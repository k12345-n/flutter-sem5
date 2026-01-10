import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/my_config.dart';
import 'package:pawpal/views/pet_details_page.dart';
import 'package:pawpal/views/submitpetpage.dart';
import 'package:pawpal/views/edit_profile_page.dart'; 
import 'package:pawpal/views/donation_history_page.dart';
import 'package:pawpal/views/loginpage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  final User user;
  const Homepage({super.key, required this.user});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // List to store pet data fetched from the server.
  List pets = [];
  String status = "Loading...";
  TextEditingController searchController = TextEditingController();
  
  // Dropdown variables for pet type filtering.
  String selectedType = "All";
  List<String> petTypes = ["All", "Dogs", "Cat", "Rabbit"];

  @override
  void initState() {
    super.initState();
    // Load public pet data immediately when the app starts.
    loadPublicPets(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPal Homepage'),
        backgroundColor: Colors.orange,
      ),
      // Side menu containing user profile information and navigation links.
      drawer: Drawer(
        child: Column(
          children: [
            // Header showing the user's name, email, and profile picture.
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              // Use the null-aware operator (??) to show "User" if name is missing.
              accountName: Text(widget.user.userName ?? "User"),
              accountEmail: Text(widget.user.userEmail ?? "Email"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                // Logic: Loads user photo from server if it exists, otherwise falls back to a local asset.
                backgroundImage: widget.user.profileImage != null && widget.user.profileImage != 'default_user.png'
                    ? NetworkImage("${MyConfig.baseUrl}/pawpal/assets/profile/${widget.user.profileImage}")
                    : const AssetImage('assets/images/profile.png') as ImageProvider,
              ),
            ),
            // Tile showing the user's phone number.
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(widget.user.userPhone ?? "No Phone Number"),
            ),
            const Divider(),
            // Navigation to the Edit Profile screen.
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Edit Profile"),
              onTap: () async {
                Navigator.pop(context); // Close the drawer first. Go to Edit Profile Page.
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage(user: widget.user)),
                );
                if (updatedUser != null) {
                  setState(() {}); 
                }
              },
            ),
            // Navigation to the Donation History screen.
            ListTile(
              leading: const Icon(Icons.history, color: Colors.green),
              title: const Text("Donation History"),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonationHistoryPage(user: widget.user)),
                );
              },
            ),
            const Spacer(), // Pushes logout button to the bottom.
            const Divider(),
            // Logout action.
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: _logoutDialog,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Column(
        children: [
          // Task 1: Search bar and Dropdown button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Search Input.
                Expanded(
                  flex: 6,
                  child: TextFormField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search pet name...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    // Automatically re-fetch pets whenever text changes.
                    onChanged: (value) => loadPublicPets(), 
                  ),
                ),
                const SizedBox(width: 8),
                // Filter Dropdown.
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: petTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        loadPublicPets(); // Re-fetch based on selected type.
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Pet List Display.
          Expanded(
            child: pets.isEmpty
                ? Center(child: Text(status, style: const TextStyle(fontSize: 18)))
                : ListView.builder(
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      // Grabs the first image filename from a comma-separated string (e.g., "img1.png,img2.png").
                      String firstImage = pets[index]['image_paths'].toString().split(',')[0];
                      
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            // Task 2: Navigate to Pet Details when a card is tapped.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetDetailsPage(pet: pets[index], user: widget.user),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Displays the pet image from the server.
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                child: Image.network(
                                  "${MyConfig.baseUrl}/pawpal/assets/pets/$firstImage",
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  // Shows a generic icon if the network image fails to load.
                                  errorBuilder: (context, error, stackTrace) => 
                                      Container(height: 200, color: Colors.grey, child: const Icon(Icons.pets, size: 50)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Displays the pet name.
                                    Text(
                                      pets[index]['pet_name'],
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    // Displays Type and Age in a row.
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Type: ${pets[index]['pet_type']}"),
                                        Text("Age: ${pets[index]['pet_age'] ?? 'N/A'} years"),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Highlights the category (e.g., Adoption, Help, Donation).
                                    Text(
                                      "Category: ${pets[index]['category']}",
                                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Button to navigate to the Add Pet screen.
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitPetScreen(user: widget.user)));
          loadPublicPets(); // Refresh the list after adding a new pet.
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void loadPublicPets() {
    setState(() => status = "Loading...");
    String search = searchController.text;
    String url = "${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?search=$search&type=$selectedType";

    http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body); 
        if (data['status'] == 'success') {
          setState(() {
            pets = data['data']; // Store the list of pets found.
          });
        } else {
          // If no pets match the filters.
          setState(() {
            pets = [];
            status = "No pets found.";
          });
        }
      }
    }).catchError((error) {
      setState(() => status = "Error: $error");
    });
  }

  // Confirmation dialog for logging out.
  void _logoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Clear the saved user session data from the device.
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('userData'); 
                await prefs.setBool('rememberMe', false); 
                
                if (!mounted) return;
                // Redirect to Login Page and remove all previous screens from the stack.
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false, 
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}