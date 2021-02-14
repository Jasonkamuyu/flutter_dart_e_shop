import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Models/address.dart';
import 'package:flutter/material.dart';

class AddAddress extends StatelessWidget {
  final formKey= GlobalKey<FormState>();
  final scaffoldKey= GlobalKey<ScaffoldState>();
  final cName= TextEditingController();
  final cPhone= TextEditingController();
  final cHomeNo= TextEditingController();
  final cCity= TextEditingController();
  final cCountry= TextEditingController();
  final cPinCode= TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: MyAppBar(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: ()
          {
            if(formKey.currentState.validate())
              {
                final model = AddressModel(
                  name: cName.text.trim(),
                  state: cCountry.text.trim(),
                  pincode: cPinCode.text,
                  phoneNumber: cPhone.text,
                  flatNumber: cHomeNo.text,
                  city: cCity.text.trim(),
                ).toJson();

                //add to firestore

                EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                .collection(EcommerceApp.subCollectionAddress).document(DateTime.now().millisecondsSinceEpoch.toString())
                .setData(model).then((value){
                  final snack= SnackBar(content: Text("New Address Added Successfully."));
                  scaffoldKey.currentState.showSnackBar(snack);
                  FocusScope.of(context).requestFocus(FocusNode());
                  formKey.currentState.reset();
                });

                Route route=MaterialPageRoute(builder: (_) =>StoreHome());
                Navigator.pushReplacement(context, route);
              }
          },
          label: Text("Done"),
          backgroundColor: Colors.pink,
          icon: Icon(Icons.check),
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Add New Address",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    MyTextField(
                      hint: "Name",
                      controller: cName,
                    ),

                    MyTextField(
                      hint: "Phone Number",
                      controller: cPhone,
                    ),

                    MyTextField(
                      hint: "House Number",
                      controller: cHomeNo,
                    ),

                    MyTextField(
                      hint: "County",
                      controller: cCity,
                    ),

                    MyTextField(
                      hint: "Country",
                      controller: cCountry,
                    ),

                    MyTextField(
                      hint: "Pin Code",
                      controller: cPinCode,
                    ),

                  ],
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  MyTextField({Key key, this.hint, this.controller,}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        validator: (val) => val.isEmpty ? "Field Cannot be Empty." : null,
      ),

    );
  }
}
