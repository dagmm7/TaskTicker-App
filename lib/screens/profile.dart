import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String imageUrl;

  ProfilePage({
    required this.initialName,
    required this.initialEmail,
    required this.imageUrl,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String username;
  late String email;
  bool isEditingName = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

@override
  void initState() {
    super.initState();
    username = widget.initialName;
    email = widget.initialEmail;
    _nameController.text = username;
    _emailController.text = email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

