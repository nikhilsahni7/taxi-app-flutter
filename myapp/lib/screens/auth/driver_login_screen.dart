// lib/screens/auth/driver_login_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/app_colors.dart';
import '../../models/vehicle_category.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Text Controllers
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _dlController = TextEditingController();
  final _carNumberController = TextEditingController();
  final _carNameController = TextEditingController();

  // Document paths
  String? _selfiePath;
  String? _drivingLicensePath;
  String? _rcPermitPath1;
  String? _rcPermitPath2;
  String? _fitnessPaperPath;
  String? _insurancePaperPath;
  String? _pollutionPaperPath;
  String? _carFrontPath;
  String? _carBackPath;

  String? _selectedCategory;
  bool _isLoading = false;

  final List<VehicleCategory> _categories = [
    const VehicleCategory(
      name: 'Mini',
      description: 'Compact cars for city rides',
      image: 'assets/images/mini.png',
    ),
    const VehicleCategory(
      name: 'Sedan',
      description: 'Comfortable sedans for longer trips',
      image: 'assets/images/sedan.png',
    ),
    const VehicleCategory(
      name: 'SUV',
      description: 'Spacious SUVs for group travel',
      image: 'assets/images/suv.png',
    ),
    const VehicleCategory(
      name: 'Tempo 12',
      description: '12 seater traveller',
      image: 'assets/images/tempo12.png',
    ),
    const VehicleCategory(
      name: 'Tempo 17',
      description: '17 seater traveller',
      image: 'assets/images/tempo17.png',
    ),
  ];

  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          switch (type) {
            case 'selfie':
              _selfiePath = image.path;
              break;
            case 'license':
              _drivingLicensePath = image.path;
              break;
            case 'rcPermit1':
              _rcPermitPath1 = image.path;
              break;
            case 'rcPermit2':
              _rcPermitPath2 = image.path;
              break;
            case 'fitness':
              _fitnessPaperPath = image.path;
              break;
            case 'insurance':
              _insurancePaperPath = image.path;
              break;
            case 'pollution':
              _pollutionPaperPath = image.path;
              break;
            case 'carFront':
              _carFrontPath = image.path;
              break;
            case 'carBack':
              _carBackPath = image.path;
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Driver Registration',
          style: TextStyle(color: AppColors.text),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Details Section
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter your phone number',
                icon: Icons.phone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person,
                controller: _nameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Document Section
              const Text(
                'Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              _buildDocumentUpload('Live Selfie', 'selfie', _selfiePath),
              const SizedBox(height: 12),
              _buildDocumentUpload(
                  'Driving License', 'license', _drivingLicensePath),
              const SizedBox(height: 12),
              _buildDocumentUpload(
                  'RC Permit (1)', 'rcPermit1', _rcPermitPath1),
              const SizedBox(height: 12),
              _buildDocumentUpload(
                  'RC Permit (2)', 'rcPermit2', _rcPermitPath2),
              const SizedBox(height: 12),
              _buildDocumentUpload(
                  'Fitness Paper', 'fitness', _fitnessPaperPath),
              const SizedBox(height: 12),
              _buildDocumentUpload(
                  'Insurance Paper', 'insurance', _insurancePaperPath),
              const SizedBox(height: 12),
              _buildDocumentUpload(
                  'Pollution Paper', 'pollution', _pollutionPaperPath),
              const SizedBox(height: 20),

              // Vehicle Details Section
              const Text(
                'Vehicle Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category.name == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category.name;
                        });
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.text,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.text,
                              ),
                            ),
                            Text(
                              category.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.caption,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Vehicle Number',
                hint: 'Enter vehicle registration number',
                icon: Icons.car_rental,
                controller: _carNumberController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: "Vechile Name",
                hint: "Enter Vechile Name eg: Wagnor,fortuner ",
                icon: Icons.car_rental_outlined,
                controller: _carNameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildDocumentUpload(
                  'Vehicle Front Photo', 'carFront', _carFrontPath),
              const SizedBox(height: 12),
              _buildDocumentUpload(
                  'Vehicle Back Photo', 'carBack', _carBackPath),
              const SizedBox(height: 32),

              // Submit Button
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Registration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(String title, String type, String? path) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title *',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.upload_file, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  path ?? 'No file chosen',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: () => _pickImage(type),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Choose File'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Validate required documents
      if (_selfiePath == null ||
          _drivingLicensePath == null ||
          _rcPermitPath1 == null ||
          _rcPermitPath2 == null ||
          _fitnessPaperPath == null ||
          _insurancePaperPath == null ||
          _pollutionPaperPath == null ||
          _carFrontPath == null ||
          _carBackPath == null ||
          _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload all required documents')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }
  }
}
