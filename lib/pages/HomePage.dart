import 'package:chatapp_firebase/models/ChatRoomModdel.dart';
import 'package:chatapp_firebase/models/FireBaseHelper.dart';
import 'package:chatapp_firebase/models/UIHelper.dart';
import 'package:chatapp_firebase/models/userModel.dart';
import 'package:chatapp_firebase/models/userModel.dart';
import 'package:chatapp_firebase/pages/ChatRoomPage.dart';
import 'package:chatapp_firebase/pages/LoginPage.dart';
import 'package:chatapp_firebase/pages/searchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({Key? key, required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),

        actions: [
          IconButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context){
                  return LoginPage();
                }));
          },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: SafeArea(child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("chatRooms").
          where("participants.${userModel.uid}" , isEqualTo: true).snapshots(),

          builder: (context , snapshots){
            if(snapshots.connectionState == ConnectionState.active){
              if(snapshots.hasData){

                QuerySnapshot chatRoomSnapshot = snapshots.data as QuerySnapshot;

                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context , index){
                    ChatRoomModel chatRoomModel = ChatRoomModel.
                    fromMap(chatRoomSnapshot.docs[index].data() as Map<String , dynamic>);

                    Map<String, dynamic> participants  = chatRoomModel.participants!;

                    List<String> participantsKeys = participants.keys.toList();

                    participantsKeys.remove(userModel.uid);

                    return FutureBuilder(
                      future: FirebaseHelper.getUserModeById(participantsKeys[0]),
                      builder: (context, userData){

                        if(userData.connectionState == ConnectionState.done){

                           if(userData.data != null)
                             {
                               UserModel targetUser = userData.data as UserModel;

                               return ListTile(
                                 onTap: (){
                                   Navigator.push(context,
                                       MaterialPageRoute(builder: (context){
                                         return ChatRoomPage(
                                             targetModel: targetUser,
                                             chatRoom: chatRoomModel,
                                             userModel: userModel,
                                             firebaseUser: firebaseUser);
                                       }));
                                 },
                                 leading: CircleAvatar(
                                   backgroundImage: NetworkImage(targetUser.profilePic.toString()),
                                 ),
                                 title: Text(targetUser.fullName.toString()),
                                 subtitle: (chatRoomModel.lastMessage.toString() != "") ?
                                 Text(chatRoomModel.lastMessage.toString()) :
                                 Text("Say hi to your friend!",
                                 style: TextStyle(color: Colors.blue),),
                               );
                             }
                           else{
                             return CircularProgressIndicator();
                           }


                        }
                        else{
                          return Container();
                        }


                      },
                    );
                  },

                );

              }
              else if(snapshots.hasError){
                return Text(snapshots.error.toString());
              }
              else{
                return Center(
                  child: Text("No chats"),
                );
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
      )
      ),
      floatingActionButton : FloatingActionButton(
        onPressed: (){

          Navigator.push(context, MaterialPageRoute(builder: (context){
            return SearchPage(userModel: userModel, firebaseUser: firebaseUser);
          }));
        },
        child: Icon(Icons.search),
      )
    );
  }
}
