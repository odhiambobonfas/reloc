import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/resident_model.dart';

class MoverDetailScreen extends StatelessWidget {
  final Map<String, dynamic> moverData;
  final ResidentModel resident;

  const MoverDetailScreen({
    super.key,
    required this.moverData,
    required this.resident,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navBar,
        title: const Text('Mover Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const Divider(color: Colors.white24, height: 30),
                _buildDetailRow('Service Area', moverData['serviceArea'] ?? 'N/A'),
                _buildDetailRow('Hourly Rate', 'KES ${moverData['rate']?.toStringAsFixed(0) ?? '0'}'),
                _buildDetailRow('Vehicle Type', moverData['vehicleType'] ?? 'N/A'),
                _buildDetailRow('Experience', '${moverData['experience'] ?? 'N/A'} years'),
                const SizedBox(height: 12),
                const Text(
                  'About',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (moverData['description'] != null && moverData['description'].isNotEmpty)
                      ? moverData['description']
                      : 'No description provided.',
                  style: const TextStyle(color: Colors.white60),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Messaging feature coming soon')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You hired ${moverData['name'] ?? 'the mover'}!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Hire Mover'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(
            (moverData['photoUrl'] != null && moverData['photoUrl'].isNotEmpty)
                ? moverData['photoUrl']
                : 'https://ui-avatars.com/api/?name=${moverData['name']}',
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              moverData['name'] ?? 'Mover',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              moverData['email'] ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}