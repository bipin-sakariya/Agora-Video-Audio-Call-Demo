class UserModel {
  String multicast_id;
  String success;
  String failure;
  String canonical_ids;
  List<Results> results;

  UserModel(
      {this.multicast_id,
      this.success,
      this.failure,
      this.canonical_ids,
      this.results});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var data = json['results'] as List;
    List<Results> resultList = data.map((e) => Results.fromJson(e)).toList();

    return UserModel(
      multicast_id: json['multicast_id'].toString(),
      success: json['success'].toString(),
      failure: json['failure'].toString(),
      canonical_ids: json['canonical_ids'].toString(),
      results: resultList,
    );
  }
}

class Results {
  String message_id;

  Results({this.message_id});

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      message_id: json['message_id'].toString(),
    );
  }
}

class UserData {
  String name;
  String email;
  String image;
  String token;

  UserData({this.name, this.email, this.image, this.token});
}
