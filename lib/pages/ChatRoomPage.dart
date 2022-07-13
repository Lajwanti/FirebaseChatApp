import 'dart:developer';

import 'package:chatapp_firebase/main.dart';
import 'package:chatapp_firebase/models/ChatRoomModdel.dart';
import 'package:chatapp_firebase/models/MessageModel.dart';
import 'package:chatapp_firebase/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetModel;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({Key? key,
    required this.targetModel,
    required this.chatRoom,
    required this.userModel,
    required this.firebaseUser}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController msgController = TextEditingController();


  void sendMessage() async{
    String msg = msgController.text.trim();
    msgController.clear();



    if(msg != ""){
      // send msg
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        createdOn: DateTime.now(),
        text: msg,
        seen: false
      );

      FirebaseFirestore.instance.collection("chatRooms").doc(widget.chatRoom.chatroomId).
      collection("Messages").doc(newMessage.messageId).set(newMessage.toMap());

      widget.chatRoom.lastMessage = msg;

      FirebaseFirestore.instance.collection("chatRooms").
      doc(widget.chatRoom.chatroomId).set(widget.chatRoom.toMap());

      log("Message sent!");

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
             backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(widget.targetModel.profilePic.toString()),
            ),
            SizedBox(width: 10),
            Text(widget.targetModel.fullName.toString()),

          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              //This is where chat wil go
              Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("chatRooms").
                      doc(widget.chatRoom.chatroomId).
                      collection("Messages").orderBy("createdOn", descending: true).snapshots(),

                      builder: (context, snapshot){
                        if(snapshot.connectionState == ConnectionState.active){
                          if(snapshot.hasData){
                            QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;

                            return ListView.builder(
                              reverse: true,
                              itemCount: datasnapshot.docs.length,
                              itemBuilder: (context , index){
                                MessageModel currentMessage = MessageModel.
                                fromMap(datasnapshot.docs[index].data() as Map<String, dynamic>);
                                //print(currentMessage.text.toString());
                                return Row(
                                  mainAxisAlignment:  (currentMessage.sender == widget.userModel.uid)
                                      ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                Container(
                                margin: EdgeInsets.symmetric(vertical: 2),
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                decoration: BoxDecoration(
                                color :  (currentMessage.sender == widget.userModel.uid) ? Colors.grey : Colors.blue,
                                borderRadius: BorderRadius.circular(12)
                                ),
                                child: Text(currentMessage.text.toString()),),
                                  ],
                                );
                              }
                            );

                          }
                          else if(snapshot.hasError){
                            return Text("An error occured! Please check your internet connection.");

                          }
                          else{
                            return Text("Say hi to your new friend!");
                          }
                        }
                        else{
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Container();
                      },
                    ),
                  )),


              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5
                ),
                child: Row(
                  children: [
                    Flexible(child: TextField(
                      controller: msgController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: "Enter message"
                      ),
                    )),

                    IconButton(
                      onPressed: (){
                        sendMessage();
                      },
                      icon: Icon(Icons.send,
                        color: Colors.blue),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
