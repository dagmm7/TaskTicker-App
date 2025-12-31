import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_ticker_app/services/hive_service.dart';
import 'package:task_ticker_app/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  UserModel? _user;
  String? _profilePicturePath;
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;

  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
  final RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final email = HiveService.getCurrentUserEmail();
    if (email != null) {
      setState(() {
        _user = HiveService.getUser(email);
        if (_user != null) {
          _nameController.text = _user!.fullName;
          _emailController.text = _user!.email;
          _profilePicturePath = _user!.profilePicturePath;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 85,
    );

    if (image != null) {
      // Save image to app directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'profile_${_user!.email}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${appDir.path}/$fileName';
      
      final File imageFile = File(image.path);
      await imageFile.copy(filePath);

      setState(() {
        _profilePicturePath = filePath;
      });

      // Save to Hive
      await HiveService.updateUserProfilePicture(_user!.email, filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!nameRegex.hasMatch(_nameController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name can only contain letters and spaces'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Capitalize name properly
    String capitalizedName = _nameController.text.trim();
    if (capitalizedName.isNotEmpty) {
      capitalizedName = capitalizedName
          .split(' ')
          .map((word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '')
          .join(' ')
          .trim();
    }
    await HiveService.updateUserName(_user!.email, capitalizedName);
    setState(() {
      _isEditingName = false;
    });
    _loadUserData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newEmail = _emailController.text.trim();
    
    if (newEmail == _user!.email) {
      setState(() {
        _isEditingEmail = false;
      });
      return;
    }

    if (HiveService.userExists(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email already registered'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await HiveService.updateUserEmail(_user!.email, newEmail);
    setState(() {
      _isEditingEmail = false;
    });
    _loadUserData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your current password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weak password. Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if password has letters, numbers, and symbols
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(_newPasswordController.text);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(_newPasswordController.text);
    final hasSymbols = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text);
    
    if (!hasLetters || !hasNumbers || !hasSymbols) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weak password. Password must contain letters, numbers, and symbols.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await HiveService.updateUserPassword(
      _user!.email,
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      setState(() {
        _isChangingPassword = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current password is incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF4A90E2),
                      backgroundImage: _profilePicturePath != null && File(_profilePicturePath!).existsSync()
                          ? FileImage(File(_profilePicturePath!))
                          : null,
                      child: _profilePicturePath == null || !File(_profilePicturePath!).existsSync()
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A90E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Upload Photo'),
              ),
              
              const SizedBox(height: 30),
              
              // Name Field
              _buildEditableField(
                label: 'Name',
                controller: _nameController,
                isEditing: _isEditingName,
                onEdit: () => setState(() => _isEditingName = true),
                onSave: _saveName,
                onCancel: () {
                  _nameController.text = _user!.fullName;
                  setState(() => _isEditingName = false);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (!nameRegex.hasMatch(value.trim())) {
                    return 'Name can only contain letters and spaces';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              
              const SizedBox(height: 20),
              
              // Email Field
              _buildEditableField(
                label: 'Email',
                controller: _emailController,
                isEditing: _isEditingEmail,
                onEdit: () => setState(() => _isEditingEmail = true),
                onSave: _saveEmail,
                onCancel: () {
                  _emailController.text = _user!.email;
                  setState(() => _isEditingEmail = false);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Email must include @gmail.com';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 30),
              
              // Password Section
              if (!_isChangingPassword)
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isChangingPassword = true),
                  icon: const Icon(Icons.lock),
                  label: const Text('Change Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                        helperText: 'Minimum 6 characters, must contain letters, numbers, and symbols',
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _currentPasswordController.clear();
                              _newPasswordController.clear();
                              setState(() => _isChangingPassword = false);
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onCancel,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (!isEditing)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
                color: const Color(0xFF4A90E2),
              )
            else
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: onSave,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onCancel,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEditing,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: isEditing ? Colors.white : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}

