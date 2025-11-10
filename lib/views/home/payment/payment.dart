import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ To get Firebase UID
import 'package:reloc/core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  final ApiClient _apiClient = ApiClient();

  Future<void> initiatePayment() async {
    final double? amount = double.tryParse(_amountController.text.trim());
    final String phone = _phoneController.text.trim();
    final String recipient = _recipientController.text.trim();
    final String? userId = FirebaseAuth.instance.currentUser?.uid; // ✅ Get UID

    if (userId == null) {
      setState(() {
        _message = "You must be logged in first.";
      });
      return;
    }

    if (amount == null || amount <= 0 || phone.isEmpty || recipient.isEmpty) {
      setState(() {
        _message = "Enter valid details (amount, phone, and recipient).";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await _apiClient.post('/mpesa/payment', {
        "userId": userId, // ✅ Current logged-in user
        "recipientId": recipient, // ✅ Could be another user’s UID or email
        "amount": amount,
        "phone": phone, // ✅ Must be in 2547XXXXXXXX format
      });

      if (response['success'] == true) {
        setState(() {
          _message = response["message"] ??
              "Payment request sent! Check your M-Pesa phone to complete.";
        });
      } else {
        setState(() {
          _message = response["message"] ?? response['error'] ?? "Failed to initiate payment.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Something went wrong: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Make a Payment", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recipient (User ID or Email)",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _recipientController,
              decoration: InputDecoration(
                hintText: "e.g. recipient_user_id",
                filled: true,
                fillColor: Colors.white10,
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            const Text("Amount",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "e.g. 1000",
                filled: true,
                fillColor: Colors.white10,
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            const Text("Your M-Pesa Phone Number",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "e.g. 254712345678",
                filled: true,
                fillColor: Colors.white10,
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : initiatePayment,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Pay Now",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),

            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                    color: _message!.toLowerCase().contains("payment request")
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
