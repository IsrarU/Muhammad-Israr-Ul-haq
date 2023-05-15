import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ndialog/ndialog.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:userlocation/ComplaintList.dart';
import 'package:userlocation/MissingPersonList.dart';
class AddMissingPerson extends StatefulWidget {
  const AddMissingPerson({Key? key}) : super(key: key);

  @override
  State<AddMissingPerson> createState() => _AddComplaintState();
}

class _AddComplaintState extends State<AddMissingPerson> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController contactController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  String date = "";
  XFile? image;

  List _images = [];

  final ImagePicker picker = ImagePicker();
  var img;

  selectImage(ImageSource media) async
  {
    img = await picker.pickImage(source: media);
  }
  //we can upload image from camera or from gallery based on parameter
  Future sendImage() async {



    var uri = "https://jafasa.com/WomenSafety/api/addMissingPerson.php";

    var request = http.MultipartRequest('POST', Uri.parse(uri));


    if(img != null){

      var pic = await http.MultipartFile.fromPath("image", img.path);
      request.fields['name'] = nameController.text;
      request.fields['contact'] = contactController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['date'] = date;


      request.files.add(pic);

      await request.send().then((result) {

        http.Response.fromStream(result).then((response) {

          var message = jsonDecode(response.body);

          // show snackbar if input data successfully
          final snackBar = SnackBar(content: Text(message['message']));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          //get new list images
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MissingPersonList()));

        });

      }).catchError((e) {

        print(e);

      });
    }

  }

  //show popup dialog
  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select'),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.gallery);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ProgressDialog dialog = new ProgressDialog(context, title: Text("Missing Person"),
        message: Text("Missing Person is Uploading . Please wait ..."));
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Missing Person"),
        elevation: 10.0,
        backgroundColor: Colors.teal[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Add Missing Person',
                      style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w500,
                          fontSize: 26),
                    )),

                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Name',
                    ),

                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Contact',
                    ),

                  ),
                ),

                InkWell(
                  onTap: (){
                        DatePicker.showDatePicker(context,
                                   showTitleActions: true,
                                   minTime: DateTime(2018, 3, 5),
                                   maxTime: DateTime(2023, 3, 15),
                                   theme: DatePickerTheme(
                                   headerColor: Colors.deepOrangeAccent,
                                   backgroundColor: Colors.teal,
                                  itemStyle: TextStyle(
                                 color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                                   doneStyle:
                                 TextStyle(color: Colors.white, fontSize: 16)),
                                  onChanged: (date) {
                                  this.date = "${date.day}-${date.month}-${date.year}";
                                 print('change $date in time zone ' +
                                 date.timeZoneOffset.inHours.toString());
                                }, onConfirm: (date) {
                              this.date = "${date.day}-${date.month}-${date.year}";
                                print('confirm $date');
                                 }, currentTime: DateTime.now(), locale: LocaleType.en);
                                 },

                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      enabled: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Date',
                        suffixIcon: Icon(Icons.date_range)

                      ),

                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 5, //or null

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Description',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                SizedBox(height: 8.0,),
                InkWell(
                  onTap: (){
                    myAlert();
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: TextField(



                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.photo_camera),

                        labelText: 'Select Image',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: false,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04,),
                Text("براہ کرم ! غلط قسم کی معلومات کا اندراج کرنے سے اجتناب کریں-", style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.red),
                ),
                Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[700],
                                  foregroundColor: Colors.white
                              ),
                              onPressed: (){
                                dialog.show();

                                sendImage();


                              }, child: Text("Add Missing Person")))),


                    ],
                  ),
                ),

              ],
            )),
      ),
    );
  }


}

