import 'dart:ui';

import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final Color cardColor;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
     this.cardColor= Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Main container
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(width: 40), // Space for the icon
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(message),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Blurred gradient effect
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Container(
                width: 20,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.2),
                    ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(color: color.withOpacity(0.2)),
                ),
              ),
            ),
          ),
          // Icon
          Positioned(
            left: 16,
            top: 16,
            child: Icon(icon, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

// Usage example
class TransactionHistoryPage extends StatelessWidget {
  TransactionHistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            NotificationCard(
              title: "Information",
              message: "Anyone with a link can now view this file.",
              color: Colors.blue,
              icon: Icons.info_outline,
            ),
            NotificationCard(
              title: "Success",
              message: "Anyone with a link can now view this file.",
              color: Colors.green,
              icon: Icons.check_circle_outline,
            ),
            NotificationCard(
              title: "Warning",
              message: "Anyone with a link can now view this file.",
              color: Colors.orange,
              icon: Icons.warning_amber_rounded,
            ),
            NotificationCard(
              title: "Error",
              message: "Anyone with a link can now view this file.",
              color: Colors.red,
              icon: Icons.error_outline,
            ),
          ],
        ),
      ),
    );
  }
}