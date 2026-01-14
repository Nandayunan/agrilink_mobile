const express = require('express');
const router = express.Router();

// ✅ Dapatkan daftar supplier/petani untuk restoran
router.get('/suppliers-farmers/:restaurantId', async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const pool = req.app.locals.pool;

    // Query untuk mendapatkan supplier (petani role='admin')
    const query = `
      SELECT DISTINCT
        u.id,
        u.name,
        u.company_name,
        u.phone,
        u.city,
        u.province,
        u.role,
        'supplier' as contact_type
      FROM users u
      WHERE u.role = 'admin' AND u.status = 'approved'
      UNION
      SELECT DISTINCT
        u.id,
        u.name,
        u.company_name,
        u.phone,
        u.city,
        u.province,
        u.role,
        'farmer' as contact_type
      FROM users u
      INNER JOIN restaurant_farmers rf ON u.id = rf.farmer_id
      WHERE rf.restaurant_id = ? AND u.status = 'approved'
      ORDER BY name ASC
    `;

    const [results] = await pool.query(query, [restaurantId]);
    res.json(results);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// ✅ Dapatkan pesan antara restoran dan supplier/petani
router.get('/conversation/:restaurantId/:contactId', async (req, res) => {
  try {
    const { restaurantId, contactId } = req.params;
    const pool = req.app.locals.pool;

    const query = `
      SELECT
        m.id,
        m.sender_id,
        m.recipient_id,
        m.title,
        m.content,
        m.message_type,
        m.is_read,
        m.created_at,
        u_sender.name as sender_name,
        u_sender.role as sender_role,
        u_recipient.name as recipient_name,
        u_recipient.role as recipient_role
      FROM messages m
      INNER JOIN users u_sender ON m.sender_id = u_sender.id
      INNER JOIN users u_recipient ON m.recipient_id = u_recipient.id
      WHERE (
        (m.sender_id = ? AND m.recipient_id = ?)
        OR (m.sender_id = ? AND m.recipient_id = ?)
      )
      ORDER BY m.created_at DESC
    `;

    const [results] = await pool.query(query, [restaurantId, contactId, contactId, restaurantId]);
    res.json(results);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// ✅ Dapatkan pesan masuk untuk restoran (dari supplier/petani)
router.get('/inbox/:restaurantId', async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const pool = req.app.locals.pool;

    const query = `
      SELECT
        m.id,
        m.sender_id,
        m.recipient_id,
        m.title,
        m.content,
        m.message_type,
        m.is_read,
        m.created_at,
        u_sender.name as sender_name,
        u_sender.company_name as sender_company,
        u_sender.role as sender_role
      FROM messages m
      INNER JOIN users u_sender ON m.sender_id = u_sender.id
      WHERE m.recipient_id = ?
      ORDER BY m.is_read ASC, m.created_at DESC
    `;

    const [results] = await pool.query(query, [restaurantId]);
    res.json(results);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// ✅ Kirim pesan baru
router.post('/send', async (req, res) => {
  try {
    const { senderId, recipientId, title, content, messageType } = req.body;
    const pool = req.app.locals.pool;

    // Validasi input
    if (!senderId || !recipientId || !title || !content) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const query = `
      INSERT INTO messages (sender_id, recipient_id, title, content, message_type, is_read)
      VALUES (?, ?, ?, ?, ?, 0)
    `;

    const [result] = await pool.query(
      query,
      [senderId, recipientId, title, content, messageType || 'inquiry']
    );

    res.json({
      id: result.insertId,
      senderId,
      recipientId,
      title,
      content,
      messageType: messageType || 'inquiry',
      is_read: 0,
      created_at: new Date()
    });
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Failed to send message' });
  }
});

// ✅ Tandai pesan sebagai sudah dibaca
router.put('/mark-as-read/:messageId', async (req, res) => {
  try {
    const { messageId } = req.params;
    const pool = req.app.locals.pool;

    const query = 'UPDATE messages SET is_read = 1 WHERE id = ?';
    await pool.query(query, [messageId]);

    res.json({ success: true });
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Failed to update message' });
  }
});

// ✅ Dapatkan statistik pesan
router.get('/stats/:restaurantId', async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const pool = req.app.locals.pool;

    const query = `
      SELECT
        COUNT(*) as total_messages,
        SUM(CASE WHEN is_read = 0 THEN 1 ELSE 0 END) as unread_messages
      FROM messages
      WHERE recipient_id = ?
    `;

    const [results] = await pool.query(query, [restaurantId]);
    res.json(results[0]);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

// ✅ Tambahkan petani ke favorite list restoran
router.post('/add-favorite-farmer', async (req, res) => {
  try {
    const { restaurantId, farmerId } = req.body;
    const pool = req.app.locals.pool;

    if (!restaurantId || !farmerId) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const query = `
      INSERT INTO restaurant_farmers (restaurant_id, farmer_id)
      VALUES (?, ?)
      ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)
    `;

    const [result] = await pool.query(query, [restaurantId, farmerId]);
    res.json({ success: true, id: result.insertId });
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Failed to add farmer' });
  }
});

// ✅ Hapus petani dari favorite list restoran
router.delete('/remove-favorite-farmer/:restaurantId/:farmerId', async (req, res) => {
  try {
    const { restaurantId, farmerId } = req.params;
    const pool = req.app.locals.pool;

    const query = `
      DELETE FROM restaurant_farmers
      WHERE restaurant_id = ? AND farmer_id = ?
    `;

    await pool.query(query, [restaurantId, farmerId]);
    res.json({ success: true });
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Failed to remove farmer' });
  }
});

module.exports = router;
