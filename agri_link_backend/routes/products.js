const express = require('express');
const router = express.Router();
const { verifyToken, verifyAdminRole } = require('../middleware/auth');

// Get All Products
router.get('/', async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { category, search, admin_id, limit = 50, offset = 0 } = req.query;

        let query = `
    SELECT p.*, u.name as admin_name, u.company_name
    FROM products p
    LEFT JOIN users u ON p.admin_id = u.id
    WHERE p.is_available = TRUE
`;

        let params = [];

        if (category) {
            query += ' AND p.category = ?';
            params.push(category);
        }

        if (search) {
            query += ' AND p.name LIKE ?';
            params.push(`%${search}%`);
        }

        if (admin_id) {
            query += ' AND p.admin_id = ?';
            params.push(admin_id);
        }

        query += ' ORDER BY p.created_at DESC LIMIT ? OFFSET ?';
        params.push(parseInt(limit), parseInt(offset));

        const [products] = await pool.query(query, params);

        // Get total count
        let countQuery = 'SELECT COUNT(*) as total FROM products WHERE is_available = TRUE';
        let countParams = [];

        if (category) {
            countQuery += ' AND category = ?';
            countParams.push(category);
        }

        if (search) {
            countQuery += ' AND name LIKE ?';
            countParams.push(`%${search}%`);
        }

        if (admin_id) {
            countQuery += ' AND admin_id = ?';
            countParams.push(admin_id);
        }

        const [countResult] = await pool.query(countQuery, countParams);

        res.json({
            success: true,
            message: 'Products retrieved',
            data: {
                products,
                total: countResult[0].total,
                limit,
                offset
            }
        });
    } catch (error) {
        console.error('Get products error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get products',
            data: null
        });
    }
});

// Get Product Categories
router.get('/categories/list', async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const [categories] = await pool.query(
            'SELECT DISTINCT category FROM products ORDER BY category'
        );

        res.json({
            success: true,
            message: 'Categories retrieved',
            data: categories.map(c => c.category)
        });
    } catch (error) {
        console.error('Get categories error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get categories',
            data: null
        });
    }
});

// Get Product By ID
router.get('/:productId', async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { productId } = req.params;

        const [products] = await pool.query(
            'SELECT p.*, u.name as admin_name, u.company_name FROM products p JOIN users u ON p.admin_id = u.id WHERE p.id = ?',
            [productId]
        );

        if (products.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Product not found',
                data: null
            });
        }

        // Get reviews
        const [reviews] = await pool.query(
            'SELECT pr.*, u.name as reviewer_name FROM product_reviews pr JOIN users u ON pr.client_id = u.id WHERE pr.product_id = ? ORDER BY pr.created_at DESC',
            [productId]
        );

        res.json({
            success: true,
            message: 'Product details retrieved',
            data: {
                ...products[0],
                reviews
            }
        });
    } catch (error) {
        console.error('Get product error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get product',
            data: null
        });
    }
});

// Create Product (Admin only)
router.post('/', verifyToken, verifyAdminRole, (req, res, next) => {
    const upload = req.app.locals.upload;
    upload.single('image')(req, res, async (err) => {
        if (err) {
            return res.status(400).json({
                success: false,
                message: err.message || 'File upload failed',
                data: null
            });
        }

        try {
            const pool = req.app.locals.pool;
            const { category, name, description, price, stock, unit } = req.body;

            if (!category || !name || !price || !unit) {
                return res.status(400).json({
                    success: false,
                    message: 'Missing required fields',
                    data: null
                });
            }

            // Generate image URL if file was uploaded
            let imageUrl = null;
            if (req.file) {
                imageUrl = `http://localhost:5000/uploads/products/${req.file.filename}`;
            }

            const [result] = await pool.query(
                'INSERT INTO products (admin_id, category, name, description, price, stock, unit, image_url, is_available) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [req.user.id, category, name, description, price, stock || 0, unit, imageUrl, true]
            );

            res.status(201).json({
                success: true,
                message: 'Product created successfully',
                data: {
                    id: result.insertId,
                    admin_id: req.user.id,
                    category,
                    name,
                    description,
                    price,
                    stock: stock || 0,
                    unit,
                    image_url: imageUrl,
                    is_available: true,
                    created_at: new Date(),
                    updated_at: new Date()
                }
            });
        } catch (error) {
            console.error('Create product error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to create product',
                data: null
            });
        }
    });
});

// Update Product (Admin only)
router.put('/:productId', verifyToken, verifyAdminRole, (req, res, next) => {
    const upload = req.app.locals.upload;
    upload.single('image')(req, res, async (err) => {
        if (err) {
            return res.status(400).json({
                success: false,
                message: err.message || 'File upload failed',
                data: null
            });
        }

        try {
            const pool = req.app.locals.pool;
            const { productId } = req.params;
            const { category, name, description, price, stock, unit, is_available } = req.body;

            // Check if product belongs to user
            const [products] = await pool.query('SELECT admin_id, image_url FROM products WHERE id = ?', [productId]);
            if (products.length === 0 || products[0].admin_id !== req.user.id) {
                return res.status(403).json({
                    success: false,
                    message: 'Unauthorized to update this product',
                    data: null
                });
            }

            // Use new image URL if file was uploaded, otherwise keep existing
            let imageUrl = products[0].image_url;
            if (req.file) {
                imageUrl = `http://localhost:5000/uploads/products/${req.file.filename}`;
            }

            await pool.query(
                'UPDATE products SET category = ?, name = ?, description = ?, price = ?, stock = ?, unit = ?, image_url = ?, is_available = ? WHERE id = ?',
                [category, name, description, price, stock || 0, unit, imageUrl, is_available !== undefined ? is_available : true, productId]
            );

            // Fetch updated product
            const [updatedProducts] = await pool.query('SELECT * FROM products WHERE id = ?', [productId]);

            res.json({
                success: true,
                message: 'Product updated successfully',
                data: updatedProducts[0]
            });
        } catch (error) {
            console.error('Update product error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to update product',
                data: null
            });
        }
    });
});

// Delete Product (Admin only)
router.delete('/:productId', verifyToken, verifyAdminRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { productId } = req.params;

        // Check if product belongs to user
        const [products] = await pool.query('SELECT admin_id FROM products WHERE id = ?', [productId]);
        if (products.length === 0 || products[0].admin_id !== req.user.id) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized to delete this product',
                data: null
            });
        }

        await pool.query('DELETE FROM products WHERE id = ?', [productId]);

        res.json({
            success: true,
            message: 'Product deleted successfully',
            data: null
        });
    } catch (error) {
        console.error('Delete product error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete product',
            data: null
        });
    }
});



// Add Product Review
router.post('/:productId/reviews', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { productId } = req.params;
        const { rating, comment } = req.body;

        if (!rating || rating < 1 || rating > 5) {
            return res.status(400).json({
                success: false,
                message: 'Rating must be between 1 and 5',
                data: null
            });
        }

        const [result] = await pool.query(
            'INSERT INTO product_reviews (product_id, client_id, rating, comment) VALUES (?, ?, ?, ?)',
            [productId, req.user.id, rating, comment]
        );

        res.status(201).json({
            success: true,
            message: 'Review added successfully',
            data: {
                id: result.insertId,
                product_id: productId,
                client_id: req.user.id,
                rating,
                comment
            }
        });
    } catch (error) {
        console.error('Add review error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to add review',
            data: null
        });
    }
});

module.exports = router;
