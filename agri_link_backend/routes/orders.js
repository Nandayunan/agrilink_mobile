const express = require('express');
const router = express.Router();
const { verifyToken, verifyClientRole } = require('../middleware/auth');

// Generate Order Number
const generateOrderNumber = () => {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000);
    return `ORD-${timestamp}-${random}`;
};

// Calculate totals
const calculateTotals = (subtotal, discountPercentage = 0, taxPercentage = 0, serviceFee = 0) => {
    const discountAmount = (subtotal * discountPercentage) / 100;
    const taxAmount = ((subtotal - discountAmount) * taxPercentage) / 100;
    const grandTotal = subtotal - discountAmount + taxAmount + serviceFee;

    return {
        subtotal: parseFloat(subtotal),
        discount_percentage: discountPercentage,
        discount_amount: parseFloat(discountAmount.toFixed(2)),
        service_fee: parseFloat(serviceFee),
        tax_percentage: taxPercentage,
        tax_amount: parseFloat(taxAmount.toFixed(2)),
        grand_total: parseFloat(grandTotal.toFixed(2))
    };
};

// Get User Orders
router.get('/', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { status, limit = 50, offset = 0 } = req.query;

        let query = 'SELECT o.*, u.name as admin_name, u.company_name FROM orders o LEFT JOIN users u ON o.admin_id = u.id WHERE o.client_id = ?';
        let params = [req.user.id];

        if (status) {
            query += ' AND o.status = ?';
            params.push(status);
        }

        query += ' ORDER BY o.created_at DESC LIMIT ? OFFSET ?';
        params.push(parseInt(limit), parseInt(offset));

        const [orders] = await pool.query(query, params);

        // Get total count
        let countQuery = 'SELECT COUNT(*) as total FROM orders WHERE client_id = ?';
        let countParams = [req.user.id];

        if (status) {
            countQuery += ' AND status = ?';
            countParams.push(status);
        }

        const [countResult] = await pool.query(countQuery, countParams);

        res.json({
            success: true,
            message: 'Orders retrieved',
            data: {
                orders,
                total: countResult[0].total,
                limit,
                offset
            }
        });
    } catch (error) {
        console.error('Get orders error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get orders',
            data: null
        });
    }
});

// Get Order Details
router.get('/:orderId', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { orderId } = req.params;

        const [orders] = await pool.query(
            'SELECT o.*, u.name as admin_name, u.company_name FROM orders o LEFT JOIN users u ON o.admin_id = u.id WHERE o.id = ?',
            [orderId]
        );

        if (orders.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found',
                data: null
            });
        }

        // Check if user is owner
        const order = orders[0];
        if (order.client_id !== req.user.id && req.user.id !== order.admin_id) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized to view this order',
                data: null
            });
        }

        // Get order items
        const [items] = await pool.query(
            'SELECT oi.*, p.name, p.image_url, p.unit FROM order_items oi JOIN products p ON oi.product_id = p.id WHERE oi.order_id = ?',
            [orderId]
        );

        res.json({
            success: true,
            message: 'Order details retrieved',
            data: {
                ...order,
                items
            }
        });
    } catch (error) {
        console.error('Get order error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get order',
            data: null
        });
    }
});

