import 'package:chatapp_firebase/models/UIHelper.dart';
import 'package:chatapp_firebase/models/userModel.dart';
import 'package:chatapp_firebase/pages/CompleteProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();


void checkValues() {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();
  String cPassword = confirmPasswordController.text.trim();


  if(email == "" || password == "" || cPassword == ""){
    UIHelper.showAlert(context, "Incomplete Data!", "Please fill all fields.");
    print("Please enter all fields");
  }
  else if(password != cPassword){
    UIHelper.showAlert(context, "Password Mismatched!", "The passwords you entered don't match");
    print("Password do not match!");
  }
  else {
    //print("Sign up successfully!");
    signUp(email, password);
  }
}
//firebase auth give us class credential auth
// then get user credential from credential class
void signUp(String email, String password) async{
  UserCredential? credential;

  UIHelper.showLoadingDialog(context, "Creating New Account...!");

  try{
    credential = await FirebaseAuth.instance.createUserWithEmailAndPassword
      (email: email, password: password);


  } on FirebaseAuthException catch(ex){
    Navigator.pop(context);
    UIHelper.showAlert(context, "An error occured!", ex.code.toString());
    print(ex.code.toString());
  }

  if(credential != null) {
    String uid = credential.user!.uid;
    UserModel newUser = UserModel(
      uid: uid,
      email: email,
      fullName: '',
      profilePic: '',

    );
    await FirebaseFirestore.instance.collection("users").doc(uid).set(
        newUser.toMap()).then((value) {
          print("New user created!");
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
            return CompleteProfile(userModel: newUser, firebaseUser: credential!.user!);
          }));
    });

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

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: "Confirm Password"
                    ),
                  ),

                  SizedBox(height: 10),

                  MaterialButton(
                    onPressed: (){
                      checkValues();
                      // Navigator.push(context, MaterialPageRoute(
                      //     builder: (context)=>CompleteProfile()));
                    },
                    child: Text("Sign Up"),
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
            Text("Already have an account?",
                style: TextStyle(
                  fontSize: 16,

                )),

            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child:   Text("SignIn",
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
