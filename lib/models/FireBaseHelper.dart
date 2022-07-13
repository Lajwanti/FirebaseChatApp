import 'package:chatapp_firebase/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper{

 static Future<UserModel?> getUserModeById(String uid)async {
    UserModel? userModel;

     DocumentSnapshot documentSnapshot =await FirebaseFirestore.instance.
     collection("users").doc(uid).get();

     if(documentSnapshot.data() != null){
       userModel = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);

     }
     return userModel;

  }
}