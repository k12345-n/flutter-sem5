class User {
  String? userId;
  String? userEmail;
  String? userName;
  String? userPhone;
  String? userPassword;
  String? userRegdate;
  String? profileImage; 

  User({
    this.userId,
    this.userEmail,
    this.userName,
    this.userPhone,
    this.userPassword,
    this.userRegdate,
    this.profileImage,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userEmail = json['email'];
    userName = json['name'];
    userPhone = json['phone'];
    userPassword = json['password'];
    userRegdate = json['reg_date'];
    profileImage = json['profile_image']; 
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['email'] = userEmail;
    data['name'] = userName;
    data['phone'] = userPhone;
    data['password'] = userPassword;
    data['reg_date'] = userRegdate;
    data['profile_image'] = profileImage;
    return data;
  }
}