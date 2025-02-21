import 'dart:io';

import 'package:chatty/constants.dart';
import 'package:chatty/models/last_message_model.dart';
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
   setLoading(true);
   notifyListeners();
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
         repliedMessageType: repliedMessageType,
         reactions: []
     );

     // 3. check if its a group message and send to group else send to contact
     if(groupId.isNotEmpty){
       // handle group message

     }else{
       // handle contact message
         await  handleContactMessage(
         messageModel: messageModel,
         contactUID: contactUID,
         contactName: contactName,
         contactImage : contactImage,
         onSuccess : onSuccess,
         onError : onError
       );

      // set message reply model to null
       setMessageReplyModel(null);

     }

   }catch(e){
     onError(e.toString());
   }
  }

  // send file message to firestore
  Future<void> sendFileMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required File file,
    required MessageEnum messageType,
    required String groupId,
    required Function onSuccess,
    required Function(String) onError
})async{
    setLoading(true);
   try {
     var messageId = const Uuid().v4();
     //1. check if its a message reply and add the replied message to the message
     String repliedMessage = _messageReplyModel?.message ?? '';
     String repliedTo = _messageReplyModel == null
         ? ''
         : _messageReplyModel!.isMe
         ? 'You'
         : _messageReplyModel!.senderName;
     MessageEnum repliedMessageType = _messageReplyModel?.messageType ??
         MessageEnum.text;

     // 2. upload file to firebase storage
     final ref = '${Constants.chatFiles}/${messageType.name}/${sender
         .uid}/$contactUID/$messageId';
     String fileUrl = await storeFileToStorage(file: file, reference: ref);

     // 3. update/set the messageModel
     final messageModel = MessageModel(
         senderUID: sender.uid,
         senderName: sender.name,
         senderImage: sender.image,
         contactUID: contactUID,
         message: fileUrl,
         messageType: messageType,
         timeSent: DateTime.now(),
         messageId: messageId,
         isSeen: false,
         repliedMessage: repliedMessage,
         repliedTo: repliedTo,
         repliedMessageType: repliedMessageType,
         reactions: []
     );

     // 4. check if its a group message and send to group else send to contact
     if (groupId.isNotEmpty) {
       // handle group message

     } else {
       // handle contact message
       await handleContactMessage(
           messageModel: messageModel,
           contactUID: contactUID,
           contactName: contactName,
           contactImage: contactImage,
           onSuccess: onSuccess,
           onError: onError
       );

       // set message reply model to null
       setMessageReplyModel(null);
     }
   }catch(e){
     onError(e.toString());
   }



}

  Future<void> handleContactMessage({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required Function onSuccess,
    required Function(String p1) onError}) async{

    try{
      // 0. contact messageModel
      final contactMessageModel = messageModel.copyWith(userId: messageModel.senderUID);

      // 1. initialize last message for the sender
      final senderLastMessage = LastMessageModel(
          senderUID: messageModel.senderUID,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          message: messageModel.message,
          messageType: messageModel.messageType,
          timeStamp: messageModel.timeSent,
          isSeen: false
      );

      // 2. initilize last message for the contact

      final contactLastMessage = senderLastMessage.copyWith(
          contactUID: messageModel.senderUID,
          contactName: messageModel.senderName,
          contactImage: messageModel.senderImage
      );
      // 3. send message to sender firestore location
     await _firestore.collection(Constants.users)
              .doc(messageModel.senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageModel.messageId).set(messageModel.toMap());

      // 4. send message to contact firestore location
    await _firestore.collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(messageModel.senderUID)
              .collection(Constants.messages)
              .doc(messageModel.messageId).set(contactMessageModel.toMap());

      // 5. send the last message to sender firestore location
       await  _firestore.collection(Constants.users)
              .doc(messageModel.senderUID)
              .collection(Constants.chats)
              .doc(contactUID).set(senderLastMessage.toMap());

      // 6. send the last message to contact firestore location
      await _firestore.collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(messageModel.senderUID).set(contactLastMessage.toMap());


      // await _firestore.runTransaction((transaction)async{
      //   // 3. send message to sender firestore location
      //   transaction.set(
      //       _firestore.collection(Constants.users)
      //           .doc(messageModel.senderUID)
      //           .collection(Constants.chats)
      //           .doc(contactUID)
      //           .collection(Constants.messages)
      //           .doc(messageModel.messageId),
      //     messageModel.toMap()
      //   );
      //   // 4. send message to contact firestore location
      //   transaction.set(
      //       _firestore.collection(Constants.users)
      //           .doc(contactUID)
      //           .collection(Constants.chats)
      //           .doc(messageModel.senderUID)
      //           .collection(Constants.messages)
      //           .doc(messageModel.messageId),
      //       contactMessageModel.toMap()
      //   );
      //
      //   // 5. send the last message to sender firestore location
      //   transaction.set(
      //       _firestore.collection(Constants.users)
      //           .doc(messageModel.senderUID)
      //           .collection(Constants.chats)
      //           .doc(contactUID),
      //       senderLastMessage.toMap()
      //   );
      //
      //   // 6. send the last message to contact firestore location
      //   transaction.set(
      //       _firestore.collection(Constants.users)
      //           .doc(contactUID)
      //           .collection(Constants.chats)
      //           .doc(messageModel.senderUID),
      //       contactLastMessage.toMap()
      //   );
      //
      //
      // });


      // 7. call onSuccess
      setLoading(false);
      onSuccess();

    }on FirebaseException catch (e){
      setLoading(false);
      onError(e.message ?? e.toString());
    }catch(e){
      setLoading(false);
      onError(e.toString());
    }

  }

  // set message as seen
  Future<void> setMessageAsSeen({
    required String userId,
    required String contactUID,
    required String messageId,
    required String groupId
})async{

   // 1. check if its a group message
    if(groupId.isNotEmpty){
      // handle group message
    }else{
      // handle contact message

      // 2. update the current message as seen
      await _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId)
          .update({Constants.isSeen: true});

      // 3. update the contact message as seen
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(userId)
          .collection(Constants.messages)
          .doc(messageId)
          .update({Constants.isSeen: true});

      // 4. update the last message as seen for current user
      await _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .update({Constants.isSeen: true});

      // 5. update the last message as seen for contact
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(userId)
          .update({Constants.isSeen: true});


    }
  }

  // get chatList Screen
  Stream<List<LastMessageModel>> getChatListStream(String userId){
   return _firestore
       .collection(Constants.users)
       .doc(userId)
       .collection(Constants.chats)
       .orderBy(Constants.timeSent,descending: true)
       .snapshots()
       .map((snapshot) {
         return snapshot.docs.map((doc) {
           return LastMessageModel.fromMap(doc.data());
         }).toList();
   });
  }

  // stream messages from chat collection
  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String contactUID,
    required String isGroup
}){
   // 1. check if its a group message
    if(isGroup.isNotEmpty){
      // handle group message
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    }else{
      return _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return MessageModel.fromMap(doc.data());
            }).toList();
      });
    }
}
// store file to firestore  and return file Url
  Future<String> storeFileToStorage({
    required File file,
    required String reference
  })async{
    UploadTask uploadTask = _firebaseStorage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }
}

