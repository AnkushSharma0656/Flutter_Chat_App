import 'package:chatty/constants.dart';
import 'package:chatty/widgets/app_bar_back_button.dart';
import 'package:chatty/widgets/friends_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({Key? key}) : super(key: key);

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);
        },),
        centerTitle: true,
        title: const Text('Friend Request Screen'),
      ),
      body: Column(
        children: [
          // cupertino search bar
          CupertinoSearchTextField(
            placeholder: 'Search',
            style: const TextStyle(color: Colors.white),
            onChanged: (value){
              print(value);
            },
          ),
          const Expanded(child: FriendsList(viewType: FriendViewType.friendRequests))
        ],
      ),
    );
  }
}
