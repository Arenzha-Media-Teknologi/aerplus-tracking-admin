import 'dart:async';
import 'package:admin/assets/colors.dart';
import 'package:admin/assets/constant.dart';
import 'package:admin/models/checkin.dart';
import 'package:admin/pages/track/checkin_history.dart';
import 'package:admin/pages/track/detail.dart';
import 'package:admin/pages/track/photo.dart';
import 'package:admin/repositories/api.dart';
import 'package:admin/repositories/checkin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:format_indonesia/format_indonesia.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';

class TrackingAdmin extends StatefulWidget {
  @override
  _TrackingAdminState createState() => _TrackingAdminState();
}

class _TrackingAdminState extends State<TrackingAdmin> {
  final Set<Marker> markers = new Set();

  bool isDetail = false;
  var name, position, address, photo = null, employeeId = "0";
  var latitude, longitude;
  GoogleMapController? mapController;
  BitmapDescriptor? _markerIcon;
  var searchText = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      getMarkerData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.mediaQuery.size.width,
        height: Get.mediaQuery.size.height,
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              markers: markers,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                //method called when map is created
                setState(() {
                  mapController = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(-6.9032739, 107.5731166), zoom: 10.0),
              // onMapCreated: (GoogleMapController controller) {
              //   _controller.complete(controller);
              // },
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                height: 50,
                child: TextFormField(
                  // controller: usernameController,
                  style: TextStyle(
                      fontFamily: "roboto-regular", color: blackColor2),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: Container(
                        child: Icon(
                          // Based on passwordVisible state choose the icon
                          Icons.search,
                          color: textFieldColor,
                        ),
                      ),
                      contentPadding: EdgeInsets.only(top: 2, left: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(width: 0, color: Colors.red),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: baseColor, width: 2.0),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 1.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      hintText: 'Cari Pegawai',
                      hintStyle: TextStyle(
                          color: textFieldColor, fontFamily: "roboto-regular")),

                  // validator: (value) =>
                  // state.isValidPassword ? null : "password is too short",
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toString();
                    });
                  },
                ),
              ),
            ),
            searchText != ""
                ? Container(
                    margin: EdgeInsets.only(top: 90, left: 30, right: 30),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    child: SingleChildScrollView(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('employee_locations')
                            .where("is_tracked", isEqualTo: true)

                            // .where('name', isLessThan: searchText +'z')
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                          if (streamSnapshot.hasData &&
                              streamSnapshot != null) {
                            if (streamSnapshot.data!.docs.length > 0) {
                              //  List dataa= data.dwhere((i) => i.isAnimated).toList();
                              List d = streamSnapshot.data!.docs
                                  .where((element) => element['name']
                                      .toString()
                                      .toUpperCase()
                                      .contains(
                                          searchText.toString().toUpperCase()))
                                  .toList();
                              return Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Column(
                                    children: List.generate(d.length, (index) {
                                  return InkWell(
                                    onTap: () {
                                      searchText = "";
                                      mapController?.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                  target: LatLng(
                                                      double.parse(
                                                          d[index]['latitude']),
                                                      double.parse(d[index]
                                                          ['longitude'])),
                                                  zoom: 20)
                                              //17 is new zoom level
                                              ));
                                      // setState(() {
                                      //   isDetail = true;
                                      //   var id = d["employee_id"] ??
                                      //       0;
                                      //   employeeId = id.toString();
                                      //   latitude = streamSnapshot
                                      //       .data!.docs[index]["latitude"]
                                      //       .toString();
                                      //   longitude = streamSnapshot
                                      //       .data!.docs[index]["longitude"]
                                      //       .toString();
                                      //
                                      //   employeeId = id.toString();
                                      //
                                      //   // Navigator.pop(context);
                                      // });
                                      // name = streamSnapshot.data!.docs[index]
                                      //     ['name'];
                                      // address = streamSnapshot.data!.docs[index]
                                      //     ['address'];
                                      // photo = streamSnapshot.data!.docs[index]
                                      //     ['photo'];
                                      //
                                      // Navigator.pop(context);
                                      // _showModalButtonSheet();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 10, right: 10, bottom: 50),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            child: d[index]['photo'] == null
                                                ? Image.asset(
                                                    "assets/images/profile-default.png",
                                                    width: 50,
                                                    height: 50,
                                                  )
                                                : CircleAvatar(
                                              backgroundImage:
                                              NetworkImage("${image_url}/${d[index]['photo']}"),
                                              radius:
                                              25,
                                            )
                                          ),
                                          Container(
                                            width: Get.mediaQuery.size.width *
                                                0.55,
                                            margin: EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  d[index]['name'],
                                                  style: TextStyle(
                                                      fontFamily:
                                                          "roboto-regular",
                                                      fontSize: 15,
                                                      color: blackColor2),
                                                ),
                                                Text(d[index]['address'],
                                                    style: TextStyle(
                                                        fontFamily:
                                                            "roboto-regular",
                                                        color: blackColor1,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })),
                              );
                            }
                            if (streamSnapshot.data!.docs.length == 0) {
                              return Center(child: Text('No Data'));
                            }
                          }
                          return Center(
                            child: Container(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  color: baseColor,
                                )),
                          );
                        },
                      ),
                    ),
                  )
                : Container(),
            Positioned(
                bottom: 1,
                child: Container(
                  width: Get.mediaQuery.size.width,
                  height: 100,
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 1,
                            child: Container(
                              margin: EdgeInsets.all(5),
                              child: Icon(Icons.arrow_back, color: blackColor),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Expanded(
                          child: Container(
                            width: double.maxFinite,
                            height: 100,
                            margin: EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 50,
                              height: 50,
                              child: InkWell(
                                onTap: () {
                                  _showModalButtonSheet();
                                  // showModalBottomSheet(
                                  //     backgroundColor: Colors.transparent,
                                  //     context: context,
                                  //     isScrollControlled: true,
                                  //     builder: (context) {
                                  //       return FractionallySizedBox(
                                  //           heightFactor: 0.9,
                                  //           child: _bottomSheet());
                                  //     });
                                },
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  elevation: 1,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.group,
                                      color: blackColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size.square(48));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/images/office.png')
          .then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIcon = bitmap;
    });
  }

  ///functiom
  getMarkerData() async {
    print("ts");
    Stream<QuerySnapshot> stream =
        FirebaseFirestore.instance.collection("employee_locations").snapshots();
    await stream.forEach((QuerySnapshot element) {
      if (element == null) return;

      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size.square(48));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, 'assets/images/profile-default.png');

      element.docs.forEach((element) async {
        var iconurl = 'your url';
        var dataBytes;
        var request = await http.get(Uri.parse(employee_default));
        var bytes = request.bodyBytes;
        final Uint8List markerIcon =
            await getBytesFromAsset('assets/images/profile-default.png', 100);
        final Marker marker =
            Marker(icon: BitmapDescriptor.fromBytes(markerIcon));

        setState(() {
          dataBytes = bytes;
        });
        if (element['is_tracked']) {
          _createMarkerImageFromAsset(context);
          setState(() {
            markers.add(Marker(
              //add first marker
              markerId: MarkerId(element['name']),
              icon: BitmapDescriptor.fromBytes(markerIcon),
              // icon: BitmapDescriptor.fromBytes(dataBytes.buffer.asUint8List()),

              position: LatLng(
                double.parse(element['latitude'].toString()),
                double.parse(element['longitude'].toString()),
              ),
              onTap: () {
                setState(() {
                  isDetail = true;
                  name = element['name'];
                  address = element['address'];
                  photo = element['photo'];
                  latitude = element['latitude'].toString();
                  longitude = element['longitude'].toString();
                  // employeeId = element.docs[count]['employee_id'];
                  var id = element['employee_id'];
                  employeeId = id.toString();
                });

                // Navigator.pop(context);
                _showModalButtonSheet();
              },

              // icon: BitmapDescriptor.defaultMarker, //Icon for Marker
            ));
          });
        }
      });

      // for (int count = 0; count < element.docs.length; count++) {
      //
      //   if (element.docs[count]['is_tracked']) {
      //     _createMarkerImageFromAsset(context);
      //     setState(() {
      //       markers.add(Marker(
      //         //add first marker
      //         markerId: MarkerId(element.docs[count]['name']),
      //         icon: _markerIcon,
      //
      //         position: LatLng(
      //           double.parse(element.docs[count]['latitude'].toString()),
      //           double.parse(element.docs[count]['longitude'].toString()),
      //         ),
      //         onTap: () {
      //           setState(() {
      //             isDetail = true;
      //             name = element.docs[count]['name'];
      //             address = element.docs[count]['address'];
      //             photo = element.docs[count]['photo'];
      //             latitude = element.docs[count]['latitude'].toString();
      //             longitude = element.docs[count]['longitude'].toString();
      //             // employeeId = element.docs[count]['employee_id'];
      //             //  var id=element.docs[count]['employee_id'];
      //             //  employeeId=id.toString();
      //           });
      //
      //           // Navigator.pop(context);
      //           _showModalButtonSheet();
      //         },
      //
      //         // icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      //       ));
      //     });
      //   }
      // }
    });
  }

  void _showModalButtonSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return FractionallySizedBox(heightFactor: 0.9, child: _bottomSheet());
        });
  }

  Widget _bottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 1,
      minChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          child: Column(
            children: [
              Container(
                width: Get.mediaQuery.size.width,
                height: 100,
                margin: EdgeInsets.only(right: 5),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        if (isDetail == true) {
                          setState(() {
                            isDetail = false;
                          });
                          Navigator.pop(context);
                          _showModalButtonSheet();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 1,
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: Icon(Icons.arrow_back, color: blackColor),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Expanded(
                        child: Container(
                          width: double.maxFinite,
                          height: 100,
                          margin: EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          child: isDetail == false
                              ? InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      elevation: 1,
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.close,
                                          color: blackColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        //new Color.fromRGBO(255, 0, 0, 0.0),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: isDetail == false
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: whiteColor1,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      width: 60,
                                      height: 5,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: 20, left: 10, right: 10),
                                      width: double.infinity,
                                      height: Get.mediaQuery.size.height,
                                      child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('employee_locations')
                                            .where("is_tracked",
                                                isEqualTo: true)
                                            .snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                                streamSnapshot) {
                                          if (streamSnapshot.hasData &&
                                              streamSnapshot != null) {
                                            if (streamSnapshot
                                                    .data!.docs.length >
                                                0) {
                                              return ListView.builder(
                                                  itemCount: streamSnapshot
                                                      .data!.docs.length,
                                                  itemBuilder: (ctx, index) {
                                                    print(streamSnapshot
                                                        .data!.docs.length);
                                                    return streamSnapshot.data!
                                                                .docs.length >
                                                            0
                                                        ? InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                isDetail = true;
                                                                var id = streamSnapshot
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        "employee_id"] ??
                                                                    0;
                                                                employeeId = id
                                                                    .toString();
                                                                latitude = streamSnapshot
                                                                    .data!
                                                                    .docs[index]
                                                                        [
                                                                        "latitude"]
                                                                    .toString();
                                                                longitude = streamSnapshot
                                                                    .data!
                                                                    .docs[index]
                                                                        [
                                                                        "longitude"]
                                                                    .toString();

                                                                employeeId = id
                                                                    .toString();

                                                                // Navigator.pop(context);
                                                              });
                                                              name = streamSnapshot
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                  ['name'];
                                                              address = streamSnapshot
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                  ['address'];
                                                              photo = streamSnapshot
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                  ['photo'];

                                                              Navigator.pop(
                                                                  context);
                                                              _showModalButtonSheet();
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          50),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    child: streamSnapshot.data!.docs[index]['photo'] ==
                                                                            null
                                                                        ? Image
                                                                            .asset(
                                                                            "assets/images/profile-default.png",
                                                                            width:
                                                                                50,
                                                                            height:
                                                                                50,
                                                                          )
                                                                        : CircleAvatar(
                                                                            backgroundImage:
                                                                                NetworkImage("${image_url}/${streamSnapshot.data!.docs[index]['photo']}"),
                                                                            radius:
                                                                                25,
                                                                          ),
                                                                  ),
                                                                  Container(
                                                                    width: Get
                                                                            .mediaQuery
                                                                            .size
                                                                            .width *
                                                                        0.55,
                                                                    margin: EdgeInsets.only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          streamSnapshot
                                                                              .data!
                                                                              .docs[index]['name'],
                                                                          style: TextStyle(
                                                                              fontFamily: "roboto-regular",
                                                                              fontSize: 15,
                                                                              color: blackColor2),
                                                                        ),
                                                                        Text(
                                                                            streamSnapshot.data!.docs[index][
                                                                                'address'],
                                                                            style: TextStyle(
                                                                                fontFamily: "roboto-regular",
                                                                                color: blackColor1,
                                                                                fontSize: 12)),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Icon(
                                                                      Icons
                                                                          .remove_red_eye,
                                                                      color:
                                                                          blackColor2,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container();
                                                  }
                                                  // Text(streamSnapshot.data!.docs[index]['address']),
                                                  );
                                            } else if (streamSnapshot
                                                    .data!.docs.length ==
                                                0) {
                                              return Center(
                                                  child: Text('No Data'));
                                            }
                                          }
                                          return Center(
                                            child: Container(
                                                width: 50,
                                                height: 50,
                                                child:
                                                    CircularProgressIndicator()),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : SingleChildScrollView(
                            child: Container(
                              margin: EdgeInsets.all(10),
                              width: Get.mediaQuery.size.width,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    width: 61,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: whiteColor1,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      width: 100,
                                      height: 5,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          child: photo == null
                                              ? Image.asset(
                                                  "assets/images/profile-default.png",
                                                  width: 50,
                                                  height: 50,
                                                )
                                              : CircleAvatar(
                                            backgroundImage:
                                            NetworkImage("${image_url}/${photo}"),
                                            radius:
                                            25,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "${name}",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily:
                                                        "roboto-regular",
                                                    color: blackColor2),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "Supervisor",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily:
                                                        "roboto-regular",
                                                    color: blackColor3),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      mapController?.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                  target: LatLng(
                                                      double.parse(
                                                          latitude.toString()),
                                                      double.parse(longitude
                                                          .toString())),
                                                  zoom: 20)
                                              //17 is new zoom level
                                              ));
                                      Get.back();
                                    },
                                    child: Container(
                                        color: blackColor5,
                                        height: 100,
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.only(top: 30),
                                        child: Center(
                                          child: Container(
                                              width: Get.mediaQuery.size.width,
                                              margin: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Lokasi Saat ini",
                                                    style: TextStyle(
                                                        color: blackColor2,
                                                        fontSize: 15,
                                                        fontFamily:
                                                            "roboto-regular"),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        "${address != null ? address : address}",
                                                        style: TextStyle(
                                                            color: blackColor1,
                                                            fontSize: 13,
                                                            fontFamily:
                                                                "roboto-regular")),
                                                  ),
                                                ],
                                              )),
                                        )),
                                  ),
                                  //devider
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Divider(
                                      color: whiteColor2,
                                    ),
                                  ),

                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 20, left: 10, right: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          child: Icon(
                                            Icons.history,
                                            color: blackColor2,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text("Riwayat Checkin",
                                              style: TextStyle(
                                                  color: blackColor2,
                                                  fontFamily: "roboto-regular",
                                                  fontSize: 15)),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .rightToLeft,
                                                      child: CheckinHistoryPage(
                                                        employeeId: employeeId,
                                                      )));
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              alignment: Alignment.centerRight,
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                "Tampilkan Semua",
                                                style: TextStyle(
                                                    color: baseColor2,
                                                    fontFamily:
                                                        "roboto-regular",
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),

                                  StreamBuilder<List<CheckinModel>>(
                                    stream: watchPurchases(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Container(
                                            // margin: EdgeInsets.only(
                                            //     left: 20, right: 20),
                                            // child: Text(
                                            //   "${snapshot.error}",
                                            //   style: TextStyle(
                                            //       color: Colors.red,
                                            //       fontSize: 12),
                                            // ),
                                            );
                                      }
                                      if (snapshot.hasData) {
                                        var data = snapshot.data!;
                                        if (data.length > 0) {
                                          return Column(
                                            children: List.generate(data.length,
                                                (index) {
                                              var d = DateTime.parse(data[index]
                                                  .dateTime
                                                  .toString());

                                              var dateLocal = d.toLocal();
                                              // var localDate = DateFormat().parse(data[index].dateTime.toString(), true).toLocal().toString();
                                              // String createdDate = DateFormat().format(DateTime.parse(localDate)); // you will local time
                                              ///checkin history
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .rightToLeft,
                                                            child: DetailPage(
                                                              image: data[index]
                                                                  .image,
                                                              address:
                                                                  data[index]
                                                                      .address,
                                                              latitude:
                                                                  data[index]
                                                                      .latitude,
                                                              longitude: data[
                                                                      index]
                                                                  .longitude,
                                                              datetime:
                                                                  data[index]
                                                                      .dateTime,
                                                            )));
                                                    // isDetail = true;
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      left: 15, right: 15),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: <Widget>[
                                                          Container(
                                                            width: 15,
                                                            height: 15,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    baseColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 10),
                                                            child: Text(
                                                              "${Waktu(DateTime.parse(data[index].dateTime.toString())).yMMMMEEEEd()} ",
                                                              style: TextStyle(
                                                                  color:
                                                                      blackColor2,
                                                                  fontSize: 13,
                                                                  letterSpacing:
                                                                      0.5,
                                                                  height: 1.4,
                                                                  fontFamily:
                                                                      "roboto-regular"),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              width: double
                                                                  .maxFinite,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 10),
                                                              child: Text(
                                                                "${DateFormat("HH:mm:ss").format(dateLocal)}",
                                                                style: TextStyle(
                                                                    color:
                                                                        baseColor,
                                                                    fontSize:
                                                                        13,
                                                                    letterSpacing:
                                                                        0.5,
                                                                    height: 1.4,
                                                                    fontFamily:
                                                                        "roboto-regular"),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 5),
                                                              height: 90,
                                                              color: baseColor3,
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            10),
                                                                width: double
                                                                    .maxFinite,
                                                                child: Text(
                                                                  "${data[index].address}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      letterSpacing:
                                                                          0.5,
                                                                      height:
                                                                          1.4,
                                                                      color:
                                                                          blackColor4),
                                                                ),
                                                              ),
                                                            ),
                                                            Hero(
                                                                tag: "avatar-1",
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Get.to(
                                                                        PhotoPage(
                                                                      image: data[
                                                                              index]
                                                                          .image,
                                                                    ));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 50,
                                                                    height: 50,
                                                                    color: Colors
                                                                        .blue,
                                                                    child: PhotoView(
                                                                        imageProvider:
                                                                            NetworkImage("${image_url}/${data[index].image}")),
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                        } else {
                                          return Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: Get.mediaQuery.size
                                                          .width /
                                                      2,
                                                  height: 200,
                                                  child: SvgPicture.asset(
                                                      "assets/images/no-checkin.svg",
                                                      semanticsLabel:
                                                          'Acme Logo'),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  child: Text(
                                                    "belum ada checkin",
                                                    style: TextStyle(
                                                        color: blackColor4,
                                                        fontSize: 14),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: baseColor,
                                          ),
                                        ),
                                      );
                                    },
                                  )

                                  ///checkin history
                                  // Container(
                                  //   margin: EdgeInsets.only(
                                  //       top: 20, left: 15, right: 15),
                                  //   child: Column(
                                  //     children: [
                                  //       Row(
                                  //         children: <Widget>[
                                  //           Container(
                                  //             width: 15,
                                  //             height: 15,
                                  //             decoration: BoxDecoration(
                                  //                 color: baseColor,
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(
                                  //                         20)),
                                  //           ),
                                  //           Container(
                                  //             margin: EdgeInsets.only(left: 10),
                                  //             child: Text(
                                  //               "13 januari 2022",
                                  //               style: TextStyle(
                                  //                   letterSpacing: 1,
                                  //                   color: blackColor2,
                                  //                   fontSize: 14,
                                  //                   fontFamily:
                                  //                       "roboto-regular"),
                                  //             ),
                                  //           ),
                                  //           Expanded(
                                  //             child: Container(
                                  //               alignment:
                                  //                   Alignment.centerRight,
                                  //               width: double.maxFinite,
                                  //               margin:
                                  //                   EdgeInsets.only(left: 10),
                                  //               child: Text(
                                  //                 "10:13:41",
                                  //                 style: TextStyle(
                                  //                     letterSpacing: 1,
                                  //                     color: baseColor,
                                  //                     fontSize: 14,
                                  //                     fontFamily:
                                  //                         "roboto-regular"),
                                  //               ),
                                  //             ),
                                  //           )
                                  //         ],
                                  //       ),
                                  //       Container(
                                  //         child: Row(
                                  //           children: <Widget>[
                                  //             Container(
                                  //               alignment:
                                  //                   Alignment.centerRight,
                                  //               margin:
                                  //                   EdgeInsets.only(left: 5),
                                  //               height: 90,
                                  //               color: baseColor3,
                                  //               width: 5,
                                  //             ),
                                  //             Expanded(
                                  //               child: Container(
                                  //                 margin:
                                  //                     EdgeInsets.only(left: 20),
                                  //                 width: double.maxFinite,
                                  //                 child: Text(
                                  //                   "Jl. Dipati Ukur No.112-116, Lebakgede, Kecamatan Coblong, Kota Bandung, Jawa Barat 40132",
                                  //                   style: TextStyle(
                                  //                       letterSpacing: 1,
                                  //                       color: blackColor4,
                                  //                       fontFamily:
                                  //                           "roboto-regular"),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           ],
                                  //         ),
                                  //       )
                                  //     ],
                                  //   ),
                                  // ),
                                  // Container(
                                  //   margin:
                                  //       EdgeInsets.only(left: 15, right: 15),
                                  //   child: Column(
                                  //     children: [
                                  //       Row(
                                  //         children: <Widget>[
                                  //           Container(
                                  //             width: 15,
                                  //             height: 15,
                                  //             decoration: BoxDecoration(
                                  //                 color: baseColor,
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(
                                  //                         20)),
                                  //           ),
                                  //           Container(
                                  //             margin: EdgeInsets.only(left: 10),
                                  //             child: Text(
                                  //               "13 januar 2022",
                                  //               style: TextStyle(
                                  //                   color: blackColor2,
                                  //                   fontSize: 14,
                                  //                   fontFamily:
                                  //                       "roboto-regular"),
                                  //             ),
                                  //           ),
                                  //           Expanded(
                                  //             child: Container(
                                  //               alignment:
                                  //                   Alignment.centerRight,
                                  //               width: double.maxFinite,
                                  //               margin:
                                  //                   EdgeInsets.only(left: 10),
                                  //               child: Text(
                                  //                 "10:13:41",
                                  //                 style: TextStyle(
                                  //                     color: baseColor,
                                  //                     fontSize: 14,
                                  //                     fontFamily:
                                  //                         "roboto-regular"),
                                  //               ),
                                  //             ),
                                  //           )
                                  //         ],
                                  //       ),
                                  //       Container(
                                  //         child: Row(
                                  //           children: <Widget>[
                                  //             Container(
                                  //               alignment:
                                  //                   Alignment.centerRight,
                                  //               margin:
                                  //                   EdgeInsets.only(left: 5),
                                  //               height: 90,
                                  //               color: baseColor3,
                                  //               width: 5,
                                  //             ),
                                  //             Expanded(
                                  //               child: Container(
                                  //                 margin:
                                  //                     EdgeInsets.only(left: 20),
                                  //                 width: double.maxFinite,
                                  //                 child: Text(
                                  //                   "Jl. Dipati Ukur No.112-116, Lebakgede, Kecamatan Coblong, Kota Bandung, Jawa Barat 40132",
                                  //                   style: TextStyle(
                                  //                       fontFamily:
                                  //                           "roboto-regular",
                                  //                       letterSpacing: 2,
                                  //                       color: blackColor4),
                                  //                 ),
                                  //               ),
                                  //             )
                                  //           ],
                                  //         ),
                                  //       )
                                  //     ],
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // Future<Uint8List> getBytesFromCanvas(int width, int height) async {
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint()..color = Colors.blue;
  //   final Radius radius = Radius.circular(20.0);
  //   canvas.drawRRect(
  //       RRect.fromRectAndCorners(
  //         Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
  //         topLeft: radius,
  //         topRight: radius,
  //         bottomLeft: radius,
  //         bottomRight: radius,
  //       ),
  //       paint);
  //   TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  //   painter.text = TextSpan(
  //     text: 'Hello world',
  //     style: TextStyle(fontSize: 25.0, color: Colors.white),
  //   );
  //   painter.layout();
  //   painter.paint(canvas, Offset((width * 0.5) - painter.width * 0.5, (height * 0.5) - painter.height * 0.5));
  //   final img = await pictureRecorder.endRecording().toImage(width, height);
  //   final data = await img.toByteData(format: ui.ImageByteFormat.png);
  //   return data!.buffer.asUint8List();
  // }

  Stream<List<CheckinModel>> watchPurchases() async* {
    var date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    var ohList = await CheckinRepository()
        .fetchChecindayall(employeeId.toString(), date, date);
    yield ohList;
  }
}
