import 'package:chatapp_firebase/models/FireBaseHelper.dart';
import 'package:chatapp_firebase/models/userModel.dart';
import 'package:chatapp_firebase/pages/CompleteProfile.dart';
import 'package:chatapp_firebase/pages/HomePage.dart';
import 'package:chatapp_firebase/pages/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  

 User? currentUser =  FirebaseAuth.instance.currentUser;


 if(currentUser != null) {
   //Logged in
   UserModel? thisUserModel = await FirebaseHelper.getUserModeById(
       currentUser.uid);
   if (thisUserModel != null) {
     runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
   }
   else{
     // not logged in
     runApp(MyApp());
   }
 }
 else{
   // not logged in
   runApp(MyApp());
 }

}

//when we are not logged in then we call this widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}


//when we are  logged in then we call this widget
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({Key? key, required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}

