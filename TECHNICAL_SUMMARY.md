# 🎯 Fitur Dashboard Messaging Restoran - RINGKASAN TEKNIS

## Alur Kerja Sistem

### 📱 User Journey (Restoran)

```
Login (Restoran)
    ↓
Home Screen → Tab "Pesan" (NEW!)
    ↓
    ├─ Tab 1: "Pesan Masuk (N)" ← Lihat pesan dari supplier/petani
    │   ├─ Klik pesan → Lihat detail & Balas
    │   └─ Unread indicator (red dot)
    │
    └─ Tab 2: "Hubungi Supplier/Petani" ← Hubungi langsung
        ├─ Section: "Supplier (Petani)"
        │   └─ Card kontak supplier
        │       └─ Tombol "Hubungi" → Compose Message Dialog
        │
        └─ Section: "Petani Pilihan"
            └─ Card kontak farmer (dari restaurant_farmers table)
                └─ Tombol "Hubungi" → Compose Message Dialog
```

---

## 🗄️ Database Structure

### Relasi Tabel

```
users (existing)
  ├─ id
  ├─ name
  ├─ email
  ├─ phone
  ├─ company_name
  ├─ role ('admin' = Petani, 'client' = Restoran)
  ├─ city
  ├─ province
  └─ status ('pending', 'approved', 'rejected')

    ↓ (1 to Many)
    
messages (NEW)
  ├─ id
  ├─ sender_id → FK users.id
  ├─ recipient_id → FK users.id
  ├─ sender_type ('restaurant', 'farmer', 'supplier')
  ├─ recipient_type
  ├─ title
  ├─ content
  ├─ message_type ('inquiry', 'offer', 'update', 'order_related')
  ├─ is_read (0/1)
  ├─ created_at
  └─ updated_at

restaurant_farmers (NEW)
  ├─ id
  ├─ restaurant_id → FK users.id (client)
  ├─ farmer_id → FK users.id (admin/petani)
  └─ created_at
```

### Query Contoh

```sql
-- Get semua supplier (petani)
SELECT * FROM users WHERE role = 'admin' AND status = 'approved'

-- Get petani favorit restoran
SELECT u.* FROM users u
INNER JOIN restaurant_farmers rf ON u.id = rf.farmer_id
WHERE rf.restaurant_id = 2 AND u.status = 'approved'

-- Get pesan masuk restoran
SELECT m.*, u.name as sender_name, u.company_name as sender_company
FROM messages m
INNER JOIN users u ON m.sender_id = u.id
WHERE m.recipient_id = 2
ORDER BY m.is_read ASC, m.created_at DESC
```

---

## 🔄 API Flow

### Inisialisasi Dashboard

```
RestaurantDashboardScreen.initState()
  ├─ fetchSuppliersAndFarmers(restaurantId)
  │  └─ GET /api/messages/suppliers-farmers/2
  │     ├─ Query suppliers (role='admin')
  │     └─ Query favorite farmers (from restaurant_farmers)
  │
  ├─ fetchInbox(restaurantId)
  │  └─ GET /api/messages/inbox/2
  │     └─ Load all incoming messages
  │
  └─ fetchMessageStats(restaurantId)
     └─ GET /api/messages/stats/2
        └─ Get unread count
```

### Send Message Flow

```
User clicks "Hubungi" → Dialog Compose
  ↓
Fill: title, content, messageType
  ↓
Click "Kirim Pesan"
  ↓
POST /api/messages/send
  {
    senderId: 2 (restoran),
    recipientId: 1 (supplier/petani),
    title: "Pertanyaan stok tomat",
    content: "Berapa stok tomat untuk bulan depan?",
    messageType: "inquiry"
  }
  ↓
Backend INSERT message to DB
  ↓
Return new Message object
  ↓
Add to local messages list
  ↓
Show success snackbar
```

### Read Message Flow

```
User clicks message in Inbox
  ↓
Open bottom sheet with detail
  ↓
markAsRead(messageId)
  ↓
PUT /api/messages/mark-as-read/123
  ↓
Backend UPDATE messages SET is_read = 1
  ↓
Update local UI (remove indicator)
```

---

## 🎨 UI Components