// Create Order (Checkout)
router.post('/', verifyToken, verifyClientRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const {
            admin_id,
            items,
            discount_percentage = 0,
            service_fee = 0,
            tax_percentage = 0,
            delivery_address,
            delivery_date,
            notes
        } = req.body;

        console.log('Create order request:', {
            admin_id,
            items,
            delivery_address,
            delivery_date,
            client_id: req.user.id
        });

        if (!items || items.length === 0 || !admin_id) {
            return res.status(400).json({
                success: false,
                message: 'Invalid order data',
                data: null
            });
        }

        // Get product details and calculate subtotal
        let subtotal = 0;
        const productIds = items.map(item => item.product_id);
        const [products] = await pool.query(
            `SELECT id, price, stock FROM products WHERE id IN (${productIds.join(',')})`
        );

        const productMap = {};
        products.forEach(p => {
            productMap[p.id] = p;
        });

        // Validate stock and calculate subtotal
        for (const item of items) {
            const product = productMap[item.product_id];
            if (!product) {
                return res.status(400).json({
                    success: false,
                    message: `Product ${item.product_id} not found`,
                    data: null
                });
            }

            if (product.stock < item.quantity) {
                return res.status(400).json({
                    success: false,
                    message: `Insufficient stock for product ${item.product_id}`,
                    data: null
                });
            }

            subtotal += product.price * item.quantity;
        }

        // Calculate totals
        const totals = calculateTotals(subtotal, discount_percentage, tax_percentage, service_fee);

        // Create order
        const orderNumber = generateOrderNumber();
        const [result] = await pool.query(
            `INSERT INTO orders (order_number, client_id, admin_id, subtotal, discount_percentage, discount_amount, service_fee, tax_percentage, tax_amount, grand_total, delivery_address, delivery_date, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                orderNumber,
                req.user.id,
                admin_id,
                totals.subtotal,
                totals.discount_percentage,
                totals.discount_amount,
                totals.service_fee,
                totals.tax_percentage,
                totals.tax_amount,
                totals.grand_total,
                delivery_address,
                delivery_date,
                notes
            ]
        );

        const orderId = result.insertId;

        // Insert order items
        for (const item of items) {
            const product = productMap[item.product_id];
            await pool.query(
                'INSERT INTO order_items (order_id, product_id, quantity, price, subtotal) VALUES (?, ?, ?, ?, ?)',
                [orderId, item.product_id, item.quantity, product.price, product.price * item.quantity]
            );

            // Update product stock
            await pool.query(
                'UPDATE products SET stock = stock - ? WHERE id = ?',
                [item.quantity, item.product_id]
            );
        }

        res.status(201).json({
            success: true,
            message: 'Order created successfully',
            data: {
                order_id: orderId,
                order_number: orderNumber,
                ...totals
            }
        });
    } catch (error) {
        console.error('Create order error:', error);
        res.status(500).json({
            success: false,
            message: `Failed to create order: ${error.message}`,
            data: null
        });
    }
});

// Update Order Status
router.put('/:orderId', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { orderId } = req.params;
        const { status, payment_status } = req.body;

        const [orders] = await pool.query('SELECT * FROM orders WHERE id = ?', [orderId]);

        if (orders.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found',
                data: null
            });
        }

        const order = orders[0];

        // Check authorization
        if (req.user.id !== order.client_id && req.user.id !== order.admin_id) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized to update this order',
                data: null
            });
        }

        const updates = {};
        if (status) updates.status = status;
        if (payment_status) updates.payment_status = payment_status;

        const updateQuery = Object.keys(updates)
            .map(key => `${key} = ?`)
            .join(', ');

        if (updateQuery) {
            const values = Object.values(updates);
            values.push(orderId);

            await pool.query(
                `UPDATE orders SET ${updateQuery} WHERE id = ?`,
                values
            );
        }

        res.json({
            success: true,
            message: 'Order updated successfully',
            data: null
        });
    } catch (error) {
        console.error('Update order error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update order',
            data: null
        });
    }
});

// Get Orders for Supplier (Admin)
router.get('/supplier/list', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { status, limit = 50, offset = 0 } = req.query;

        let query = `SELECT o.*, u.name as client_name, u.phone as client_phone, u.address as client_address FROM orders o 
                    LEFT JOIN users u ON o.client_id = u.id 
                    WHERE o.admin_id = ?`;
        let params = [req.user.id];

        if (status) {
            query += ' AND o.status = ?';
            params.push(status);
        }

        query += ' ORDER BY o.created_at DESC LIMIT ? OFFSET ?';
        params.push(parseInt(limit), parseInt(offset));

        const [orders] = await pool.query(query, params);

        // Get total count
        let countQuery = 'SELECT COUNT(*) as total FROM orders WHERE admin_id = ?';
        let countParams = [req.user.id];

        if (status) {
            countQuery += ' AND status = ?';
            countParams.push(status);
        }

        const [countResult] = await pool.query(countQuery, countParams);

        // Get order items for each order
        for (const order of orders) {
            const [items] = await pool.query(
                `SELECT oi.*, p.name, p.image_url, p.unit FROM order_items oi 
                 JOIN products p ON oi.product_id = p.id 
                 WHERE oi.order_id = ?`,
                [order.id]
            );
            order.items = items;
        }

        res.json({
            success: true,
            message: 'Supplier orders retrieved',
            data: {
                orders,
                total: countResult[0].total,
                limit,
                offset
            }
        });
    } catch (error) {
        console.error('Get supplier orders error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get orders',
            data: null
        });
    }
});

// Update Order Status
router.put('/:orderId/status', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { orderId } = req.params;
        const { status } = req.body;

        if (!status) {
            return res.status(400).json({
                success: false,
                message: 'Status is required',
                data: null
            });
        }

        const [orders] = await pool.query('SELECT * FROM orders WHERE id = ?', [orderId]);

        if (orders.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Order not found',
                data: null
            });
        }

        const order = orders[0];

        // Check authorization - only supplier (admin) can update their orders
        if (req.user.id !== order.admin_id) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized to update this order',
                data: null
            });
        }

        await pool.query(
            'UPDATE orders SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
            [status, orderId]
        );

        res.json({
            success: true,
            message: 'Order status updated successfully',
            data: { id: orderId, status }
        });
    } catch (error) {
        console.error('Update order status error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update order status',
            data: null
        });
    }
});

module.exports = router;
