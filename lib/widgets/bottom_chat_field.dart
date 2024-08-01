import 'dart:io';

import 'package:chatty/constants.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/providers/chat_provider.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:chatty/widgets/message_reply_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({Key? key,required this.contactUID, required this.contactName, required this.contactImage, required this.groupId}) : super(key: key);
  final String contactUID;
  final String contactName;
  final String contactImage;
  final String groupId;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  File? finalFileImage;
  String filePath = '';
  @override
  void initState() {
    // TODO: implement initState
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }
  @override
  void dispose(){
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  void selectImage(bool fromCamera)async{
    finalFileImage = await pickImage(
        fromCamera: fromCamera,
        onFail: (String message){
          showSnackBar(context, message);
        }
    );

    //crop image
    await cropImage(finalFileImage?.path);
    popContext();
  }
  void popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(croppedFilePath)async{
    if(croppedFilePath != null ){
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: croppedFilePath,
          maxHeight: 800,
          maxWidth: 800,
          compressQuality: 90
      );

      if(croppedFile != null){
        filePath = croppedFilePath;
        //send image message to firestore
      }
    }

  }
  // send text message to firestore
  void sendTextMessage(){
    final currentUser = context.read<AuthenticationProvider>().userModel;
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendTextMessage(
        sender: currentUser!,
        contactUID: widget.contactUID,
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        message: _textEditingController.text,
        messageType: MessageEnum.text,
        groupId: widget.groupId,
        onSuccess: (){
          _textEditingController.clear();
          _focusNode.requestFocus();
        },
        onError: (error){
          showSnackBar(context, error);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context,chatProvider,child){
        final messageReply = chatProvider.messageReplyModel;
        final isMessageReply = messageReply != null;
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).colorScheme.primary)
          ),
          child: Column(
            children: [
              isMessageReply
                  ? const MessageReplyPreview()
                  : const SizedBox.shrink(),
              Row(
                children: [
                  IconButton(
                      onPressed: (){
                        showBottomSheet(
                            context: context,
                            builder: (context){
                              return Container(
                                height: 200,
                                child: const Center(
                                  child: Text('Attachment'),
                                ),
                              );
                            }
                        );
                      },
                      icon: const Icon(Icons.attachment)),
                  Expanded(
                      child: TextFormField(
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration.collapsed(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(30)
                                ),
                                borderSide: BorderSide.none
                            ),
                            hintText: 'Type a message'
                        ),
                      )),
                  GestureDetector(
                    onTap: sendTextMessage,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.deepPurple
                      ),
                      margin: const EdgeInsets.all(5),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_upward,color: Colors.white,),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}