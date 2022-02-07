import 'package:AgoraDemo/repository/sendNotificationCall.dart';
import 'package:AgoraDemo/utils/settings.dart';
import 'package:AgoraDemo/videoCall.dart';
import 'package:AgoraDemo/main.dart';
import 'package:AgoraDemo/userProfile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/userModel.dart';

class UserList extends StatefulWidget {
  UserList({Key key}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  DatabaseReference datebaseReference = FirebaseDatabase.instance.reference();
  GoogleSignIn _googleSignIn = GoogleSignIn();

  List<UserData> userData = [];
  UserData currentUser = new UserData();
  bool isLoading = true;
  TextEditingController _channelController = TextEditingController();
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getPermissionAndDatabaseValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Video Call",
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.brown,
            ),
            onPressed: () async {
              // User Profile Screen with current user data
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return UserProfile(
                    name: currentUser.name == null
                        ? "Not Available"
                        : currentUser.name,
                    email: currentUser.email == null
                        ? "Not Available"
                        : currentUser.email,
                    image: currentUser.image,
                  );
                },
              ));
              print("UserProfile");
            },
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.brown,
            ),
            onPressed: () async {
              prefs = await SharedPreferences.getInstance();
              prefs.setInt("isLogin", 0);
              await _googleSignIn.signOut().whenComplete(() {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) {
                    return MyHomePage();
                  },
                ));
              });
              developer.log("Sign Out");
            },
          ),
        ],
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: EdgeInsets.fromLTRB(20.0, 5.0, 5.0, 5.0),
            margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: TextField(
              controller: _channelController,
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'token (Channel name)',
                hintStyle: TextStyle(
                  color: Colors.brown,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
              child: Row(
                children: [
                  Container(
                    child: Text(
                      "Client Role : ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      "ClientRole.Broadcaster",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              : userData.isEmpty
                  ? Container(
                      alignment: Alignment.center,
                      child: Text(
                        "No user available",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Expanded(
                      child: Container(
                        child: ListView.builder(
                          itemCount: userData.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () async {
                                notificationAndVideoCall(userData[index]);
                              },
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userData[index].image),
                              ),
                              title: Text(userData[index].name),
                              subtitle: Text(userData[index].email),
                              trailing: Icon(
                                Icons.call,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                    )
        ],
      ),
    );
  }

  getPermissionAndDatabaseValue() async {
    // Permission for Video and Microphone
    await Permission.camera.request();
    await Permission.microphone.request();

    // Get User's data from database
    datebaseReference.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> map = snapshot.value;
      convertDataToUsable(map.values.toList());
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  convertDataToUsable(List listJson) async {
    prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email');

    // Extract data to Usable Objects
    List<UserData> temp = [];
    for (int i = 0; i < listJson.length; i++) {
      if (email != listJson[i]['email'].toString()) {
        temp.add(new UserData(
          name: listJson[i]['name'].toString(),
          email: listJson[i]['email'].toString(),
          image: listJson[i]['image'].toString(),
          token: listJson[i]['token'].toString(),
        ));
      } else {
        // Current User Data
        setState(() {
          currentUser = new UserData(
            name: listJson[i]['name'].toString(),
            email: listJson[i]['email'].toString(),
            image: listJson[i]['image'].toString(),
            token: listJson[i]['token'].toString(),
          );
        });
        // continue;
      }
    }
    setState(() {
      userData = temp;
    });
  }

  notificationAndVideoCall(UserData userData) async {
    if (PermissionStatus.granted == await Permission.camera.status &&
        PermissionStatus.granted == await Permission.microphone.status) {
      // Send Notification to receiver(User) to join video call
      await sendNotification(userData.token, userData.name);
      await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return CallPage(
            channelName: channelName,
            role: ClientRole.Broadcaster,
          );
        },
      ));
    } else {
      // Ask Permission Again If user doesn't accept it
      await Permission.camera.request();
      await Permission.microphone.request();
    }
  }
}
