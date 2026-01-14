import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/message_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = context.read<AuthProvider>();
    final messageProvider = context.read<MessageProvider>();
    final restaurantId = authProvider.currentUser?.id;

    if (restaurantId != null) {
      await messageProvider.fetchSuppliersAndFarmers(restaurantId);
      await messageProvider.fetchInbox(restaurantId);
      await messageProvider.fetchMessageStats(restaurantId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard Pesan', showBackButton: false),
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer2<AuthProvider, MessageProvider>(
        builder: (context, authProvider, messageProvider, _) {
          final restaurantId = authProvider.currentUser?.id;

          if (restaurantId == null) {
            return const Center(
              child: Text('Tidak ada data restoran'),
            );
          }

          return Column(
            children: [
              // Tab Bar
              Container(
                color: AppTheme.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textGray,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: [
                    Tab(
                      text: 'Pesan Masuk (${messageProvider.unreadCount})',
                    ),
                    const Tab(text: 'Hubungi Supplier/Petani'),
                  ],
                ),
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInboxTab(restaurantId, messageProvider),
                    _buildContactsTab(restaurantId, messageProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ Tab Pesan Masuk
  Widget _buildInboxTab(int restaurantId, MessageProvider messageProvider) {
    if (messageProvider.isLoading) {
      return const LoadingWidget(message: 'Memuat pesan...');
    }

    if (messageProvider.inbox.isEmpty) {
      return EmptyStateWidget(
        title: 'Tidak Ada Pesan',
        message: 'Hubungi supplier atau petani untuk memulai percakapan',
        icon: Icons.mail_outline,
        onRetry: _loadInitialData,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppPadding.lg),
      itemCount: messageProvider.inbox.length,
      itemBuilder: (context, index) {
        final message = messageProvider.inbox[index];
        return _buildMessageCard(message, restaurantId, messageProvider);
      },
    );
  }

  // ✅ Card Pesan Masuk
  Widget _buildMessageCard(
    Message message,
    int restaurantId,
    MessageProvider messageProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppPadding.lg),
      child: InkWell(
        onTap: () async {
          // Mark as read
          if (!message.isRead) {
            await messageProvider.markAsRead(message.id);
          }

          // Buka detail pesan
          if (mounted) {
            _showMessageDetail(context, message, restaurantId, messageProvider);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.senderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.senderCompany,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!message.isRead)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppPadding.md),
              // Title
              Text(
                message.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppPadding.sm),
              // Preview
              Text(
                message.content,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGray,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppPadding.md),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppFormatter.formatDate(message.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.md,
                      vertical: AppPadding.sm,
                    ),
                    decoration: BoxDecoration(
                      color: _getMessageTypeColor(message.messageType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      _getMessageTypeLabel(message.messageType),
                      style: TextStyle(
                        color: _getMessageTypeColor(message.messageType),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Tab Kontak Supplier/Petani
  Widget _buildContactsTab(int restaurantId, MessageProvider messageProvider) {
    if (messageProvider.isLoading) {
      return const LoadingWidget(message: 'Memuat supplier dan petani...');
    }

    if (messageProvider.contacts.isEmpty) {
      return EmptyStateWidget(
        title: 'Tidak Ada Supplier/Petani',
        message: 'Mulai dengan menambahkan petani favorit',
        icon: Icons.people_outline,
        onRetry: _loadInitialData,
      );
    }

    // Pisahkan supplier dan farmer
    final suppliers = messageProvider.contacts
        .where((c) => c.contactType == 'supplier')
        .toList();
    final farmers = messageProvider.contacts
        .where((c) => c.contactType == 'farmer')
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Suppliers Section
            if (suppliers.isNotEmpty) ...[
              const Text(
                'Supplier (Petani)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppPadding.md),
              ...suppliers.map((supplier) {
                return _buildContactCard(
                  supplier,
                  restaurantId,
                  messageProvider,
                );
              }).toList(),
              const SizedBox(height: AppPadding.xxl),
            ],

            // Farmers Section (Favorite)
            if (farmers.isNotEmpty) ...[
              const Text(
                'Petani Pilihan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppPadding.md),
              ...farmers.map((farmer) {
                return _buildContactCard(
                  farmer,
                  restaurantId,
                  messageProvider,
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ Card Kontak
  Widget _buildContactCard(
    Contact contact,
    int restaurantId,
    MessageProvider messageProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppPadding.md),
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Center(
                    child: Text(
                      contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppPadding.lg),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (contact.companyName != null)
                        Text(
                          contact.companyName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      if (contact.city != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppTheme.textGray,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${contact.city}, ${contact.province}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textGray,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppPadding.lg),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Hubungi',
                    onPressed: () {
                      _showContactDialog(
                        context,
                        contact,
                        restaurantId,
                        messageProvider,
                      );
                    },
                    height: 40,
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Dialog Detail Pesan
  void _showMessageDetail(
    BuildContext context,
    Message message,
    int restaurantId,
    MessageProvider messageProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppPadding.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.senderName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.senderCompany,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Title
                Text(
                  message.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                // Content
                Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textDark,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
                // Meta
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppFormatter.formatDate(message.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGray,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.md,
                        vertical: AppPadding.sm,
                      ),
                      decoration: BoxDecoration(
                        color: _getMessageTypeColor(message.messageType)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        _getMessageTypeLabel(message.messageType),
                        style: TextStyle(
                          color: _getMessageTypeColor(message.messageType),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.xxl),
                // Reply Button
                CustomButton(
                  label: 'Balas Pesan',
                  onPressed: () {
                    Navigator.pop(context);
                    _showComposeMessageDialog(
                      context,
                      message.senderId,
                      message.senderName,
                      restaurantId,
                      messageProvider,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Dialog Hubungi Supplier/Petani
  void _showContactDialog(
    BuildContext context,
    Contact contact,
    int restaurantId,
    MessageProvider messageProvider,
  ) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String messageType = 'inquiry';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppPadding.lg),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hubungi ${contact.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Message Type
                      const Text(
                        'Jenis Pesan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppPadding.md),
                      Wrap(
                        spacing: AppPadding.md,
                        children: [
                          _buildMessageTypeChip(
                            'Pertanyaan',
                            'inquiry',
                            messageType,
                            (value) {
                              setState(() => messageType = value);
                            },
                          ),
                          _buildMessageTypeChip(
                            'Penawaran',
                            'offer',
                            messageType,
                            (value) {
                              setState(() => messageType = value);
                            },
                          ),
                          _buildMessageTypeChip(
                            'Update',
                            'update',
                            messageType,
                            (value) {
                              setState(() => messageType = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppPadding.xxl),
                      // Title Field
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Pesan',
                          hintText: 'Masukkan judul',
                          prefixIcon: Icon(Icons.subject),
                        ),
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Content Field
                      TextFormField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          labelText: 'Isi Pesan',
                          hintText: 'Masukkan isi pesan',
                          prefixIcon: Icon(Icons.message),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: AppPadding.xxl),
                      // Send Button
                      CustomButton(
                        label: 'Kirim Pesan',
                        onPressed: () async {
                          if (titleController.text.isEmpty ||
                              contentController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Semua field harus diisi'),
                              ),
                            );
                            return;
                          }

                          final success = await messageProvider.sendMessage(
                            senderId: restaurantId,
                            recipientId: contact.id,
                            title: titleController.text.trim(),
                            content: contentController.text.trim(),
                            messageType: messageType,
                          );

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pesan berhasil dikirim'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal mengirim pesan: ${messageProvider.error}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    contentController.dispose();
  }

  // ✅ Dialog Compose Message
  void _showComposeMessageDialog(
    BuildContext context,
    int recipientId,
    String recipientName,
    int restaurantId,
    MessageProvider messageProvider,
  ) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String messageType = 'inquiry';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppPadding.lg),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balas ke $recipientName',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Title Field
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Balasan',
                          hintText: 'Masukkan judul',
                          prefixIcon: Icon(Icons.subject),
                        ),
                      ),
                      const SizedBox(height: AppPadding.lg),
                      // Content Field
                      TextFormField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          labelText: 'Isi Balasan',
                          hintText: 'Masukkan isi balasan',
                          prefixIcon: Icon(Icons.message),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: AppPadding.xxl),
                      // Send Button
                      CustomButton(
                        label: 'Kirim Balasan',
                        onPressed: () async {
                          if (titleController.text.isEmpty ||
                              contentController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Semua field harus diisi'),
                              ),
                            );
                            return;
                          }

                          final success = await messageProvider.sendMessage(
                            senderId: restaurantId,
                            recipientId: recipientId,
                            title: titleController.text.trim(),
                            content: contentController.text.trim(),
                            messageType: messageType,
                          );

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Balasan berhasil dikirim'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal mengirim balasan: ${messageProvider.error}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    contentController.dispose();
  }

  // ✅ Helper: Message Type Chip
  Widget _buildMessageTypeChip(
    String label,
    String value,
    String selected,
    Function(String) onSelected,
  ) {
    final isSelected = selected == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: isSelected ? AppTheme.primaryLight : AppTheme.white,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textGray,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ✅ Helper: Get Message Type Color
  Color _getMessageTypeColor(String type) {
    switch (type) {
      case 'inquiry':
        return AppTheme.infoColor;
      case 'offer':
        return AppTheme.successColor;
      case 'update':
        return AppTheme.warningColor;
      case 'order_related':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textGray;
    }
  }

  // ✅ Helper: Get Message Type Label
  String _getMessageTypeLabel(String type) {
    switch (type) {
      case 'inquiry':
        return 'Pertanyaan';
      case 'offer':
        return 'Penawaran';
      case 'update':
        return 'Update';
      case 'order_related':
        return 'Terkait Pesanan';
      default:
        return type;
    }
  }
}
