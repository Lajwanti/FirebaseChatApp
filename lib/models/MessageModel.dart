class MessageModel{

  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;

  MessageModel({this.sender,this.text,this.seen,this.createdOn,this.messageId});

  //from map constructor
  //firebase se data lenge to fromMap k through data lenge mtlb
  // yhn se map milega phr object banaege  or to map me us object se map banaege
  MessageModel.fromMap(Map<String, dynamic>map){
    messageId = map['messageId'];
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdOn = map['createdOn'].toDate();
  }

  //toMap
  //data save from to map into firebase
// return to a map
  Map<String, dynamic> toMap(){
    return{
      'messageId' : messageId,
      'sender' : sender,
      'text' : text,
      'seen' : seen,
      'createdOn' : createdOn,
    };
  }
}