import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Models/address.dart';
import 'package:e_shop/Orders/PlaceOrderPaymentPage.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/wideButton.dart';
import 'package:e_shop/Counters/changeAddresss.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'addAddress.dart';

class Address extends StatefulWidget {
  final double totalAmount;

  const Address({Key key, this.totalAmount}) : super(key: key);

  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Select Address",
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0,

                ),
                ),
              ),
            ),

            Consumer<AddressChanger>(builder: (context, address, c){
              return Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                      .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                      .collection(EcommerceApp.subCollectionAddress).snapshots(),

                  builder: (context,snaphsot)
                  {
                    return !snaphsot.hasData
                        ? Center(child: circularProgress(),)
                        :snaphsot.data.documents.length ==0
                        ? noAddressCard()
                        : ListView.builder(
                      itemCount: snaphsot.data.documents.length,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        return AddressCard(
                          currentIndex: address.count,
                          Value: index,
                          addressId: snaphsot.data.documents[index].documentID,
                          totalAmount: widget.totalAmount,
                          model: AddressModel.fromJson(snaphsot.data.documents[index].data),
                        );
                      },

                    );
                   },
                ),
              );
            })
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text("Add New Address"),
          backgroundColor: Colors.pink,
          icon: Icon(Icons.add_location),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (c) => AddAddress());
            Navigator.pushReplacement(context, route);
          },
        ),
      ),
    );
  }

  noAddressCard() {
    return Card(
      color: Colors.pink.withOpacity(0.5),
      child: Container(
        height: 100.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location, color: Colors.white,),
              Text("No Shipment Address Saved."),
            Text("Please Add Shipment Address for delivery."),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final AddressModel model;
  final String addressId;
  final double totalAmount;
  final int currentIndex;
  final int Value;

  AddressCard(
      {Key key,
      this.model,
      this.currentIndex,
      this.addressId,
      this.totalAmount,
      this.Value})
      : super(key: key);

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: ()
      {
        Provider.of<AddressChanger>(context, listen: false).displayResult(widget.Value);
      },
      child: Card(
        color: Colors.pinkAccent.withOpacity(0.4),
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                  groupValue: widget.currentIndex,
                  value: widget.Value,
                  activeColor: Colors.pink,
                  onChanged: (val) {
                    Provider.of<AddressChanger>(context, listen: false)
                        .displayResult(val);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: screenWidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              KeyText(
                                msg: "Name",
                              ),
                              Text(widget.model.name),
                            ],
                          ),

                          TableRow(
                            children: [
                              KeyText(msg: "Phone Number",),
                              Text(widget.model.phoneNumber),

                            ],
                          ),

                          TableRow(
                            children: [
                              KeyText(msg: "House Number",),
                              Text(widget.model.flatNumber),

                            ],
                          ),

                          TableRow(
                            children: [
                              KeyText(msg: "City",),
                              Text(widget.model.city),

                            ],
                          ),

                          TableRow(
                            children: [
                              KeyText(msg: "Country",),
                              Text(widget.model.state),

                            ],
                          ),

                          TableRow(
                            children: [
                              KeyText(msg: "Pin Code",),
                              Text(widget.model.pincode),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            widget.Value==Provider.of<AddressChanger>(context).count
                ? WideButton(
                    message: "Proceed",
                    onPressed: ()
                    {
                      Route route=MaterialPageRoute(builder: (_) =>PaymentPage(
                        addressId:widget.addressId,
                        totalAmount:widget.totalAmount,
                      ));
                      Navigator.pushReplacement(context, route);

                    },

            )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class KeyText extends StatelessWidget {
  final String msg;

  KeyText({Key key, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
