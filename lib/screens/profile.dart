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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Container(),
    );
  }
}