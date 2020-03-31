import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_hestia/model/global.dart';
import 'package:ant_icons/ant_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:project_hestia/screens/home_screen.dart';
import 'package:project_hestia/screens/login.dart';
import 'package:project_hestia/model/util.dart';
import 'package:project_hestia/services/shared_prefs_custom.dart';
import 'package:project_hestia/widgets/my_back_button.dart';

class CreateShopSuggestionScreen extends StatefulWidget {
  CreateShopSuggestionScreen({@required this.userID, @required this.itemName});
  final userID, itemName;
  @override
  _CreateShopSuggestionScreenState createState() => _CreateShopSuggestionScreenState();
}

class _CreateShopSuggestionScreenState extends State<CreateShopSuggestionScreen> {
  _CreateShopSuggestionScreenState({this.userID, this.itemName});

  final String userID, itemName;

  TextEditingController nameController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController extraController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  bool isLoading = false;

  Map<String, String> suggestionInfo = {
    "recommended_for":"1",
    "name_of_shop": "Shanti Medical",
    "phone_number": "68794039245",
    "landmark": "Chettinad Hospital",
    "extra_instruction": "Go towards the right bifurcation at the end of the avenue, shop should be at the right",
    "description_of_shop": "Sanitizers, medicines, and masks available",
    "item":"hn"
  };


  Future _createSuggestion() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    // final id  = await SharedPrefsCustom().getUserId();
    suggestionInfo['recommended_for']= widget.userID;
    suggestionInfo['item']=widget.itemName;
    setState(() {
      isLoading = true;
    });
    String content = "";
    try {
      print("Body sent to add shop suggestion is "+suggestionInfo.toString());
      final token = await SharedPrefsCustom().getToken();
      final response = await http.post(URL_SHOW_CREATE_SUGGESTIONS, body: jsonEncode(suggestionInfo), headers: {HttpHeaders.authorizationHeader: token,"Content-Type": "application/json"});
      print("Response is "+response.toString());
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      print(responseBody.toString());
      if (response.statusCode==201) {
        Fluttertoast.showToast(msg: "Successfully added");
        Navigator.pop(context);
        Navigator.of(context).canPop();
      } else {
        Fluttertoast.showToast(msg: responseBody['message']);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme.copyWith(color: colorBlack),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  MyBackButton(),
                  SizedBox(width: 25,),
                  Text(
                    'Suggest a Shop',
                    style: screenHeadingStyle,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Shop Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          gapPadding: 10,
                        ),
                      ),
                      // onChanged: (value) => _itemNameController.text = value,
                      onSaved: (value) => suggestionInfo['name_of_shop'] = value,
                      validator: (value) {
                        if (value == "") {
                          return "This field is required";
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      // textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          gapPadding: 10,
                        ),
                      ),
                      // onChanged: (value) => _quantityController.text = value,
                      onSaved: (value) => suggestionInfo['phone_number'] = value,
                      validator: (value) {
                        if (value == "") {
                          return "This field is required";
                        }
                        else if(value.length!=10){
                          return "Enter correct phone number";
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: descController,
                      // textCapitalization: TextCapitalization.words,
                      maxLines: 3,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: 'Description of the shop',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          gapPadding: 10,
                        ),
                      ),
                      // onChanged: (value) => _itemNameController.text = value,
                      onSaved: (value) => suggestionInfo['description_of_shop'] = value,
                      validator: (value) {
                        if (value == "") {
                          return "This field is required";
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: landmarkController,
                      textCapitalization: TextCapitalization.words,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: 'Landmark',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          gapPadding: 10,
                        ),
                      ),
                      // onChanged: (value) => _itemNameController.text = value,
                      onSaved: (value) => suggestionInfo['landmark'] = value,
                      validator: (value) {
                        if (value == "") {
                          return "This field is required";
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: extraController,
                      autocorrect: true,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Extra Instruction',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          gapPadding: 10,
                        ),
                      ),
                      // onChanged: (value) => _itemNameController.text = value,
                      onSaved: (value) => suggestionInfo['extra_instruction'] = value,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  (isLoading)
                      ? CircularProgressIndicator()
                      : RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          color: mainColor,
                          textColor: colorWhite,
                          onPressed: _createSuggestion,
                          child: Text('Submit'),
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    color: colorWhite,
                    textColor: mainColor,
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
