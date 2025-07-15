
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.explore),
              title: const Text("Explore"),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Solution"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text("Heatmap"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Painindex"),
              onTap: () {},
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                // implement logout logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
