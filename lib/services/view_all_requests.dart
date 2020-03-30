import 'dart:io';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_hestia/model/global.dart';
import 'package:http/http.dart' as http;
import 'package:project_hestia/services/shared_prefs_custom.dart';
import '../model/request.dart';
import 'package:permission_handler/permission_handler.dart';

Future<AllRequests> getAllRequests() async {
  print("I am in get all request");
  AllRequests allRequests;
  Position position;
  PermissionStatus permissionStatus =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
  if (permissionStatus != PermissionStatus.granted) {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.location]);
    if (permissions[PermissionGroup.location] != PermissionStatus.granted) {
      return AllRequests(
          message: 'Required Permissions Not Granted', request: []);
    }
  }
  try {
    ServiceStatus serviceStatus = await PermissionHandler().checkServiceStatus(PermissionGroup.location);
    if(serviceStatus == ServiceStatus.disabled){
      return AllRequests(message: 'Your location is disabled', request: []);
    }
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    if (geolocationStatus == GeolocationStatus.unknown) {
      position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.medium);
      // return AllRequests(
      //     message: 'Required Permissions Not Granted', request: []);
    }
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    final address = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(position.latitude, position.longitude));
    print(address.first.locality);
    final uri = Uri.https(
      ITEM_REQUEST_BASE_URL,
      URL_VIEW_ALL_REQUESTS,
      {'location': address.first.locality},
    );
    print("URI in all requests is "+uri.toString());
    final token = await SharedPrefsCustom().getToken();
    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: token,
      },
    );
    // print(response.statusCode);
    // print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      allRequests = allRequestsFromJson(response.body);
      allRequests.request.sort((a,b)=>b.dateTimeCreated.compareTo(a.dateTimeCreated));
    } else if (response.statusCode == 204) {
      allRequests = AllRequests(message: 'No requests found', request: []);
    } else {
      allRequests =
          AllRequests(message: 'Something\'s wrong on our end', request: []);
    }
  } catch (e) {
    print(e.toString());
  }
  return allRequests;
}
