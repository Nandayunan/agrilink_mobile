const express = require('express');
const router = express.Router();
const { verifyToken, verifyAdminRole } = require('../middleware/auth');

// Get Pending Accounts (for Admin approval)
router.get('/pending-accounts', verifyToken, verifyAdminRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;

        const [users] = await pool.query(
            'SELECT id, name, email, phone, company_name, city, province, business_license, description, created_at FROM users WHERE role = ? AND status = ?',
            ['admin', 'pending']
        );

        res.json({
            success: true,
            message: 'Pending accounts retrieved',
            data: users
        });
    } catch (error) {
        console.error('Get pending accounts error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get pending accounts',
            data: null
        });
    }
});

// Approve Account
router.post('/approve-account/:userId', verifyToken, verifyAdminRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { userId } = req.params;

        // Check if user exists and is pending
        const [users] = await pool.query(
            'SELECT id, role, status FROM users WHERE id = ?',
            [userId]
        );

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
                data: null
            });
        }

        if (users[0].status === 'approved') {
            return res.status(400).json({
                success: false,
                message: 'Account already approved',
                data: null
            });
        }

        await pool.query(
            'UPDATE users SET status = ? WHERE id = ?',
            ['approved', userId]
        );

        res.json({
            success: true,
            message: 'Account approved successfully',
            data: null
        });
    } catch (error) {
        console.error('Approve account error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to approve account',
            data: null
        });
    }
});

// Reject Account
router.post('/reject-account/:userId', verifyToken, verifyAdminRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { userId } = req.params;
        const { reason } = req.body;

        const [users] = await pool.query(
            'SELECT id, role, status FROM users WHERE id = ?',
            [userId]
        );

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
                data: null
            });
        }

        await pool.query(
            'UPDATE users SET status = ? WHERE id = ?',
            ['rejected', userId]
        );

        res.json({
            success: true,
            message: 'Account rejected successfully',
            data: null
        });
    } catch (error) {
        console.error('Reject account error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to reject account',
            data: null
        });
    }
});

// Get Dashboard Stats (for Admin)
router.get('/dashboard/stats', verifyToken, verifyAdminRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;

        // Get orders for this admin
        const [orders] = await pool.query(
            'SELECT COUNT(*) as total_orders, SUM(grand_total) as total_revenue FROM orders WHERE admin_id = ?',
            [req.user.id]
        );

        const [products] = await pool.query(
            'SELECT COUNT(*) as total_products, SUM(stock) as total_stock FROM products WHERE admin_id = ?',
            [req.user.id]
        );

        const [pendingOrders] = await pool.query(
            'SELECT COUNT(*) as pending_orders FROM orders WHERE admin_id = ? AND status = ?',
            [req.user.id, 'pending']
        );

        res.json({
            success: true,
            message: 'Dashboard stats retrieved',
            data: {
                total_orders: orders[0].total_orders || 0,
                total_revenue: orders[0].total_revenue || 0,
                total_products: products[0].total_products || 0,
                total_stock: products[0].total_stock || 0,
                pending_orders: pendingOrders[0].pending_orders || 0
            }
        });
    } catch (error) {
        console.error('Get stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get dashboard stats',
            data: null
        });
    }
});

// Get Orders for Admin (their supplier orders)
router.get('/orders', verifyToken, verifyAdminRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { status, limit = 50, offset = 0 } = req.query;

        let query = 'SELECT o.*, u.name as client_name, u.company_name FROM orders o JOIN users u ON o.client_id = u.id WHERE o.admin_id = ?';
        let params = [req.user.id];

        if (status) {
            query += ' AND o.status = ?';
            params.push(status);
        }

        query += ' ORDER BY o.created_at DESC LIMIT ? OFFSET ?';
        params.push(parseInt(limit), parseInt(offset));

        const [orders] = await pool.query(query, params);

        let countQuery = 'SELECT COUNT(*) as total FROM orders WHERE admin_id = ?';
        let countParams = [req.user.id];

        if (status) {
            countQuery += ' AND status = ?';
            countParams.push(status);
        }

        const [countResult] = await pool.query(countQuery, countParams);

        res.json({
            success: true,
            message: 'Admin orders retrieved',
            data: {
                orders,
                total: countResult[0].total,
                limit,
                offset
            }
        });
    } catch (error) {
        console.error('Get admin orders error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get orders',
            data: null
        });
    }
});

// Approve Order
router.post('/orders/:orderId/approve', verifyToken, verifyAdminRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { orderId } = req.params;

        const [orders] = await pool.query(
            'SELECT admin_id FROM orders WHERE id = ?',
            [orderId]
        );

        if (orders.length === 0 || orders[0].admin_id !== req.user.id) {
            return res.status(403).json({
                success: false,
                message: 'Unauthorized to approve this order',
                data: null
            });
        }

        await pool.query(
            'UPDATE orders SET status = ? WHERE id = ?',
            ['confirmed', orderId]
        );

        res.json({
            success: true,
            message: 'Order approved successfully',
            data: null
        });
    } catch (error) {
        console.error('Approve order error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to approve order',
            data: null
        });
    }
});

module.exports = router;
