import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/my_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  // Pass the current User object to pre-fill the form with existing data
  final User user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers to manage and retrieve text input for Name and Phone
  late TextEditingController nameController, phoneController;
  // File variable to hold the new image if the user selects one from the gallery
  File? _image;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user data so the user doesn't have to re-type everything
    nameController = TextEditingController(text: widget.user.userName);
    phoneController = TextEditingController(text: widget.user.userPhone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Image Selection Section
            GestureDetector(
              onTap: _selectImage, // Opens the gallery when the avatar is tapped
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[300],
                // Logic: Show the newly selected local file if it exists; 
                // otherwise, fetch the current profile image from the server
                backgroundImage: _image != null 
                    ? FileImage(_image!) 
                    : NetworkImage("${MyConfig.baseUrl}/pawpal/assets/profile/${widget.user.profileImage}") as ImageProvider,
                child: const Icon(Icons.camera_alt, color: Colors.white70, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            // Edit field for the user's name
            TextField(
              controller: nameController, 
              decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder())
            ),
            const SizedBox(height: 10),
            // Edit field for the phone number with numeric keyboard optimization
            TextField(
              controller: phoneController, 
              keyboardType: TextInputType.phone, 
              decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder())
            ),
            const SizedBox(height: 20),
            // Button to trigger the update process
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, 
                foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 50)
              ),
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }

  // Uses the image_picker package to allow users to pick a photo from their phone gallery
  Future<void> _selectImage() async {
    final picker = ImagePicker(); 
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    // If a file was picked, update the UI to show the new local image preview
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  // Function to send updated data (Text + Base64 Image) to the PHP backend
  Future<void> _updateProfile() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    
    // If a new image was selected, convert the physical file into a Base64 string for network transfer
    String? base64Image = _image != null ? base64Encode(_image!.readAsBytesSync()) : null;

    // Basic validation to ensure required text fields are not empty
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fields cannot be empty"), backgroundColor: Colors.red)
      );
      return;
    }

    // Send a POST request to the update_profile.php script
    http.post(
      Uri.parse("${MyConfig.baseUrl}/pawpal/api/update_profile.php"),
      body: {
        "user_id": widget.user.userId,
        "name": name,
        "phone": phone,
        "image": base64Image ?? "", 
      },
    ).then((response) {
      var data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        widget.user.userName = name;
        widget.user.userPhone = phone;
        if (data['new_image'] != "") widget.user.profileImage = data['new_image'];

        // Update the persistent storage (SharedPreferences) so changes remain after app restart
        _saveSession(widget.user);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated!"))
        );
        // Return the updated User object back to the previous screen (Homepage)
        Navigator.pop(context, widget.user);
      }
    });
  }

  Future<void> _saveSession(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    prefs.setString('userData', jsonEncode(user.toJson()));
  }
}