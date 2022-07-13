import 'dart:io';
import 'package:chatapp_firebase/models/UIHelper.dart';
import 'package:chatapp_firebase/models/userModel.dart';
import 'package:chatapp_firebase/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfile({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController fullNameController = TextEditingController();
  File? imageFile;


  void selectImage(ImageSource source) async{
   XFile? pickedFile = await ImagePicker().pickImage(source: source);
   if(pickedFile != null){
     cropImage(pickedFile);
   }
  }

  void cropImage(XFile filepath) async{
 CroppedFile? croppedFile= (await ImageCropper().cropImage(
    sourcePath: filepath.path,
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    compressQuality:20
  ));

 if(croppedFile!= null) {
   final cropImage = croppedFile.path;
   setState(() {
     imageFile = File(cropImage);
   });
  }
  }

  void checkValues(){
    String fullName = fullNameController.text.trim();
    if(fullName == "" || imageFile == ""){

      UIHelper.showAlert(context, "Incomplete Data", "Please fil all the fields and upload profile picture.");
      print("Please fill all fields");
    }
    else{
      uploadData();
    }
  }

  void uploadData() async{

    UIHelper.showLoadingDialog(context, "Uploading image...");


   final uploadTask = (await FirebaseStorage.instance.ref("profilePicture").
    child(widget.userModel.uid.toString()).putFile(imageFile!));

    TaskSnapshot taskSnapshot = await uploadTask;
    String? imageUrl = await taskSnapshot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();

    widget.userModel.fullName = fullname;
    widget.userModel.profilePic = imageUrl;
    
    await FirebaseFirestore.instance.collection("users").
    doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value) {
      print("Data uploaded");

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
          HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
    });
  }


  void showPhotoOptions() {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title : Text("Upload profile picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from gallery"),
            ),

            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a photo"),
            )
          ],
        ),
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: ListView(
              children: [

                SizedBox(height: 20,),

                MaterialButton(
                  onPressed: (){
                    showPhotoOptions();
                  },
                  child: CircleAvatar(
                    radius: 60,
                     backgroundImage: imageFile != null ? FileImage(imageFile!) : null,

                      child: (imageFile == null) ? Icon(Icons.person, size: 60,) : null,
                  ),
                ),
                SizedBox(height: 20,),

                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    hintText: "Full Name"
                  ),
                ),

                SizedBox(height: 20,),


                MaterialButton(
                  onPressed: (){
                    checkValues();
                  },
                  child: Text("Submit"),
                  color: Colors.blue,

                )

              ],

            ),
          )),
    );
  }
}
