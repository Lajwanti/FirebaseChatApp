class ChatRoomModel{
  String? chatroomId;
  Map<String, dynamic>?  participants;
  String? lastMessage;


  //default constructor
ChatRoomModel({this.chatroomId,this.participants,this.lastMessage});

  ChatRoomModel.fromMap(Map<String, dynamic>map){
    chatroomId = map['chatroomId'];
    participants = map['participants'];
    lastMessage = map['lastMessage'];

  }

  //toMap
  //data save from to map into firebase
// return to a map
  Map<String, dynamic> toMap(){
    return{
      'chatroomId' : chatroomId,
      'participants' : participants,
      'lastMessage' : lastMessage

    };
  }
}