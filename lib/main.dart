import 'package:AgoraDemo/manager/pushNotificationManager.dart';
import 'package:AgoraDemo/userList.dart';
import 'package:AgoraDemo/videoCall.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireauth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int isLogin = 0;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _isLoginMethod();
  }

  _isLoginMethod() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('isLogin') &&
        prefs.getInt('isLogin') != null &&
        prefs.getInt('isLogin') == 1) {
      setState(() {
        isLogin = prefs.getInt('isLogin');
        developer.log(isLogin.toString(), name: "isLogin");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/videocall': (context) => CallPage(),
      },
      home: isLogin != 1 ? MyHomePage() : UserList(),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int isVerified = 0;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    final pushNotification = PushNotificationsManager();
    pushNotification.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isVerified = 1;
                });
                _googleSignIn();
              },
              child: Container(
                height: 60.0,
                margin: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage(
                        'assets/images/google_logo.png',
                      ),
                      height: 25.0,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "Sign in with Google",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isVerified == 1
                ? Container(
                    margin: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  _googleSignIn() async {
    String token = '';
    prefs = await SharedPreferences.getInstance();
    final DatabaseReference datebaseReference =
        FirebaseDatabase.instance.reference();
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    fireauth.FirebaseAuth _auth = fireauth.FirebaseAuth.instance;

    GoogleSignInAccount googleUSer;
    GoogleSignInAuthentication googleAuth;

    try {
      // Google Sign In
      googleUSer = await _googleSignIn.signIn();

      if (googleUSer != null) {
        googleAuth = await googleUSer.authentication;

        final fireauth.AuthCredential credential =
            fireauth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final fireauth.User user =
            (await _auth.signInWithCredential(credential)).user;

        if (user.emailVerified) {
          // retrive token to save it to firebase
          if (prefs.containsKey('token') && prefs.getString('token') != null) {
            token = prefs.getString('token');
          }
          // User Login and Email
          prefs.setInt("isLogin", 1);
          prefs.setString('email', user.email.toString());

          // Save data to realtime database
          datebaseReference.child(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'image': user.photoURL,
            'token': token
          }).whenComplete(() {
            setState(() {
              isVerified = 0;
            });

            // Navigate to Main Page
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return UserList();
              },
            ));
          });
        }
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
