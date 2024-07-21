import 'package:chatty/constants.dart';
import 'package:chatty/models/message_model.dart';
import 'package:chatty/models/message_reply_model.dart';
import 'package:chatty/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier{
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }
  void setMessageReplyModel(MessageReplyModel? messageReply){
    _messageReplyModel = messageReply;
    notifyListeners();
  }
  // firebase initilization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // send msg to firestore
 Future<void> sendTextMessage({
  required UserModel sender,
   required String contactUID,
   required String contactName,
   required String contactImage,
   required String message,
   required MessageEnum messageType,
   required String groupId,
   required Function onSuccess,
   required Function(String) onError
  })async{
   try{
     var messageId = const Uuid().v4();

     // 1. check if its a message reply and add the replied message to the message
     String repliedMessage = _messageReplyModel?.message ?? '';
     String repliedTo = _messageReplyModel == null ? '' : _messageReplyModel!.isMe ? 'You' : _messageReplyModel!.senderName;
     MessageEnum repliedMessageType = _messageReplyModel?.messageType ?? MessageEnum.text;

     // 2. update/set the messageModel

     final messageModel = MessageModel(
         senderUID: sender.uid,
         senderName: sender.name,
         senderImage: sender.image,
         contactUID: contactUID,
         message: message,
         messageType: messageType,
         timeSent: DateTime.now(),
         messageId: messageId,
         isSeen: false,
         repliedMessage: repliedMessage,
         repliedTo: repliedTo,
         repliedMessageType: repliedMessageType
     );

     // 3. check if its a group message and send to group else send to contact
     if(groupId.isNotEmpty){
       // handle group message

     }else{
       // handle contact message

     }


   }catch(e){
     onError(e.toString());
   }
  }

}