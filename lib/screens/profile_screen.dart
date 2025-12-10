import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            Text(user?.name ?? "Guest", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user?.email ?? "-", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 10),
            Chip(
              label: Text(user?.role.toUpperCase() ?? "USER"),
              backgroundColor: user?.role == 'admin' ? Colors.orange : Colors.blue[100],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                 Navigator.pop(context); 
                 Provider.of<AuthProvider>(context, listen: false).logout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("LOGOUT"),
            )
          ],
        ),
      ),
    );
  }
}
