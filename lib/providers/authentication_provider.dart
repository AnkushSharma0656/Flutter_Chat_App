import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:chatty/constants.dart';
import 'package:chatty/models/user_model.dart';
import 'package:chatty/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier{
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String ? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // check authentication state
  Future<bool> checkAuthenticationState()async{
    bool isSigned = false;
    await Future.delayed(const Duration(seconds: 2));

    if(_auth.currentUser != null){
      _uid = _auth.currentUser!.uid;
      // get user data from firestore
      await getUserDataFromFireStore();
      // save user data to shared preferences
      await saveUserDataToSharedPreferences();
      notifyListeners();
      isSigned = true;
    }else{
      isSigned = false;
    }

    return isSigned;
  }


  // check if user exists
  Future<bool> checkUserExists()async{
    DocumentSnapshot documentSnapshot = await _firestore.collection(Constants.users).doc(_uid).get();
    if(documentSnapshot.exists) return true;
    return false;
  }

  // get user data from firestore
  Future<void> getUserDataFromFireStore()async{
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel = UserModel.fromMap(documentSnapshot.data() as Map<String,dynamic>);
    notifyListeners();
  }

  // save user data to the shared preferences
  Future<void> saveUserDataToSharedPreferences()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  // get data from shared preferences
  Future<void> getUserDataFromSharedPreferences()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString = sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();
  }


  // sign in with phone number
Future<void> signInWithPhoneNumber({
  required String phoneNumber,
  required BuildContext context
}) async{

  _isLoading = true;
  notifyListeners();

  await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential)async{
        await _auth.signInWithCredential(credential).then((value)async{
          _uid = value.user!.uid;
          _phoneNumber = value.user!.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          notifyListeners();
        });
       },
      verificationFailed: (FirebaseException e){
        _isSuccessful = false;
        _isLoading = false;
        notifyListeners();
        showSnackBar(context,e.toString());
      },
      codeSent: (String verificationId,int? resendToken)async{
        _isLoading = false;
        notifyListeners();
        Navigator.of(context).pushNamed(
          Constants.otpScreen,
          arguments: {
            Constants.verificationId : verificationId,
            Constants.phoneNumber : phoneNumber
          }
        );
      },
      codeAutoRetrievalTimeout: (String verificationId){},
  );

}

  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccess
  })async{
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode);

    await _auth.signInWithCredential(credential).then((value)async{
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }).catchError((e){
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.toString());
    });

  }

  // save user data to firestore
void saveUserDataToFireStore({
  required UserModel userModel,
  required File? fileImage,
  required Function onSuccess,
  required Function onFail,
})async{

    _isLoading = true;
    notifyListeners();

    try{
      if(fileImage != null){
        // upload image to fireStore
        String imageUrl = await storeFileToStorage(file: fileImage, reference: '${Constants.userImages}/${userModel.uid}');
        userModel.image = imageUrl;
      }
      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      // save user data to fireStore
      await _firestore.collection(Constants.users).doc(userModel.uid).set(userModel.toMap());

      _isLoading = false;
      onSuccess();
      notifyListeners();
    }on FirebaseException catch(e){
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
}

// store file to fire store  and return file Url
Future<String> storeFileToStorage({
    required File file,
    required String reference
})async{
    UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
}

// get user stream
Stream<DocumentSnapshot> userStream({required String userID}){
    return _firestore.collection(Constants.users).doc(userID).snapshots();
}
// get all user stream
  Stream<QuerySnapshot> getAllUsersStream({required String userID}){
    return _firestore.collection(Constants.users).where(Constants.uid, isNotEqualTo: userID).snapshots();
  }
  // send friend request list
  Future<void> sendFriendRequest({
  required String friendID
})async{
    try{
      // add our uid to friend request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestUIDS: FieldValue.arrayUnion([_uid])});
      // add friend uid to our friend requests send list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.sendFriendRequests: FieldValue.arrayUnion([_uid])});

    }on FirebaseException catch(e){
      print(e.toString()+ 'send friend request error');
    }
  }


  Future<void> cancelFriendRequest({
    required String friendID
  })async{
    try{
      // remove uid to friend request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestUIDS: FieldValue.arrayRemove([_uid])});
      // remove friend uid to our friend requests send list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.sendFriendRequests: FieldValue.arrayRemove([_uid])});

    }on FirebaseException catch(e){
      print(e.toString()+ 'cancelled friend request error');
    }
  }

  Future<void> acceptFriendRequest({
    required String friendID
  })async{
    try{
      // add our uid to friend  list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendsUIDs: FieldValue.arrayUnion([_uid])});

      // add friend uid to our  friend list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendsUIDs: FieldValue.arrayUnion([friendID])});

      // remove our uid from friend request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.sendFriendRequests: FieldValue.arrayRemove([_uid])});

      // remove friend uid from our friend request sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendRequestUIDS: FieldValue.arrayRemove([friendID])});

    }on FirebaseException catch(e){
      print(e.toString()+ 'accept friend request error');
    }
  }
  // remove friends
  Future<void> removeFriend({
    required String friendID
  })async{
    try{
      // remove uid from friend  list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendsUIDs: FieldValue.arrayRemove([_uid])});
      // remove uid from our friend  list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendsUIDs: FieldValue.arrayRemove([friendID])});

    }on FirebaseException catch(e){
      print(e.toString()+ 'removeFriend error');
    }
  }
// logout

 Future logoutUser() async{
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }



}