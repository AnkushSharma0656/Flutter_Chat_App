import 'dart:html';

import 'package:chatty/constants.dart';
import 'package:chatty/widgets/app_bar_back_button.dart';
import 'package:chatty/widgets/friends_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);
        },),
        centerTitle: true,
        title: const Text('Friends Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // cupertino search bar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(color: Colors.white),
              onChanged: (value){
                print(value);
              },
            ),
            const Expanded(child: FriendsList(viewType: FriendViewType.friends,))
          ],
        ),
      ),
    );
  }
}
