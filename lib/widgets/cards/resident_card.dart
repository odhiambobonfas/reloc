import 'package:flutter/material.dart';

class ResidentCard extends StatelessWidget {
  final String name;
  final String location;
  final String movingDate;
  final String budget;
  final String? photoUrl;
  final VoidCallback onTap;

  const ResidentCard({
    super.key,
    required this.name,
    required this.location,
    required this.movingDate,
    required this.budget,
    this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: photoUrl != null
              ? NetworkImage(photoUrl!)
              : AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Location: $location\nDate: $movingDate\nBudget: \$$budget'),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
