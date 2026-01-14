import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedRole = 'client';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      phone: _phoneController.text.trim(),
      companyName: _companyNameController.text.trim(),
      city: _cityController.text.trim(),
      province: _provinceController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil! Silakan login.')),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pendaftaran gagal: ${authProvider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Daftar Akun',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppTheme.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Role Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppPadding.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tipe Akun',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AppPadding.md),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Restoran'),
                                    value: 'client',
                                    groupValue: _selectedRole,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRole = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Petani'),
                                    value: 'admin',
                                    groupValue: _selectedRole,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRole = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      validator: AppValidator.validateName,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      validator: AppValidator.validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'contoh@email.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      validator: AppValidator.validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Minimal 6 karakter',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      validator: AppValidator.validatePhone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // Company Name Field
                    TextFormField(
                      controller: _companyNameController,
                      decoration: InputDecoration(
                        labelText: _selectedRole == 'client'
                            ? 'Nama Restoran'
                            : 'Nama Peternakan/Petani',
                        hintText: 'Masukkan nama usaha',
                        prefixIcon: const Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // City Field
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Kota',
                        hintText: 'Masukkan kota',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // Province Field
                    TextFormField(
                      controller: _provinceController,
                      decoration: const InputDecoration(
                        labelText: 'Provinsi',
                        hintText: 'Masukkan provinsi',
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      validator: AppValidator.validateAddress,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap',
                        hintText: 'Masukkan alamat lengkap',
                        prefixIcon: Icon(Icons.home),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppPadding.xxl),
                    // Register Button
                    CustomButton(
                      label: 'Daftar',
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                    ),
                    const SizedBox(height: AppPadding.lg),
                    // Error Message
                    if (authProvider.error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppPadding.md),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppTheme.errorColor),
                        ),
                        child: Text(
                          authProvider.error,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppPadding.lg),
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            color: AppTheme.textGray,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          child: const Text(
                            'Masuk di sini',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
        },
      ),
    );
  }
}
