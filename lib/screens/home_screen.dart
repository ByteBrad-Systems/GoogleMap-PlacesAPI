import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:map_widget/screens/map_screen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title = 'Map Widget Demo', this.location = ''}) : super(key: key);
  final String title;
  final String? location;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var address;
  TextEditingController location = TextEditingController();
  getCurrentLocationAddress() async {
    address = await placemarkFromCoordinates(40.2085, -3.7130);
    setState(() {
      location.text = address[0].country.toString();
      print('location: ${location.text}');
    });
  }

  @override
  void initState() {
    super.initState();
    widget.location != '' ?
    location.text = widget.location ?? '' : getCurrentLocationAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: TextStyle(color: Colors.black),), backgroundColor: Colors.white, elevation: 0.0,),
      body: Padding(
        padding: const EdgeInsets.only(left:20.0, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
              elevation: 10,
              shadowColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              child: TextFormField(
                controller: location,
                readOnly: true,
                style: TextStyle(color: Colors.black),
                onTap: (){
                  // Get.toNamed('/MapWidget');
                  Get.to(() => MapScreen());
                },
                decoration: InputDecoration(
                  hintText: location.text == 'Spain' ? 'Default Location':'Selected Location',
                  labelText: location.text == 'Spain' ? 'Default Location':'Selected Location',
                  prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