### RestaurantDashboardScreen
```
Scaffold
├─ AppBar (title: "Dashboard Pesan")
├─ Column
│  ├─ Container (Tab Bar)
│  │  └─ TabBar (2 tabs)
│  │     ├─ "Pesan Masuk (${unreadCount})"
│  │     └─ "Hubungi Supplier/Petani"
│  │
│  └─ Expanded
│     └─ TabBarView
│        ├─ _buildInboxTab()
│        │  └─ ListView of message cards
│        │     ├─ Message card header (sender name)
│        │     ├─ Message title preview
│        │     ├─ Message content preview (2 lines)
│        │     ├─ Date & message type badge
│        │     └─ Red dot if unread
│        │
│        └─ _buildContactsTab()
│           └─ Column
│              ├─ Suppliers Section
│              │  └─ Contact cards
│              └─ Favorite Farmers Section
│                 └─ Contact cards
```

### Message Card
```
Card
└─ InkWell (tap to view detail)
   └─ Column
      ├─ Row (header)
      │  ├─ Column (sender info)
      │  │  ├─ sender name (bold)
      │  │  └─ sender company (gray)
      │  └─ Red dot (if unread)
      │
      ├─ Text (title)
      ├─ Text (content preview - 2 lines)
      └─ Row (footer)
         ├─ Date (left)
         └─ Message type badge (right)
            ├─ inquiry → blue
            ├─ offer → green
            ├─ update → orange
            └─ order_related → primary color
```

### Contact Card
```
Card
└─ Column
   ├─ Row (header)
   │  ├─ Avatar circle
   │  └─ Column (contact info)
   │     ├─ name (bold)
   │     ├─ company name (gray)
   │     ├─ location (with icon)
   │     └─ phone
   │
   └─ Row (actions)
      └─ Button "Hubungi"
```

---

## 📊 Data Models

### Message Model
```dart
class Message {
  int id
  int senderId
  int recipientId
  String title
  String content
  String messageType  // inquiry, offer, update, order_related
  bool isRead
  DateTime createdAt
  String senderName
  String senderCompany
  String senderRole      // admin, client
}
```

### Contact Model
```dart
class Contact {
  int id
  String name
  String? companyName
  String? phone
  String? city
  String? province
  String role          // admin, client
  String contactType   // supplier, farmer
}
```

---

## 🔐 State Management

### MessageProvider (ChangeNotifier)
```
Properties:
├─ List<Contact> _contacts
├─ List<Message> _messages (current conversation)
├─ List<Message> _inbox (all incoming)
├─ Message? _selectedMessage
├─ Contact? _selectedContact
├─ bool _isLoading
├─ String _error
└─ int _unreadCount

Methods:
├─ fetchSuppliersAndFarmers(restaurantId)
├─ fetchConversation(restaurantId, contactId)
├─ fetchInbox(restaurantId)
├─ fetchMessageStats(restaurantId)
├─ sendMessage(...)
├─ markAsRead(messageId)
├─ addFavoriteFarmer(restaurantId, farmerId)
├─ removeFavoriteFarmer(restaurantId, farmerId)
├─ selectContact(contact)
└─ clearMessages()
```

---

## 🎯 Key Features

### ✅ Multi-section Contact List
```
Suppliers (All petani with role='admin')
├─ Admin Petani 1
├─ Admin Petani 2
└─ Admin Petani 3

Favorite Farmers (From restaurant_farmers table)
├─ Farmer A
└─ Farmer B
```

### ✅ Unread Count Badge
- Real-time counter di tab "Pesan Masuk"
- Update otomatis setelah fetch

### ✅ Message Type Indicator
- Visual badge dengan warna berbeda
- Inquiry (blue), Offer (green), Update (orange), Order (primary)

### ✅ Two-way Communication
- Restoran bisa kirim pesan ke supplier/petani
- Supplier/petani bisa balas pesan

### ✅ Message History
- Semua pesan tersimpan di database
- Dapat diakses kapan saja

---

## 📋 File Checklist

Backend:
- ✅ `routes/messages.js` - API routes (8 endpoints)
- ✅ `agri_link.sql` - Database schema update
- ✅ `server.js` - Register messages route

Frontend:
- ✅ `models/message.dart` - Message & Contact classes
- ✅ `providers/message_provider.dart` - State management
- ✅ `screens/restaurant_dashboard_screen.dart` - Main UI
- ✅ `screens/home_screen.dart` - Integration
- ✅ `main.dart` - Add MessageProvider

---

## 🚀 Deployment Steps

1. **Database**
   ```bash
   mysql -u root -p < agri_link.sql
   ```

2. **Backend**
   ```bash
   cd agri_link_backend
   npm install  # if needed
   npm start
   ```

3. **Frontend**
   ```bash
   cd agri_link_app
   flutter pub get  # if needed
   flutter run
   ```

4. **Test**
   - Login sebagai restoran
   - Navigasi ke tab "Pesan"
   - Test mengirim pesan ke supplier

---

**Status: ✅ COMPLETE & READY TO USE**
