import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ To get Firebase UID
import 'package:reloc/core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  final ApiClient _apiClient = ApiClient();

  Future<void> initiateMpesaDeposit() async {
    final double? amount = double.tryParse(_amountController.text.trim());
    final String phone = _phoneController.text.trim();
    final String? userId = FirebaseAuth.instance.currentUser?.uid; // ✅ Get UID

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
      final response = await _apiClient.post('/mpesa/deposit', {
        "userId": userId,
        "amount": amount,
        "phone": phone, // ✅ Must be in 2547XXXXXXXX format
      });

      if (response['success'] == true) {
        setState(() {
          _message = response["message"] ??
              "STK Push sent. Check your phone to complete payment.";
        });
      } else {
        setState(() {
          _message = response["message"] ?? response['error'] ?? "Failed to initiate deposit.";
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
        title: const Text("Deposit via M-Pesa", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter Amount",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "e.g. 500",
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

            const Text("M-Pesa Phone Number",
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
                onPressed: _isLoading ? null : initiateMpesaDeposit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Deposit Now",
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
                    color: _message!.toLowerCase().contains("stk")
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
