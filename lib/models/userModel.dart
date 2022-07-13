class UserModel{
  String? uid;
  String? fullName;
  String? email;
  String? profilePic;

  //default Constructor
UserModel({this.uid,this.fullName,this.email,this.profilePic});

//from map constructor
 UserModel.fromMap(Map<String, dynamic>map){
  uid = map['uid'];
  fullName = map['fullName'];
  email = map['email'];
  profilePic = map['profilePic'];
 }

 //toMap
  //data save from to map into firebase
// return to a map
Map<String, dynamic> toMap(){
   return{
     'uid' : uid,
     'fullName' : fullName,
     'email' : email,
     'profilePic' : profilePic,
   };
}
}