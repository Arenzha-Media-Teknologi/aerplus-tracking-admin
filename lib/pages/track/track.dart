import 'dart:async';
import 'package:admin/assets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingAdmin extends StatefulWidget {
  @override
  _TrackingAdminState createState() => _TrackingAdminState();
}

class _TrackingAdminState extends State<TrackingAdmin> {
  final Set<Marker> markers = new Set();

  bool isDetail = true;
  var name, position, address, photo = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //loadMap();
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
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(-6.9032739, 107.5731166), zoom: 10.0),
              // onMapCreated: (GoogleMapController controller) {
              //   _controller.complete(controller);
              // },
            ),
            Positioned(
                bottom: 1,
                child: Container(
                  width: Get.mediaQuery.size.width,
                  height: 100,
                  child: Row(
                    children: <Widget>[
                      Container(
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
                              child: Expanded(
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

  ///functiom
  getMarkerData() async {
    Stream<QuerySnapshot> stream =
        FirebaseFirestore.instance.collection("employee_locations").snapshots();
    await stream.forEach((QuerySnapshot element) {
      if (element == null) return;

      for (int count = 0; count < element.docs.length; count++) {
        if (element.docs[count]['is_tracked']) {
          setState(() {
            markers.add(Marker(
              //add first marker
              markerId: MarkerId(element.docs[count]['name']),
              position: LatLng(
                double.parse(element.docs[count]['latitude'].toString()),
                double.parse(element.docs[count]['longitude'].toString()),
              ),
              onTap: () {
                setState(() {
                  isDetail = true;
                  name = element.docs[count]['name'];
                  address = element.docs[count]['address'];
                  photo = element.docs[count]['photo'];
                });


                // Navigator.pop(context);
                _showModalButtonSheet();
              },

              // icon: BitmapDescriptor.defaultMarker, //Icon for Marker
            ));
          });
        }
      }
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
                          child: Expanded(
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
                                                                        : Image
                                                                            .network(
                                                                            streamSnapshot.data!.docs[index]['photo'],
                                                                            width:
                                                                                50,
                                                                            height:
                                                                                50,
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
                                              : Image.network(
                                                  photo,
                                                  width: 50,
                                                  height: 50,
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
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(
                                          top: 30, left: 10, right: 10),
                                      child: Container(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Lokasi Saat ini",
                                            style: TextStyle(
                                                color: blackColor2,
                                                fontSize: 15,
                                                fontFamily: "roboto-regular"),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                              "${address != null ? address : address}",
                                              style: TextStyle(
                                                  color: blackColor1,
                                                  fontSize: 13,
                                                  fontFamily:
                                                      "roboto-regular")),
                                        ],
                                      ))),
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
                                          child: Container(
                                            width: double.maxFinite,
                                            alignment: Alignment.centerRight,
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              "Tampilkan Semua",
                                              style: TextStyle(
                                                  color: baseColor2,
                                                  fontFamily: "roboto-regular",
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ///checkin history
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 20, left: 15, right: 15),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 15,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                  color: baseColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                "13 januari 2022",
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    color: blackColor2,
                                                    fontSize: 14,
                                                    fontFamily:
                                                        "roboto-regular"),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                width: double.maxFinite,
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(

                                                  "10:13:41",
                                                  style: TextStyle(
                                                      letterSpacing: 1,
                                                      color: baseColor,
                                                      fontSize: 14,
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
                                                alignment:
                                                    Alignment.centerRight,
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                height: 90,
                                                color: baseColor3,
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  width: double.maxFinite,
                                                  child: Text(
                                                    "Jl. Dipati Ukur No.112-116, Lebakgede, Kecamatan Coblong, Kota Bandung, Jawa Barat 40132",
                                                    style: TextStyle(
                                                        letterSpacing: 1,
                                                        color: blackColor4,fontFamily: "roboto-regular"),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 15, right: 15),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 15,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                  color: baseColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                "13 januar 2022",
                                                style: TextStyle(
                                                    color: blackColor2,
                                                    fontSize: 14,
                                                    fontFamily:
                                                        "roboto-regular"),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                width: double.maxFinite,
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  "10:13:41",
                                                  style: TextStyle(
                                                      color: baseColor,
                                                      fontSize: 14,
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
                                                alignment:
                                                    Alignment.centerRight,
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                height: 90,
                                                color: baseColor3,
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  width: double.maxFinite,
                                                  child: Text(
                                                    "Jl. Dipati Ukur No.112-116, Lebakgede, Kecamatan Coblong, Kota Bandung, Jawa Barat 40132",
                                                    style: TextStyle(
                                                        fontFamily: "roboto-regular",
                                                        letterSpacing: 2,
                                                        color: blackColor4),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
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
}
