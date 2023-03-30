import 'dart:async';

import 'package:admin/assets/colors.dart';
import 'package:admin/models/checkin.dart';
import 'package:admin/pages/account/account_detail.dart';
import 'package:admin/pages/track/photo.dart';
import 'package:admin/pages/track/track.dart';
import 'package:admin/repositories/api.dart';
import 'package:admin/repositories/checkin.dart';
import 'package:admin/repositories/employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:format_indonesia/format_indonesia.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart' as loc;

Timer? timer;

class Dashboardpage extends StatefulWidget {
  @override
  _DashboardpageState createState() => _DashboardpageState();
}

class _DashboardpageState extends State<Dashboardpage> {
  var isTrack = true, name, employeeId, photo, gpsStatus = false;
  var currentAddress;

  bool isAttendanceLoading = true;

  var geoLocator = Geolocator();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataPref();
    checkGps();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  height: Get.mediaQuery.size.height * 0.31,
                  color: baseColor2,
                  child: Container(
                    margin: EdgeInsets.only(top: 30, right: 20, left: 20),
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              photo == null
                                  ? Container(
                                      child: Image.asset(
                                        "assets/images/profile-default.png",
                                        width: 60,
                                        height: 60,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                          '${image_url}/${photo}')),
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "${name ?? ""}",
                                      style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 15,
                                          fontFamily: "roboto-bold",
                                          letterSpacing: 0.5),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Admin",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: "roboto-regular",
                                          letterSpacing: 0.5),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topRight,
                                  width: double.maxFinite,
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(5.0),
                                  topRight: const Radius.circular(5.0),
                                )),
                            height: 30,
                            child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              child:    Container(

                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5)),
                                  height: 33,
                                  child: Row(
                                    children: <Widget>[
                                      Container(

                                        child: Text(
                                          "Pegawai ",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontSize: 13,
                                              letterSpacing: 0.5,
                                              height: 1.4),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          width: double.maxFinite,
                                          margin: EdgeInsets.only(
                                              left: 10, right: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: greenColor,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        30)),
                                                width: 10,
                                                height: 10,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Tracking...",
                                                style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 13,
                                                    letterSpacing: 0.5,
                                                    height: 1.4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              // child: StreamBuilder<QuerySnapshot>(
                              //   stream: FirebaseFirestore.instance
                              //       .collection('employee_locations')
                              //       .snapshots(),
                              //   builder: (context, snapshot) {
                              //     if (snapshot.hasData) {
                              //       return ListView.builder(
                              //           scrollDirection: Axis.horizontal,
                              //           itemCount: snapshot.data!.docs.length,
                              //           itemBuilder: (context, index) {
                              //             DocumentSnapshot doc =
                              //                 snapshot.data!.docs[index];
                              //             var tes = "";
                              //
                              //             return doc['photo'] != null
                              //                 ? Container(
                              //                     margin:
                              //                         EdgeInsets.only(left: 5),
                              //                     child: CircleAvatar(
                              //                       backgroundColor:
                              //                           Colors.black,
                              //                       radius: 17,
                              //                       backgroundImage:
                              //                           NetworkImage(
                              //                               "${doc['photo']}"),
                              //                     ))
                              //                 : Container(
                              //                     margin:
                              //                         EdgeInsets.only(left: 5),
                              //                     child: const CircleAvatar(
                              //                         backgroundColor:
                              //                             Colors.black,
                              //                         radius: 17,
                              //                         backgroundImage: NetworkImage(
                              //                             'https://arenzha.s3.ap-southeast-1.amazonaws.com/profile-default.png')),
                              //                   );
                              //           });
                              //     } else {
                              //       return Text("No data");
                              //     }
                              //   },
                              // ),
                            )),
                        Container(

                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: new BorderRadius.only(
                                  bottomLeft: const Radius.circular(5.0),
                                  bottomRight: const Radius.circular(5.0),
                                )
                            ),
                            height: 40,
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 20),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('employee_locations')
                                    .where("is_tracked", isEqualTo: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          DocumentSnapshot doc =
                                              snapshot.data!.docs[index];
                                          var tes = "";

                                          return doc['photo'] != null
                                              ? InkWell(
                                            onTap: (){
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType.rightToLeft,
                                                      child: AccountDetailPage(employeeId:doc['employee_id'] ,)));
                                            },
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.only(left: 5),
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.black,
                                                      radius: 17,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              "${image_url}/${doc['photo']}"),
                                                    )),
                                              )
                                              : InkWell(
                                            onTap: (){
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType.rightToLeft,
                                                      child: AccountDetailPage(employeeId:doc['employee_id'] ,)));
                                            },
                                                child: Container(
                                                    margin:
                                                        EdgeInsets.only(left: 5),
                                                    child: const CircleAvatar(
                                                        backgroundColor:
                                                            Colors.black,
                                                        radius: 17,
                                                        backgroundImage: NetworkImage(
                                                            'https://arenzha.s3.ap-southeast-1.amazonaws.com/profile-default.png')),
                                                  ),
                                              );
                                        });
                                  } else {
                                    return Text("No data");
                                  }
                                },
                              ),
                            ))
                      ],
                    ),
                  ),
                ),

                Container(
                  width: Get.mediaQuery.size.width,
                  height: 40,
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: TrackingAdmin()));
                    },
                    child: const Text(
                      "Tracking",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(baseColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
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
                        child: Text("Checkin Hari Ini",
                            style: TextStyle(
                                letterSpacing: 1,
                                color: blackColor2,
                                fontFamily: "roboto-bold",
                                fontSize: 15)),
                      ),
                      // Expanded(
                      //   child: Container(
                      //     width: double.maxFinite,
                      //     alignment: Alignment.centerRight,
                      //     margin: EdgeInsets.only(left: 5),
                      //     child: Text(
                      //       "Tampilkan Semua ",
                      //       style: TextStyle(
                      //           letterSpacing: 1,
                      //           color: baseColor2,
                      //           fontFamily: "roboto-medium",
                      //           fontSize: 13),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: StreamBuilder<List<CheckinModel>>(
                    stream: watchPurchases(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // return Container(
                        //   margin: EdgeInsets.only(left: 20, right: 20),
                        //   child: Text(
                        //     "${snapshot.error}",
                        //     style: TextStyle(color: Colors.red, fontSize: 12),
                        //   ),
                        // );

                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                width: Get.mediaQuery.size.width / 2,
                                height: 200,
                                child: SvgPicture.asset(
                                    "assets/images/no-checkin.svg",
                                    semanticsLabel: 'Acme Logo'),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                child: Text(
                                  "belum ada checkin",
                                  style: TextStyle(
                                      color: blackColor4, fontSize: 14),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        if (data.length > 0) {
                          return Column(
                            children: List.generate(data.length, (index) {
                              var d = DateTime.parse(
                                  data[index].dateTime.toString());

                              var dateLocal = d.toLocal();
                              // var localDate = DateFormat().parse(data[index].dateTime.toString(), true).toLocal().toString();
                              // String createdDate = DateFormat().format(DateTime.parse(localDate)); // you will local time
                              ///checkin history
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    // isDetail = true;
                                    // Get.to(DetailPag(
                                    //   image: data[index].image,
                                    //   address: data[index].address,
                                    //   latitude: data[index].latitude,
                                    //   longitude: data[index].longitude,
                                    //   datetime: data[index].dateTime,
                                    // ));
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 15, right: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            width: 15,
                                            height: 15,
                                            decoration: BoxDecoration(
                                                color: baseColor,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "${Waktu(DateTime.parse(data[index].dateTime.toString())).yMMMMEEEEd()} ",
                                              style: TextStyle(
                                                  color: blackColor2,
                                                  fontSize: 13,
                                                  letterSpacing: 0.5,
                                                  height: 1.4,
                                                  fontFamily: "roboto-regular"),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              width: double.maxFinite,
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                "${DateFormat("HH:mm:ss").format(dateLocal)}",
                                                style: TextStyle(
                                                    color: baseColor,
                                                    fontSize: 13,
                                                    letterSpacing: 0.5,
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
                                              alignment: Alignment.centerRight,
                                              margin: EdgeInsets.only(left: 5),
                                              height: 90,
                                              color: baseColor3,
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 25),
                                                    child: Text(
                                                      "${data[index].employee != null ? data[index].employee!.name : "-"}",
                                                      style: TextStyle(
                                                          color: baseColor,
                                                          fontSize: 10,
                                                          letterSpacing: 0.5,
                                                          height: 1.4,
                                                          fontFamily:
                                                              "roboto-regular"),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20, right: 10),
                                                    width: double.maxFinite,
                                                    child: Text(
                                                      "${data[index].address}",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          letterSpacing: 0.5,
                                                          height: 1.4,
                                                          color: blackColor4),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Hero(
                                                tag: "avatar-1",
                                                child: InkWell(
                                                  onTap: () {
                                                    Get.to(PhotoPage(
                                                      image: data[index].image,
                                                    ));
                                                  },
                                                  child: Container(
                                                    width: 50,
                                                    height: 50,
                                                    color: Colors.blue,
                                                    child: PhotoView(
                                                        imageProvider: NetworkImage(
                                                            "${image_url}/${data[index].image}")),
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
                            margin: EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  width: Get.mediaQuery.size.width / 2,
                                  height: 200,
                                  child: SvgPicture.asset(
                                      "assets/images/no-checkin.svg",
                                      semanticsLabel: 'Acme Logo'),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: Text(
                                    "belum ada checkin",
                                    style: TextStyle(
                                        color: blackColor4, fontSize: 14),
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
                  ),
                )
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         PageTransition(
                //             type: PageTransitionType.rightToLeft,
                //             child: TrackPage()));
                //   },
                //   child: Container(
                //     width: Get.mediaQuery.size.width,
                //     height: 118,
                //     child: Card(
                //       elevation: 3,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.only(
                //           bottomRight: Radius.circular(25),
                //           topRight: Radius.circular(25),
                //           topLeft: Radius.circular(25),
                //           bottomLeft: Radius.circular(25),
                //         ),
                //       ),
                //       child: Row(
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         children: <Widget>[
                //           Container(
                //             margin: EdgeInsets.only(
                //                 left: 30, right: 20, top: 10, bottom: 10),
                //             alignment: Alignment.centerLeft,
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: <Widget>[
                //                 Text(
                //                   "Tracking",
                //                   style: TextStyle(
                //                     color: baseColor,
                //                     fontSize: 27,
                //                     letterSpacing: 0.5,
                //                   ),
                //                 ),
                //                 Row(
                //                   children: [
                //                     Text(
                //                       "Lacak Posisimu | ",
                //                       style: TextStyle(
                //                         color: greyColor,
                //                         fontSize: 13,
                //                         letterSpacing: 0.5,
                //                       ),
                //                     ),
                //                     isTrack
                //                         ? Text(
                //                             "Active",
                //                             style: TextStyle(
                //                               color: Colors.green,
                //                               fontSize: 13,
                //                               letterSpacing: 0.5,
                //                             ),
                //                           )
                //                         : Text(
                //                             "In Active",
                //                             style: TextStyle(
                //                               color: Colors.red,
                //                               fontSize: 13,
                //                               letterSpacing: 0.5,
                //                             ),
                //                           ),
                //                   ],
                //                 )
                //               ],
                //             ),
                //           ),
                //           SizedBox(
                //             height: 40,
                //           ),
                //           Expanded(
                //             child: Container(
                //                 margin: EdgeInsets.only(right: 30),
                //                 width: double.maxFinite,
                //                 alignment: Alignment.centerRight,
                //                 child: Container(
                //                   child: Icon(
                //                     Icons.location_on,
                //                     color: baseColor,
                //                     size: 50,
                //                   ),
                //                 )),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //function

  Stream<List<CheckinModel>> watchPurchases() async* {
    var date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    var ohList = await CheckinRepository()
        .fetchChecinday(employeeId.toString(), date, date);
    yield ohList;
  }

  void checkGps() async {
    // if (!(await Geolocator().isLocationServiceEnabled())) {
    //   setState(() {
    //     gpsStatus = false;
    //   });
    // } else {
    //   // currentLocationChange();
    //   // timer = Timer.periodic(Duration(seconds: 5), (Timer t) => sendData());
    //   gpsStatus = true;
    // }
  }

  // Future<void> sendData() async {
  //   if (isTrack == true)  {
  //     await FirebaseFirestore.instance
  //         .collection('employee_locations')
  //         .doc(employeeId.toString())
  //         .update({
  //       "address": currentAddress,
  //       "latitude": currentLocation?.latitude.toString(),
  //       "longitude": currentLocation?.longitude.toString()
  //     }).then((result) {
  //       print("new USer true");
  //     }).catchError((onError) {
  //       print("onError ${onError}");
  //     });
  //   } else {
  //     print("no tra");
  //   }
  //
  //
  // }

  Future refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    getDataPref();

    setState(() {});
  }

  void getDataPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // print("employee_id${sharedPreferences.getInt("employee_id")}");
    setState(() {
      isTrack = sharedPreferences.getBool("isTrack") ?? true;
      employeeId = sharedPreferences.getInt("employee_id");
      name = sharedPreferences.getString("name");
    });
    //todayAttendance(employeeId);
    await FirebaseFirestore.instance
        .collection('employee_locations')
        .where("employee_id", isEqualTo: employeeId ?? 18)
        .get()
        .then((value) {
      setState(() {
        name = value.docs[0]['name'];
        photo = value.docs[0]['photo'];
        isTrack = value.docs[0]['is_tracked'] ?? false;
      });
    });
  }

  Future<void> GetAddressFromLatLong(double latitude, double longitude) async {
    List<loc.Placemark> placemarks =
        await loc.placemarkFromCoordinates(latitude, longitude);
    print(placemarks);
    loc.Placemark place = placemarks[0];
    setState(() {
      currentAddress =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    });
  }

  Widget _mainMenu() {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
        child: Column(
          children: [
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: <Widget>[
            //       //Tracked
            //       Container(
            //         margin: EdgeInsets.only(left: 5, right: 5),
            //         child: InkWell(
            //           onTap: () {
            //             moveCheckin(context);
            //             //moveCheckin(context);
            //             // moveTracking(context);
            //           },
            //           child: Container(
            //             child: Column(
            //               children: [
            //                 Container(
            //                   width: 70,
            //                   height: 70,
            //                   child: Card(
            //                     elevation: 1,
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.only(
            //                         bottomRight: Radius.circular(10),
            //                         topRight: Radius.circular(10),
            //                         topLeft: Radius.circular(10),
            //                         bottomLeft: Radius.circular(10),
            //                       ),
            //                     ),
            //                     child: Container(
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.center,
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         children: [
            //                           Image.asset(
            //                             "assets/images/tracking-icon.png",
            //                             width: 35,
            //                             height: 35,
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //                 Container(
            //                   child: Text(
            //                     "Checkin",
            //                     style: TextStyle(
            //                         letterSpacing: 0.5,
            //                         fontSize: 10,
            //                         fontFamily: "Roboto-regular",
            //                         color: blackColor4),
            //                   ),
            //                 )
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //       //attendances
            //       Container(
            //         margin: EdgeInsets.only(left: 5, right: 5),
            //         child: InkWell(
            //           onTap: () {
            //             moveCheckout(context);
            //             // moveAttendance(context);
            //           },
            //           child: Container(
            //             child: Column(
            //               children: [
            //                 Container(
            //                   width: 70,
            //                   height: 70,
            //                   child: Card(
            //                     elevation: 1,
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.only(
            //                         bottomRight: Radius.circular(10),
            //                         topRight: Radius.circular(10),
            //                         topLeft: Radius.circular(10),
            //                         bottomLeft: Radius.circular(10),
            //                       ),
            //                     ),
            //                     child: Container(
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.center,
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         children: [
            //                           Image.asset(
            //                             "assets/images/attendance-icon.png",
            //                             width: 35,
            //                             height: 35,
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //                 Container(
            //                   child: Text(
            //                     "Checkout",
            //                     style: TextStyle(
            //                         letterSpacing: 0.5,
            //                         fontSize: 10,
            //                         fontFamily: "Roboto-regular",
            //                         color: blackColor4),
            //                   ),
            //                 )
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //       //sick
            //       Container(
            //         margin: EdgeInsets.only(left: 5, right: 5),
            //         child: InkWell(
            //           onTap: () {
            //             moveSick(context);
            //           },
            //           child: Container(
            //             child: Column(
            //               children: [
            //                 Container(
            //                   width: 70,
            //                   height: 70,
            //                   child: Card(
            //                     elevation: 1,
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.only(
            //                         bottomRight: Radius.circular(10),
            //                         topRight: Radius.circular(10),
            //                         topLeft: Radius.circular(10),
            //                         bottomLeft: Radius.circular(10),
            //                       ),
            //                     ),
            //                     child: Container(
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.center,
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         children: [
            //                           Image.asset(
            //                             "assets/images/sick-icon.png",
            //                             width: 35,
            //                             height: 35,
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //                 Container(
            //                   child: Text(
            //                     "Long Shift",
            //                     style: TextStyle(
            //                         letterSpacing: 0.5,
            //                         fontSize: 10,
            //                         fontFamily: "Roboto-regular",
            //                         color: blackColor4),
            //                   ),
            //                 )
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //       Container(
            //         margin: EdgeInsets.only(left: 5, right: 5),
            //         child: InkWell(
            //           onTap: () {
            //             //moveCheckin(context);
            //             moveTracking(context);
            //           },
            //           child: Container(
            //             child: Column(
            //               children: [
            //                 Container(
            //                   width: 70,
            //                   height: 70,
            //                   child: Card(
            //                     elevation: 1,
            //                     shape: RoundedRectangleBorder(
            //                       borderRadius: BorderRadius.only(
            //                         bottomRight: Radius.circular(10),
            //                         topRight: Radius.circular(10),
            //                         topLeft: Radius.circular(10),
            //                         bottomLeft: Radius.circular(10),
            //                       ),
            //                     ),
            //                     child: Container(
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.center,
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         children: [
            //                           Image.asset(
            //                             "assets/images/tracking-icon.png",
            //                             width: 35,
            //                             height: 35,
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //                 Container(
            //                   child: Text(
            //                     "Tracking",
            //                     style: TextStyle(
            //                         letterSpacing: 0.5,
            //                         fontSize: 10,
            //                         fontFamily: "Roboto-regular",
            //                         color: blackColor4),
            //                   ),
            //                 )
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //
            //     ],
            //   ),
            // ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //Tracked
                  Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child: InkWell(
                      onTap: () {
                        //moveCheckin(context);
                        // moveTracking(context);
                      },
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/tracking-icon.png",
                                        width: 35,
                                        height: 35,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "Tracking",
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontSize: 10,
                                    fontFamily: "Roboto-regular",
                                    color: blackColor4),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  //

                  //attendances
                  Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child: InkWell(
                      onTap: () {
                        //moveAttendance(context);
                      },
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/attendance-icon.png",
                                        width: 35,
                                        height: 35,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "Kehadiran",
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontSize: 10,
                                    fontFamily: "Roboto-regular",
                                    color: blackColor4),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  //sick
                  Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child: InkWell(
                      onTap: () {
                        //moveSick(context);
                      },
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/sick-icon.png",
                                        width: 35,
                                        height: 35,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "Sakit",
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontSize: 10,
                                    fontFamily: "Roboto-regular",
                                    color: blackColor4),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  //permission
                  Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child: InkWell(
                      onTap: () {
                        // movePermission(context);
                      },
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/permission-icon.png",
                                        width: 35,
                                        height: 35,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "Izin",
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontSize: 10,
                                    fontFamily: "Roboto-regular",
                                    color: blackColor4),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  //leave
                  Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child: InkWell(
                      onTap: () {
                        //  moveLeave(context);
                      },
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/leave-icon.png",
                                        width: 35,
                                        height: 35,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "Cuti",
                                style: TextStyle(
                                    letterSpacing: 0.5,
                                    fontSize: 10,
                                    fontFamily: "Roboto-regular",
                                    color: blackColor4),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
