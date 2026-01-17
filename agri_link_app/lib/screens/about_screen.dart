import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.agriculture,
                              color: Colors.white, size: 40),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Agri-Link',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Deskripsi Aplikasi
              _buildSectionTitle('Tentang Aplikasi'),
              const SizedBox(height: 8),
              _buildSectionContent(
                'Agri-Link adalah platform digital yang menghubungkan petani, '
                'pedagang, dan konsumen dalam satu ekosistem pertanian yang terintegrasi. '
                'Aplikasi ini memudahkan petani untuk menjual produk langsung kepada konsumen '
                'atau pedagang, meningkatkan transparansi harga, dan memberikan akses informasi '
                'cuaca real-time untuk membantu pengambilan keputusan pertanian yang lebih baik.',
              ),
              const SizedBox(height: 24),

              // Fitur Utama
              _buildSectionTitle('Fitur Utama'),
              const SizedBox(height: 8),
              _buildFeatureItem(
                icon: Icons.shopping_cart,
                title: 'Belanja Produk',
                description: 'Temukan dan beli produk segar langsung dari petani',
              ),
              _buildFeatureItem(
                icon: Icons.assignment,
                title: 'Kelola Pesanan',
                description: 'Pantau dan kelola status pesanan Anda dengan mudah',
              ),
              _buildFeatureItem(
                icon: Icons.inventory_2,
                title: 'Manajemen Produk',
                description: 'Petani dapat menambah dan mengelola produk mereka',
              ),
              _buildFeatureItem(
                icon: Icons.cloud,
                title: 'Informasi Cuaca',
                description: 'Dapatkan prediksi cuaca untuk perencanaan pertanian',
              ),
              _buildFeatureItem(
                icon: Icons.message,
                title: 'Komunikasi Langsung',
                description: 'Chat langsung dengan penjual atau pembeli',
              ),
              const SizedBox(height: 24),

              // User Guide
              _buildSectionTitle('Panduan Pengguna'),
              const SizedBox(height: 12),
              _buildGuideItem(
                number: '1',
                title: 'Daftar dan Login',
                description: 'Buat akun baru atau login dengan akun yang sudah ada. '
                    'Pilih tipe akun (Pembeli, Petani, atau Admin) sesuai kebutuhan Anda.',
              ),
              _buildGuideItem(
                number: '2',
                title: 'Jelajahi Produk',
                description: 'Lihat katalog produk yang tersedia. Gunakan fitur filter '
                    'dan pencarian untuk menemukan produk yang Anda cari.',
              ),
              _buildGuideItem(
                number: '3',
                title: 'Tambah ke Keranjang',
                description: 'Pilih produk yang ingin dibeli dan tambahkan ke keranjang. '
                    'Atur jumlah produk sesuai kebutuhan.',
              ),
              _buildGuideItem(
                number: '4',
                title: 'Lakukan Pembayaran',
                description: 'Lanjutkan ke pembayaran dan isi data pengiriman. '
                    'Pilih metode pembayaran yang tersedia.',
              ),
              _buildGuideItem(
                number: '5',
                title: 'Pantau Pesanan',
                description: 'Cek status pesanan Anda di menu Pesanan. '
                    'Terima notifikasi real-time untuk setiap perubahan status.',
              ),
              _buildGuideItem(
                number: '6',
                title: 'Hubungi Penjual',
                description: 'Gunakan fitur pesan untuk berkomunikasi langsung dengan penjual '
                    'jika ada pertanyaan atau masalah.',
              ),
              const SizedBox(height: 24),

              // Tim Pengembang
              _buildSectionTitle('Tim Pengembang'),
              const SizedBox(height: 12),
              _buildDeveloperCard(
                name: 'Abdy Ananda Yunan',
                studentId: '152022100',
                role: 'Fullstack Developer',
                roleColor: const Color(0xFF4CAF50),
              ),
              _buildDeveloperCard(
                name: 'Putri Salsanabilah M',
                studentId: '152022025',
                role: 'UI/UX Designer',
                roleColor: const Color(0xFF2196F3),
              ),
              _buildDeveloperCard(
                name: 'Selma Auliya',
                studentId: '152022031',
                role: 'Report & Documentation',
                roleColor: const Color(0xFFFFC107),
              ),
              _buildDeveloperCard(
                name: 'Ivan Rizky',
                studentId: '152022156',
                role: 'Project Manager & Arsitektur Sistem',
                roleColor: const Color(0xFFFF9800),
              ),
              const SizedBox(height: 24),

              // Footer Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Informasi Tambahan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '© 2026 Agri-Link. Semua hak cipta dilindungi.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Untuk bantuan, hubungi: support@agrilink.com',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.6,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String studentId,
    required String role,
    required Color roleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.person,
                  color: roleColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      studentId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
