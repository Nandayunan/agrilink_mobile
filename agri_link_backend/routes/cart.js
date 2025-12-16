const express = require('express');
const router = express.Router();
const { verifyToken, verifyClientRole } = require('../middleware/auth');

// Get Cart Items
router.get('/', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;

        const [cartItems] = await pool.query(
            `SELECT ci.*, p.name, p.price, p.unit, p.image_url, p.admin_id, u.company_name, u.name as admin_name
       FROM cart_items ci
       JOIN products p ON ci.product_id = p.id
       JOIN users u ON p.admin_id = u.id
       WHERE ci.client_id = ?
       ORDER BY ci.added_at DESC`,
            [req.user.id]
        );

        // Calculate totals by admin/supplier
        const groupedItems = {};
        let totalAmount = 0;

        cartItems.forEach(item => {
            if (!groupedItems[item.admin_id]) {
                groupedItems[item.admin_id] = {
                    admin_id: item.admin_id,
                    admin_name: item.admin_name,
                    company_name: item.company_name,
                    items: [],
                    subtotal: 0
                };
            }

            const itemTotal = item.price * item.quantity;
            groupedItems[item.admin_id].items.push(item);
            groupedItems[item.admin_id].subtotal += itemTotal;
            totalAmount += itemTotal;
        });

        res.json({
            success: true,
            message: 'Cart items retrieved',
            data: {
                items: Object.values(groupedItems),
                total_items: cartItems.length,
                total_amount: parseFloat(totalAmount.toFixed(2))
            }
        });
    } catch (error) {
        console.error('Get cart error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get cart',
            data: null
        });
    }
});

// Add to Cart
router.post('/add', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { product_id, quantity } = req.body;

        if (!product_id || !quantity || quantity < 1) {
            return res.status(400).json({
                success: false,
                message: 'Invalid product or quantity',
                data: null
            });
        }

        // Check if product exists
        const [products] = await pool.query('SELECT stock FROM products WHERE id = ?', [product_id]);
        if (products.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Product not found',
                data: null
            });
        }

        // Check stock
        if (products[0].stock < quantity) {
            return res.status(400).json({
                success: false,
                message: 'Insufficient stock',
                data: null
            });
        }

        // Try to insert or update cart item
        const [existingCart] = await pool.query(
            'SELECT id, quantity FROM cart_items WHERE client_id = ? AND product_id = ?',
            [req.user.id, product_id]
        );

        if (existingCart.length > 0) {
            // Update existing cart item
            const newQuantity = existingCart[0].quantity + quantity;

            if (products[0].stock < newQuantity) {
                return res.status(400).json({
                    success: false,
                    message: 'Insufficient stock for this quantity',
                    data: null
                });
            }

            await pool.query(
                'UPDATE cart_items SET quantity = ? WHERE id = ?',
                [newQuantity, existingCart[0].id]
            );
        } else {
            // Insert new cart item
            await pool.query(
                'INSERT INTO cart_items (client_id, product_id, quantity) VALUES (?, ?, ?)',
                [req.user.id, product_id, quantity]
            );
        }

        res.status(201).json({
            success: true,
            message: 'Item added to cart',
            data: null
        });
    } catch (error) {
        console.error('Add to cart error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to add to cart',
            data: null
        });
    }
});

// Update Cart Item Quantity
router.put('/:cartId', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { cartId } = req.params;
        const { quantity } = req.body;

        if (!quantity || quantity < 0) {
            return res.status(400).json({
                success: false,
                message: 'Invalid quantity',
                data: null
            });
        }

        // Check if cart item belongs to user
        const [cartItems] = await pool.query(
            'SELECT product_id FROM cart_items WHERE id = ? AND client_id = ?',
            [cartId, req.user.id]
        );

        if (cartItems.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Cart item not found',
                data: null
            });
        }

        if (quantity === 0) {
            // Delete cart item
            await pool.query('DELETE FROM cart_items WHERE id = ?', [cartId]);
        } else {
            // Check stock
            const [products] = await pool.query('SELECT stock FROM products WHERE id = ?', [cartItems[0].product_id]);

            if (products[0].stock < quantity) {
                return res.status(400).json({
                    success: false,
                    message: 'Insufficient stock',
                    data: null
                });
            }

            await pool.query('UPDATE cart_items SET quantity = ? WHERE id = ?', [quantity, cartId]);
        }

        res.json({
            success: true,
            message: 'Cart updated successfully',
            data: null
        });
    } catch (error) {
        console.error('Update cart error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update cart',
            data: null
        });
    }
});

// Remove from Cart
router.delete('/:cartId', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { cartId } = req.params;

        const [cartItems] = await pool.query(
            'DELETE FROM cart_items WHERE id = ? AND client_id = ?',
            [cartId, req.user.id]
        );

        res.json({
            success: true,
            message: 'Item removed from cart',
            data: null
        });
    } catch (error) {
        console.error('Remove cart error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to remove item',
            data: null
        });
    }
});

// Clear Cart
router.delete('/', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;

        await pool.query('DELETE FROM cart_items WHERE client_id = ?', [req.user.id]);

        res.json({
            success: true,
            message: 'Cart cleared',
            data: null
        });
    } catch (error) {
        console.error('Clear cart error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to clear cart',
            data: null
        });
    }
});

module.exports = router;
