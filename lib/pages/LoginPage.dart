import 'package:chatapp_firebase/models/UIHelper.dart';
import 'package:chatapp_firebase/models/userModel.dart';
import 'package:chatapp_firebase/pages/HomePage.dart';
import 'package:chatapp_firebase/pages/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == ""){
      UIHelper.showAlert(context, "Incomplete Data", "Please fill all the fields");
      print("Please enter all fields");
    }

    else {
      //print("Sign up successfully!");
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async{

    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Logging In...");

    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword
        (email: email, password: password);

    } on FirebaseAuthException catch(ex){

      //Close the loading dialog
      Navigator.pop(context);
      
      //show alert dialog
      UIHelper.showAlert(context, 'An error occured!', ex.message.toString());
      print(ex.message.toString());
    }

    if(credential != null){
      String uid = credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.
      collection("users").doc(uid).get();
      UserModel _userModel = UserModel.fromMap(userData.data()
      as Map<String, dynamic>);
      
      //go to home page
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
          HomePage(userModel: _userModel , firebaseUser: credential!.user!)));

      print("Login Successfully");
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Chat App",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    )),
                  SizedBox(height: 10),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email"
                    ),
                  ),
                  SizedBox(height: 10),
                  
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password"
                    ),
                  ),

                  SizedBox(height: 10),
                  
                  MaterialButton(
                   onPressed: (){
                     checkValues();
                   },
                    child: Text("Login"),
                    color: Colors.blue,

                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?",
                style: TextStyle(
                    fontSize: 16,

                )),

            MaterialButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpPage()));
              },
              child:   Text("SignUp",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue

                  )),



            )
          ],
        ),
      ),
    );
  }
}

