const express = require('express');
const router = express.Router();
const { verifyToken, verifyAdminRole, verifyClientRole } = require('../middleware/auth');

// Get User Profile
router.get('/profile', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const [users] = await pool.query('SELECT * FROM users WHERE id = ?', [req.user.id]);

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
                data: null
            });
        }

        const user = users[0];
        res.json({
            success: true,
            message: 'User profile retrieved',
            data: user
        });
    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get profile',
            data: null
        });
    }
});

// Update User Profile
router.put('/profile', verifyToken, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { name, phone, address, city, province, postal_code, latitude, longitude } = req.body;

        await pool.query(
            'UPDATE users SET name = ?, phone = ?, address = ?, city = ?, province = ?, postal_code = ?, latitude = ?, longitude = ? WHERE id = ?',
            [name, phone, address, city, province, postal_code, latitude, longitude, req.user.id]
        );

        res.json({
            success: true,
            message: 'Profile updated successfully',
            data: null
        });
    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update profile',
            data: null
        });
    }
});

// Get All Users (Admin only - untuk approval)
router.get('/', verifyToken, verifyAdminRole, async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const [users] = await pool.query('SELECT * FROM users WHERE role = ?', ['admin']);

        res.json({
            success: true,
            message: 'Users retrieved',
            data: users
        });
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get users',
            data: null
        });
    }
});

// Get All Approved Admins (Suppliers)
router.get('/suppliers/list', async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const [admins] = await pool.query(
            'SELECT id, name, email, phone, city, province, company_name, description, avatar_url, latitude, longitude FROM users WHERE role = ? AND status = ? ORDER BY name',
            ['admin', 'approved']
        );

        res.json({
            success: true,
            message: 'Suppliers retrieved',
            data: admins
        });
    } catch (error) {
        console.error('Get suppliers error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get suppliers',
            data: null
        });
    }
});

// Get Admin/Supplier by ID
router.get('/:userId', async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { userId } = req.params;

        const [users] = await pool.query('SELECT id, name, email, phone, address, city, province, company_name, description, avatar_url, latitude, longitude FROM users WHERE id = ? AND role = ? AND status = ?',
            [userId, 'admin', 'approved']);

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Admin not found',
                data: null
            });
        }

        res.json({
            success: true,
            message: 'Admin details retrieved',
            data: users[0]
        });
    } catch (error) {
        console.error('Get admin error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get admin',
            data: null
        });
    }
});



module.exports = router;
