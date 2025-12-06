import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/views/loginpage.dart';
import 'package:pawpal/my_config.dart';
import 'package:pawpal/views/submitpetpage.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  final User user;
  const Homepage({super.key, required this.user});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List pets = [];
  late double screenWidth, screenHeight;
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadMyPets();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > 600) {
      screenWidth = 600;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPal Homepage'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () {
              loadMyPets();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth,
          child: pets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pets, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Get the first image from image_paths
                    String? firstImage;
                    if (pets[index]['image_paths'] != null &&
                        pets[index]['image_paths'].toString().isNotEmpty) {
                      List<String> imagePaths =
                          pets[index]['image_paths'].toString().split(',');
                      if (imagePaths.isNotEmpty) {
                        firstImage = imagePaths[0].trim();
                      }
                    }

                    // Create description excerpt
                    String description =
                        pets[index]['description'] ?? 'No description';
                    String descriptionExcerpt = description.length > 100
                        ? '${description.substring(0, 100)}...'
                        : description;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Optional: show details
                          // showPetDetails(index);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pet thumbnail image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: firstImage != null
                                  ? Image.network(
                                      "${MyConfig.baseUrl}/pawpal/assets/pets/$firstImage",
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.pets,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.pets,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),

                            // Pet information
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pet name
                                  Text(
                                    pets[index]['pet_name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Type and Category row
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          pets[index]['pet_type'] ?? 'Unknown',
                                          style: TextStyle(
                                            color: Colors.orange[800],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          pets[index]['category'] ?? 'Unknown',
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Description excerpt
                                  Text(
                                    descriptionExcerpt,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmitPetScreen(
                user: widget.user,
              ),
            ),
          );
          // Reload pets after submission
          loadMyPets();
        },
        label: const Text('Submit Pet'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void loadMyPets() {
    pets.clear();
    setState(() {
      status = "Loading...";
    });

    http.get(
      Uri.parse("${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?user_id=${widget.user.userId}"),
    ).then((response) {
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null &&
            jsonResponse['data'].isNotEmpty) {
          pets.clear();
          for (var item in jsonResponse['data']) {
            pets.add(item);
          }
          setState(() {
            status = "";
          });
        } else {
          // Success but EMPTY data
          setState(() {
            pets.clear();
            status = "No submissions yet.";
          });
        }
      } else {
        // Request failed
        setState(() {
          pets.clear();
          status = "Failed to load pets";
        });
      }
    }).catchError((error) {
      setState(() {
        pets.clear();
        status = "Error: ${error.toString()}";
      });
    });
  }
}