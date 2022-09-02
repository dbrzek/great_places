import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../helpers/location_helper.dart';
import '../screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  //const LocationInput({ Key? key }) : super(key: key);
  final Function onSelectPlace;

  LocationInput(this.onSelectPlace);

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;

  Future<void> userPermisionToLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  } // kod do otrzymania zgodyn na użycie lokalizatora GPS

  void setPreviewImageUrl(double lat, double lng, String staticMapImageUrl) {
    setState(() {
      _previewImageUrl = staticMapImageUrl;
      widget.onSelectPlace(lat, lng);
    });
  }

  Future<void> getCurrentUserLocation() async {
    userPermisionToLocation();
    Location location = new Location();
    LocationData _locationData;

    try {
      _locationData = await location.getLocation();
    } catch (error) {
      return;
    }
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitude: _locationData.latitude, longitude: _locationData.longitude);
    print(_locationData.latitude);
    print(_locationData.longitude);
    setPreviewImageUrl(_locationData.latitude, _locationData.longitude, staticMapImageUrl);
    // setState(() {
    //   _previewImageUrl = staticMapImageUrl;
    //   widget.onSelectPlace(_locationData.latitude, _locationData.longitude);
    // });
  }

  Future<void> _selectOnMap() async {
    userPermisionToLocation();
    
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
    print(selectedLocation.latitude);
    print(selectedLocation.longitude);
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude);
    setPreviewImageUrl(selectedLocation.latitude, selectedLocation.longitude, staticMapImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _previewImageUrl == null
              ? Text(
                  'No location chosen.',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl, // wyświetlenie obrazu wygenerowanego za pomocą adresu http
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton.icon(
              icon: Icon(
                Icons.location_on,
              ),
              onPressed: getCurrentUserLocation,
              label: Text('Current Location'),
              textColor: Theme.of(context).primaryColor,
            ),
            FlatButton.icon(
              icon: Icon(
                Icons.map,
              ),
              onPressed: _selectOnMap,
              label: Text('Select on Map'),
              textColor: Theme.of(context).primaryColor,
            ),
          ],
        )
      ],
    );
  }
}
