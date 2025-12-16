const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const { verifyToken } = require('../middleware/auth');

// Register User
router.post('/register', async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { name, email, password, phone, role, company_name, city, province, address } = req.body;

        const userRole = role || 'client';                 // default client
        const userStatus = userRole === 'admin' ? 'pending' : 'approved'; // ✅ benar

        if (!name || !email || !password) {
            return res.status(400).json({ success: false, message: 'Missing required fields', data: null });
        }

        const [existingUser] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
        if (existingUser.length > 0) {
            return res.status(400).json({ success: false, message: 'Email already exists', data: null });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const [result] = await pool.query(
            `INSERT INTO users (name, email, password, phone, role, company_name, city, province, address, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [name, email, hashedPassword, phone || null, userRole, company_name || null, city || null, province || null, address || null, userStatus]
        );

        return res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: { id: result.insertId, name, email, role: userRole, status: userStatus }
        });
    } catch (error) {
        console.error('Register error:', error);
        return res.status(500).json({ success: false, message: error.message || 'Registration failed', data: null });
    }
});



// Login User
router.post('/login', async (req, res) => {
    try {
        const pool = req.app.locals.pool;
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Email and password required',
                data: null
            });
        }

        // Find user
        const [users] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password',
                data: null
            });
        }

        const user = users[0];

        // Check if account is approved (only for admin)
        if (user.role === 'admin' && user.status !== 'approved') {
            return res.status(403).json({
                success: false,
                message: 'Account not approved yet. Please wait for admin approval.',
                data: null
            });
        }

        // Verify password
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password',
                data: null
            });
        }

        const token = jwt.sign(
            { id: user.id, email: user.email, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN } // ✅ BENAR
        );



        res.json({
            success: true,
            message: 'Login successful',
            data: {
                token,
                user: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    role: user.role,
                    phone: user.phone,
                    company_name: user.company_name,
                    city: user.city,
                    province: user.province,
                    avatar_url: user.avatar_url
                }
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Login failed',
            data: null
        });
    }
});

// Get Current User
router.get('/me', verifyToken, async (req, res) => {
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
            message: 'User data retrieved',
            data: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                phone: user.phone,
                address: user.address,
                city: user.city,
                province: user.province,
                postal_code: user.postal_code,
                avatar_url: user.avatar_url,
                company_name: user.company_name,
                status: user.status,
                latitude: user.latitude,
                longitude: user.longitude,
                created_at: user.created_at
            }
        });
    } catch (error) {
        console.error('Get user error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get user data',
            data: null
        });
    }
});

module.exports = router;
