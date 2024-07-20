import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({Key? key,required this.contactId, required this.contactName, required this.contactImage, required this.groupId}) : super(key: key);
  final String contactId;
  final String contactName;
  final String contactImage;
  final String groupId;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).primaryColor)
      ),
      child: Row(
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).primaryColor
            ),
            margin: const EdgeInsets.all(5),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.send,color: Colors.white,),
            ),
          )
        ],
      ),
    );
  }

}