import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register>
{
  final TextEditingController _nametextEditingController =TextEditingController();
  final TextEditingController _emailtextEditingController =TextEditingController();
  final TextEditingController _passwordtextEditingController =TextEditingController();
  final TextEditingController _cpasswordtextEditingController =TextEditingController();

  final GlobalKey<FormState> _formKey =GlobalKey<FormState>();
  String userImageUrl="";
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    double _screenWidth=MediaQuery.of(context).size.width,_screenHeight=MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 10.0,),
            InkWell(
              onTap: _selectAndPickImage,
              child: CircleAvatar(
                radius: _screenWidth*0.15 ,
                backgroundColor: Colors.white,
                backgroundImage: _imageFile==null ? null : FileImage(_imageFile),
                child: _imageFile==null
                    ? Icon(Icons.add_photo_alternate,size:_screenWidth*0.15, color: Colors.grey, )
                :null,
              ),
            ),
            SizedBox(height: 8.0,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nametextEditingController,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _emailtextEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordtextEditingController,
                    data: Icons.person,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                  CustomTextField(
                    controller: _cpasswordtextEditingController,
                    data: Icons.person,
                    hintText: "Confirm Password",
                    isObsecure: true,
                  ),
                ],

              ),
            ),
            RaisedButton(
              onPressed:() {uploadAndSaveImage();},
              color: Colors.pink,
              child: Text("Sign Up", style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth*0.8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectAndPickImage() async{
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

  }

 Future<void> uploadAndSaveImage() async
 {
   if(_imageFile==null)
     {
       showDialog(
           context: context,
       builder: (c){
             return ErrorAlertDialog(message: "Please Select an Image",);

       }
       );
     }

   else{
     _passwordtextEditingController.text==_cpasswordtextEditingController.text
         ?_emailtextEditingController.text.isNotEmpty &&
         _passwordtextEditingController.text.isNotEmpty &&
          _passwordtextEditingController.text.isNotEmpty &&
         _nametextEditingController.text.isNotEmpty

         ? uploadToStorage()

         :displayDialog("Please Complete all the Form Details..")
         
         :displayDialog("Passwords do not match.");
   }
 }

 displayDialog(String msg){
    showDialog(context: context,
    builder: (c)
    {
      return ErrorAlertDialog(message: msg,);
    }
    );
 }

  uploadToStorage() async
  {
    showDialog(
      context: context,
      builder: (c)
        {
          return LoadingAlertDialog(message: "Registering, Please Wait...",);
        }
    );
    String imageFileName =DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference=FirebaseStorage.instance.ref().child(imageFileName);

    StorageUploadTask storageUploadTask=storageReference.putFile(_imageFile);

    StorageTaskSnapshot taskSnapshot= await storageUploadTask.onComplete;

    await taskSnapshot.ref.getDownloadURL().then((urlImage){
      userImageUrl=urlImage;

      _registerUser();

    });
  }

  FirebaseAuth _auth=FirebaseAuth.instance;

  void _registerUser() async
  {
    FirebaseUser firebaseUser;

    await _auth.createUserWithEmailAndPassword(
      email: _emailtextEditingController.text.trim(),
      password: _passwordtextEditingController.text.trim(),
    ).then((auth){

      firebaseUser= auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(context:context,
        builder: (c){
        return ErrorAlertDialog(message: error.message.toString(),);
        }
      );
    });

    if(firebaseUser!=null){
      saveUserInfoToFirestore(firebaseUser).then((value){
        Navigator.pop(context);
        Route route= MaterialPageRoute(builder: (c) =>StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future saveUserInfoToFirestore(FirebaseUser fUser) async

  {
    Firestore.instance.collection("users").document(fUser.uid).setData({
      "uid": fUser.uid,
      "email": fUser.email,
      "name":_nametextEditingController.text.trim(),
      "url": userImageUrl,
      EcommerceApp.userCartList:["garbageValue"],
    });

    await EcommerceApp.sharedPreferences.setString("uid", fUser.uid);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userEmail, fUser.email);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName, _nametextEditingController.text);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, userImageUrl);
    await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, ["garbageValue"]);


  }
}

