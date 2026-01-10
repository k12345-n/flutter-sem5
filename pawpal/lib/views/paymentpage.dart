import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart'; //
import 'package:pawpal/my_config.dart';   //
import 'package:webview_flutter/webview_flutter.dart'; //

class PaymentPage extends StatefulWidget {
  final User user;
  final String amount; 
  final String petId;  // Needed for your tbl_donations

  const PaymentPage({super.key, required this.user, required this.amount, required this.petId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late WebViewController _webcontroller;

  @override
  void initState() {
    super.initState();
    
    // Convert variables to strings
    String userEmail = widget.user.userEmail.toString();
    String userPhone = widget.user.userPhone.toString();
    String userName = widget.user.userName.toString();
    String userID = widget.user.userId.toString();

    // Initialize the controller and load the URL
    _webcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          // Path changed to your pawpal API
          '${MyConfig.baseUrl}/pawpal/api/billplz_payment.php?email=$userEmail&phone=$userPhone&userid=$userID&name=$userName&amount=${widget.amount}&petid=${widget.petId}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.orange, 
      ),
      // Displays the payment gateway inside the app
      body: WebViewWidget(controller: _webcontroller),
    );
  }
}