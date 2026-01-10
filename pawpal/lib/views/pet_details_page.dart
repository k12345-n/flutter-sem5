import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/my_config.dart';
import 'package:pawpal/views/paymentpage.dart';

class PetDetailsPage extends StatefulWidget {
  // Receives specific pet data and the logged-in user object from the Homepage
  final Map pet;
  final User user;

  const PetDetailsPage({super.key, required this.pet, required this.user});

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  // Controller to handle text input for the user
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Splits the comma-separated image string from the database into a list of individual filenames
    List<String> images = widget.pet['image_paths'].toString().split(',');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet['pet_name']), 
        backgroundColor: Colors.orange
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Uses a ListView.builder with horizontal scroll to allow viewing multiple pet photos
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Image.network(
                      "${MyConfig.baseUrl}/pawpal/assets/pets/${images[index]}",
                      fit: BoxFit.cover,
                      // Fallback icon if the network image fails to load
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.pets, size: 100, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            // Helpful text hint shown only if the pet has multiple images
            if (images.length > 1)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Swipe to see more photos (${images.length})",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task 2: Displaying full pet details
                  Text(
                    widget.pet['pet_name'], 
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
                  ),
                  const Divider(),
                  
                  // display detail
                  _detailRow("Gender", widget.pet['gender'] ?? 'Unknown'),
                  _detailRow("Age", "${widget.pet['pet_age'] ?? 'N/A'} years"),
                  _detailRow("Health", widget.pet['health_status'] ?? 'Healthy'),
                  _detailRow("Posted By", widget.pet['user_name'] ?? 'User'),
                  
                  const SizedBox(height: 10),
                  _detailRow("Type", widget.pet['pet_type']),
                  _detailRow("Category", widget.pet['category']),
                  
                  const SizedBox(height: 15),
                  const Text(
                    "Description:", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  Text(
                    widget.pet['description'] ?? 'No description provided.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Task 2 & 3: Conditional buttons based on the pet's category
                  Row(
                    children: [
                      // Show "Request to Adopt" only if the pet is listed for Adoption
                      if (widget.pet['category'] == 'Adoption')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showAdoptionForm,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            child: const Text("Request to Adopt", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      
                      // Show "Donate" only for pets needing medical help or food donations
                      if (widget.pet['category'] == 'Donation Request' || widget.pet['category'] == 'Help')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showDonationDialog,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                            child: const Text("Donate", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget to display a bold label next to its corresponding value
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Task 2: Displays a popup form to collect the user's adoption motivation message
  void _showAdoptionForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adoption Request"),
        content: TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter motivation...", 
            border: OutlineInputBorder()
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: _submitAdoptionRequest, 
            child: const Text("Submit")
          ),
        ],
      ),
    );
  }

  // Task 2: Sends the adoption request data to the PHP backend
  void _submitAdoptionRequest() {
    // Client-side validation: Ensure the motivation message is not empty
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Motivation required"))
      );
      return;
    }
    
    // HTTP POST to insert record into tbl_adoptions
    http.post(
      Uri.parse("${MyConfig.baseUrl}/pawpal/api/insert_adoption.php"),
      body: {
        "pet_id": widget.pet['pet_id'].toString(),
        "user_id": widget.user.userId.toString(),
        "message": _messageController.text.trim(),
      },
    ).then((response) {
      if (jsonDecode(response.body)['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request Sent!"))
        );
        Navigator.pop(context); // Close the dialog upon success
      }
    });
  }

  // Task 3: Displays the donation options dialog (Money, Food, or Medical)
  void _showDonationDialog() {
    String selectedType = "Money";
    TextEditingController amountController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // StatefulBuilder allows refreshing the dialog UI when the dropdown changes
        builder: (context, setState) => AlertDialog(
          title: const Text("Make a Donation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown to select donation category
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: "Type", 
                  border: OutlineInputBorder()
                ),
                items: ["Money", "Food", "Medical"].map((type) => 
                  DropdownMenuItem(value: type, child: Text(type))
                ).toList(),
                onChanged: (value) => setState(() => selectedType = value!),
              ),
              const SizedBox(height: 10),
              // Dynamic UI: Shows amount field for Money, description for others
              if (selectedType == "Money")
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount (RM)", 
                    border: OutlineInputBorder()
                  ),
                )
              else
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: "$selectedType Details", 
                    border: OutlineInputBorder()
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel")
            ),
            ElevatedButton(
              onPressed: () => _submitDonation(selectedType, amountController.text, descController.text),
              child: const Text("Donate"),
            ),
          ],
        ),
      ),
    );
  }

  // Task 3: Handles the initial logic of choosing between Payment Page or direct database insert
  void _submitDonation(String type, String amount, String desc) {
    // Validation: Check that the appropriate field is filled based on type
    if ((type == "Money" && amount.isEmpty) || (type != "Money" && desc.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in fields"))
      );
      return;
    }

    Navigator.pop(context); // Close the dialog

    if (type == "Money") {
      // For Money: Navigate to the web-based Billplz payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            user: widget.user,
            petId: widget.pet['pet_id'].toString(),
            amount: amount,
          ),
        ),
      ).then((_) {
        // Hint to user to check history after returning from the payment portal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please check your donation history to confirm payment status"),
            backgroundColor: Colors.blue,
          ),
        );
      });
    } else {
      // For Food/Medical: Submit data directly to the database via PHP
      _submitNonMoneyDonation(type, desc);
    }
  }

  // Task 3: API call for physical donations (Food/Medical) modified for updated tbl_donations schema
  Future<void> _submitNonMoneyDonation(String type, String desc) async {
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.baseUrl}/pawpal/api/insert_donation.php"),
        body: {
          "user_id": widget.user.userId.toString(),
          "pet_id": widget.pet['pet_id'].toString(),
          "type": type,
          "amount": "0", // Default amount is zero for non-monetary donations
          "description": desc,
          "bill_id": "NULL", // New column: Physical donations do not have a Billplz ID
          "payment_status": "completed", // New column: Default to completed for physical items
        },
      );

      if (jsonDecode(response.body)['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Donation Successful!"),
            backgroundColor: Colors.green,
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Donation failed. Please try again."),
            backgroundColor: Colors.red,
          )
        );
      }
    } catch (e) {
      // Error handling for network connectivity issues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        )
      );
    }
  }
}