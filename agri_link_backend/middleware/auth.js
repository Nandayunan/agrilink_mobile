const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'No token provided',
            data: null
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({
            success: false,
            message: 'Invalid or expired token',
            data: null
        });
    }
};

const verifyAdminRole = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            message: 'Access denied. Admin role required',
            data: null
        });
    }
    next();
};

const verifyClientRole = (req, res, next) => {
    if (req.user.role !== 'client') {
        return res.status(403).json({
            success: false,
            message: 'Access denied. Client role required',
            data: null
        });
    }
    next();
};

module.exports = {
    verifyToken,
    verifyAdminRole,
    verifyClientRole
};
