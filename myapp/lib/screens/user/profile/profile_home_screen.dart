// lib/screens/user/profile/profile_home_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selfiePath;
  bool _isEditing = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Initialize with user data
    _nameController = TextEditingController(text: 'Nikhil Sahni');
    _emailController = TextEditingController(text: 'nikhil@example.com');
    _phoneController = TextEditingController(text: '+91 98765 43210');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selfiePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: AppColors.text,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Reset controllers to original values
                  _nameController.text = 'Nikhil Sahni';
                  _emailController.text = 'nikhil@example.com';
                  _phoneController.text = '+91 98765 43210';
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildProfileDetails(),
              const SizedBox(height: 24),
              _buildSettings(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.surface,
              backgroundImage:
                  _selfiePath != null ? FileImage(File(_selfiePath!)) : null,
              child: _selfiePath == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileField(
              'Full Name',
              Icons.person_outline,
              _nameController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              'Phone Number',
              Icons.phone_outlined,
              _phoneController,
              enabled: false,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              'Email',
              Icons.email_outlined,
              _emailController,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.caption),
        labelText: label,
        labelStyle: TextStyle(color: AppColors.caption),
        filled: true,
        fillColor: AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: enabled ? AppColors.primary : AppColors.border,
            width: enabled ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      validator: (value) {
        if (label == 'Full Name' && (value == null || value.isEmpty)) {
          return 'Please enter your name';
        }
        if (label == 'Email' && (value == null || value.isEmpty)) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  Widget _buildSettings() {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Column(
        children: [
          _buildSettingTile(
            'Notifications',
            Icons.notifications_outlined,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _isEditing
                  ? (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    }
                  : null,
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingTile(
            'Privacy',
            Icons.lock_outline,
            onTap: _isEditing
                ? () {
                    // Handle privacy settings
                  }
                : null,
            trailing: _isEditing
                ? const Icon(Icons.chevron_right, color: AppColors.caption)
                : null,
          ),
          _buildSettingTile(
            'Help & Support',
            Icons.help_outline,
            onTap: _isEditing
                ? () {
                    // Handle help & support
                  }
                : null,
            trailing: _isEditing
                ? const Icon(Icons.chevron_right, color: AppColors.caption)
                : null,
          ),
          _buildSettingTile(
            'About',
            Icons.info_outline,
            onTap: _isEditing
                ? () {
                    // Handle about section
                  }
                : null,
            trailing: _isEditing
                ? const Icon(Icons.chevron_right, color: AppColors.caption)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String label,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.caption),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      trailing: trailing ??
          (_isEditing
              ? const Icon(Icons.chevron_right, color: AppColors.caption)
              : null),
      onTap: onTap,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isEditing)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save changes
                  setState(() {
                    _isEditing = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Logout user
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
