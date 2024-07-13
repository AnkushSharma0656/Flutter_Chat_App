import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chatty/constants.dart';
import 'package:chatty/main_screen/chats_list_screen.dart';
import 'package:chatty/main_screen/groups_screen.dart';
import 'package:chatty/main_screen/people_screen.dart';
import 'package:chatty/providers/authentication_provider.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatty/utilities/assets_manager.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final PageController pageController = PageController(initialPage: 0);
  final List<Widget> pages = [
    ChatsListScreen(),
    GroupsScreen(),
    PeopleScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
         appBar: AppBar(
           title: const Text("Chatty Chat"),
           actions:  [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: userImageWidget(
                   imageUrl: authProvider.userModel!.image,
                   radius: 20,
                   onTap: (){
                   //navigate to user profile with uid as arguments
                     Navigator.pushNamed(
                         context,
                         Constants.profileScreen,
                         arguments: authProvider.userModel!.uid
                     );

               })
             )
           ],
         ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index){
        setState(() {
          currentIndex = index;
        });
        },
        children: pages,

      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_2),label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.group),label: 'Groups'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.globe),label: 'People'),
      ],
        currentIndex: currentIndex,
        onTap: (index){
        pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        setState(() {
          currentIndex = index;
        });
        },
      ),

    );
  }
}
