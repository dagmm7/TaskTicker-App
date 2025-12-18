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

  void saveName() {
    setState(() {
      username = _nameController.text.trim();
      isEditingName = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

