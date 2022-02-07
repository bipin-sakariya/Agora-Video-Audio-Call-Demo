import 'dart:convert';

import 'package:AgoraDemo/model/userModel.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

var url = "https://fcm.googleapis.com/fcm/send";

Future<void> sendNotification(String token, String clientName) async {
  UserModel userModel = new UserModel();

  final body = {
    "registration_ids": ["$token"],
    "notification": {
      "title": "$clientName" + " calling..",
      "body": "Join video call",
      "image":
          "https://gamadevelopmentstorage.blob.core.windows.net/publicgamadev/GamaLogos/Logo con fondo.png"
    },
    "data": {
      "food_type": "Enter other data here",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    }
  };

  Map<String, String> header = {
    "Content-Type": "application/json",
    "Authorization":
        "key=AAAApIR3MWo:APA91bEhHCfjJhqakOS77JFAeH5xE9EGp9gQSjLBVncaAIRZ_0_ucpAH9iLp_Pz6grepWgfqMxVBCp3PI24ly9t4IVkKt0seQ7vx5b1TeGIEDi9JIH-xUsKkrN8At0lrSfdqLoRqXIEe"
  };

  try {
    final responce = await http.post(
      url,
      headers: header,
      body: jsonEncode(body),
    );

    if (responce.statusCode == 200) {
      var responceJson = json.decode(responce.body);
      userModel = UserModel.fromJson(responceJson);
      developer.log(userModel.success.toString(), name: "Success");
    }
  } catch (e) {
    print(e.toString());
  }
}
