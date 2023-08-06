class UserModel {
  String? uid;
  String name;
  String email;
  String password;
  String? urlImage;

  UserModel(this.name, this.email, this.password, this.urlImage);

  UserModel.withId(
      this.uid, this.name, this.email, this.password, this.urlImage);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "name": name,
      "email": email,
    };
    return map;
  }
}
