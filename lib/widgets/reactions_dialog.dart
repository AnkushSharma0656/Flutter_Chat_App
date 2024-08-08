import 'package:chatty/constants.dart';
import 'package:chatty/models/message_model.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:flutter/material.dart';

class ReactionsDialog extends StatefulWidget {
  const ReactionsDialog({
    super.key,
    required this.uid,
    required this.message,
    required this.onReactionsTap,
    required this.onContextMenu
  });

  final String uid;
  final MessageModel message;
  final Function(String) onReactionsTap;
  final Function(String) onContextMenu;

  @override
  State<ReactionsDialog> createState() => _ReactionsDialogState();
}

class _ReactionsDialogState extends State<ReactionsDialog> {
  @override
  Widget build(BuildContext context) {
    final isMyMessage = widget.uid == widget.message.senderUID;
    return Align(
      alignment:  Alignment.centerRight,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade500,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0,1)
                    )
                  ]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  for(final reaction in reactions)
                    InkWell(
                      onTap: () {
                        widget.onReactionsTap(reaction);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            reaction,
                            style: const TextStyle(fontSize: 20),
                        )
                        ,),
                    )
                ],
                ),
              ),
            ),
          ),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: isMyMessage
                          ?  Theme.of(context).colorScheme.primary
                          :  Colors.grey[400],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade400,
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0,1)
                        )
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.message.messageType == MessageEnum.text
                    ?
                    Text(
                      widget.message.message,
                      style: const TextStyle(color: Colors.white),
                    ):widget.message.messageType == MessageEnum.image
                        ?const Icon(Icons.image) :const Icon(Icons.video_collection) ,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width*0.4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.shade400,
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0,1)
                        )
                      ]
                  ),
                  child: Column(
                    children: [
                      for(final menu in contextMenu)
                        InkWell(
                          onTap: () {
                            widget.onContextMenu(menu);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  menu,
                                  style: const TextStyle(fontSize: 20,color: Colors.black),
                                ),
                                Icon( menu == 'Reply' ? Icons.reply : menu == 'Copy' ? Icons.copy : Icons.delete,color: Colors.black,)
                              ],
                            )
                            ,),
                        )
                  ],),
                ),
              ),
            )

        ],),
      ),
    );
  }
}
