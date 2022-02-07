import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserProfile extends StatefulWidget {
  String name;
  String email;
  String image;

  UserProfile({Key key, this.name, this.email, this.image}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        centerTitle: true,
        elevation: 0,
        title: Text(widget.name),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 130.0,
              width: 130.0,
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.image),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              child: Text(
                widget.name,
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              child: Text(
                widget.email,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
