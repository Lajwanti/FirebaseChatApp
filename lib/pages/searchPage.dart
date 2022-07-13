import 'dart:developer';

import 'package:chatapp_firebase/main.dart';
import 'package:chatapp_firebase/models/ChatRoomModdel.dart';
import 'package:chatapp_firebase/models/userModel.dart';
import 'package:chatapp_firebase/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  ChatRoomModel? chatRoom;

  Future<ChatRoomModel?> getchatRoomModel(UserModel targetUser) async{

    QuerySnapshot querySnapshot =await FirebaseFirestore.instance.collection("chatRooms").
    where("participants.${widget.userModel.uid}",isEqualTo: true).
    where("participants.${targetUser.uid}",isEqualTo: true).get();

    if(querySnapshot.docs.length > 0){
      //fetch the existing one
      log("Chat room already created!");
       var docData = querySnapshot.docs[0].data();
       ChatRoomModel  existingChatRoom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);

       chatRoom = existingChatRoom;
    }
    else{
      //create a new one

      ChatRoomModel newChatRoom = ChatRoomModel(
        chatroomId: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString() : true,
          targetUser.uid.toString() : true,

        }
      );
      await FirebaseFirestore.instance.collection("chatRooms").
      doc(newChatRoom.chatroomId).set(newChatRoom.toMap());
      log("Chat room created!");

      chatRoom = newChatRoom;

    }
    return chatRoom;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Sreach"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 20
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Email Address"
                ),
              ),

              SizedBox(height:20),

              MaterialButton(
                  onPressed: (){
                    setState(() {

                    });
                  },
                color: Colors.blue,
                child: Text("Search"),
              ),

              SizedBox(height: 20,),

              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("users").
                  where("email", isEqualTo: searchController.text).
                  where("email" , isNotEqualTo: widget.userModel.email).snapshots(),
              builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.active){
                      if(snapshot.hasData){
                        QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                        if(dataSnapshot.docs.length > 0){
                          Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;
                          UserModel searchedModel = UserModel.fromMap(userMap);
                          return ListTile(
                            onTap: ()async{
                              ChatRoomModel? chatroomModel1 = await getchatRoomModel(searchedModel);

                              if(chatroomModel1 != null){
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder:
                                        (context) {
                                       return ChatRoomPage(
                                          targetModel: searchedModel,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser,
                                          chatRoom : chatroomModel1);
                                        }
                                    ));
                              }

                            },
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(searchedModel.profilePic!),
                            ),
                            title:  Text(searchedModel.fullName!),
                            subtitle: Text(searchedModel.email!),
                            trailing: Icon(Icons.keyboard_arrow_right),

                          );

                        }
                        else{
                          return Text("No result found!");
                        }

                      }
                      else if(snapshot.hasError){
                        print("an error occured!");

                      }
                      else{
                        print("No result found!");
                      }

                    }
                    else{
                      return CircularProgressIndicator();
                    }
                return Container();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
