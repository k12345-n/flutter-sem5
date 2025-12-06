class MyPet{
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? petCategory;
  String? petDescription;
  String? petLat;
  String? petLng;
  String? petImagePaths;
  String? createdAt;
  String? userName;
  String? userEmail;

  MyPet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.petCategory,
    this.petDescription,
    this.petLat,
    this.petLng,
    this.petImagePaths,
    this.createdAt,
    this.userName,
    this.userEmail,
  });

  MyPet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    petCategory = json['category'];
    petDescription = json['description'];
    petLat = json['lat'];
    petLng = json['lng'];
    petImagePaths = json['image_paths'];
    createdAt = json['created_at'];

    userName = json['user_name'];
    userEmail = json['user_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = petCategory;
    data['description'] = petDescription;
    data['lat'] = petLat;
    data['lng'] = petLng;
    data['image_paths'] = petImagePaths;
    data['created_at'] = createdAt;

    data['user_name'] = userName;
    data['user_email'] = userEmail;

    return data;
  }
}