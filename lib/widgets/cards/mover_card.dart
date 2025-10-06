import 'package:flutter/material.dart';

class MoverCard extends StatelessWidget {
  final String name;
  final String serviceArea;
  final String rate;
  final String? photoUrl;
  final VoidCallback onTap;

  const MoverCard({
    super.key,
    required this.name,
    required this.serviceArea,
    required this.rate,
    required this.onTap,
    this.photoUrl,
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
              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Area: $serviceArea\nRate: \$$rate/hr'),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
