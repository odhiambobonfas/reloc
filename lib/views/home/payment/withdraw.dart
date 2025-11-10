import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ To get Firebase UID
import 'package:reloc/core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  final ApiClient _apiClient = ApiClient();

  Future<void> initiateWithdraw() async {
    final double? amount = double.tryParse(_amountController.text.trim());
    final String phone = _phoneController.text.trim();
    final String? userId = FirebaseAuth.instance.currentUser?.uid; // ✅ Firebase UID

    if (userId == null) {
      setState(() {
        _message = "You must be logged in first.";
      });
      return;
    }

    if (amount == null || amount <= 0 || phone.isEmpty) {
      setState(() {
        _message = "Enter a valid amount and phone number.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await _apiClient.post('/mpesa/withdraw', {
        "userId": userId, // ✅ Logged-in user making the withdrawal
        "amount": amount,
        "phone": phone, // ✅ Must be in 2547XXXXXXXX format
      });

      if (response['success'] == true) {
        setState(() {
          _message = response["message"] ?? "Withdrawal initiated successfully!";
        });
      } else {
        setState(() {
          _message = response["message"] ?? response['error'] ?? "Failed to initiate withdrawal.";
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
        title: const Text("Withdraw Funds", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Withdrawal Amount",
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
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : initiateWithdraw,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Withdraw Now",
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
                    color: _message!.toLowerCase().contains("success")
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
