import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/my_config.dart';

class DonationHistoryPage extends StatefulWidget {
  // Pass the logged-in user object to the page to identify who made the donations
  final User user;
  const DonationHistoryPage({super.key, required this.user});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  // List to hold donation records fetched from the database
  List donations = [];
  // Flag to track whether the app is currently fetching data from the server
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Start fetching data as soon as the screen is initialized
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation History"), 
        backgroundColor: Colors.orange
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Display spinner while loading
          : donations.isEmpty
              ? const Center(child: Text("No donations found.")) // Show message if list is empty
              : ListView.builder(
                  // Build a scrollable list of donation items
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    // Extract a single donation record at the current index
                    var d = donations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        // Logic for the leading icon: Money uses a dollar sign, others use a box icon
                        leading: Icon(
                          d['donation_type'] == 'Money' ? Icons.attach_money : Icons.inventory_2,
                          color: Colors.green,
                        ),
                        // Display the type of donation (Money, Food, or Medical) as the title
                        title: Text("${d['donation_type']} Donation"),
                        // Conditional display for the subtitle:
                        // If type is 'Money', show the RM amount; otherwise show the text description
                        subtitle: Text(d['donation_type'] == 'Money' 
                          ? "Amount: RM${d['amount']}" 
                          : "Details: ${d['description']}"),
                        // Extract and show only the date (YYYY-MM-DD) from the timestamp string
                        trailing: Text(d['date_donated'].toString().split(' ')[0]),
                      ),
                    );
                  },
                ),
    );
  }

  // Function to communicate with the backend PHP script
  void fetchHistory() {
    // Construct the GET URL using the server base URL and the current user's ID
    String url = "${MyConfig.baseUrl}/pawpal/api/load_donations.php?user_id=${widget.user.userId}";
    
    http.get(Uri.parse(url))
        .then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          setState(() {
            donations = data['data']; // Store the list of donations
            isLoading = false;        // Stop the loading spinner
          });
        } else {
          // If status is 'failed' (no data found), ensure list is empty and stop spinner
          setState(() {
            donations = [];
            isLoading = false;
          });
        }
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching donation history: $error");
    });
  }
}