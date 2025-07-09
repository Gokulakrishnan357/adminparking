import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String googleApiKey = "AIzaSyDxV3x0-Ra1FsFY2m2wPPwEbGAPNDbSSEQ";

class LiveLocationMap extends StatefulWidget {
  final LatLng initialLocation;

  const LiveLocationMap({super.key, required this.initialLocation});

  @override
  LiveLocationMapState createState() => LiveLocationMapState();
}

class LiveLocationMapState extends State<LiveLocationMap> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  String _currentAddress = "Fetching address...";
  bool _isLoading = true;
  LatLng? _currentLatLng;
  Placemark? _currentPlacemark;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  final Set<Marker> _markers = {};

  RxString latitude = 'Getting Latitude...'.obs;
  RxString longitude = 'Getting Longitude...'.obs;
  RxString currentAddress = 'Getting Address...'.obs;
  RxString currentCity = 'Getting City...'.obs;
  RxString formattedAddress = 'Getting City...'.obs;

  bool _isSearching = false;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLatLng = currentLatLng;
        _selectedLocation = currentLatLng;
        _isLoading = false;
      });

      _updateLocation(currentLatLng);

      _controller?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 17));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLocation(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        _currentPlacemark = placemarks.first;

        setState(() {
          _selectedLocation = latLng;
          _currentAddress =
              "${_currentPlacemark?.name ?? ''}, ${_currentPlacemark?.thoroughfare ?? ''}, "
              "${_currentPlacemark?.subLocality ?? ''}, ${_currentPlacemark?.locality ?? ''}, "
              "${_currentPlacemark?.postalCode ?? ''} ${_currentPlacemark?.administrativeArea ?? ''}";
          _markers.clear();
          _markers.add(
            Marker(markerId: const MarkerId('selected'), position: latLng),
          );
        });
      }
    } catch (e) {
      debugPrint('Failed to get address: $e');
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null && _currentPlacemark != null) {
      double selectedLat = _selectedLocation!.latitude;
      double selectedLon = _selectedLocation!.longitude;

      // Update formatted address to include only administrative area and locality
      formattedAddress.value =
          "${_currentPlacemark?.subLocality ?? ''}, ${_currentPlacemark?.locality ?? ''}";

      latitude.value = selectedLat.toString();
      longitude.value = selectedLon.toString();
      currentCity.value = _currentPlacemark?.locality ?? 'Unknown City';

      // Pass back only the required address data
      Navigator.pop(context, {
        'address': formattedAddress.value,
        'latitude': selectedLat.toString(),
        'longitude': selectedLon.toString(),
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(query);
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "OK") {
        setState(() => _searchResults = data["predictions"]);
      }
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "OK") {
        final location = data["result"]["geometry"]["location"];
        LatLng newLocation = LatLng(location["lat"], location["lng"]);

        setState(() {
          _selectedLocation = newLocation;
        });

        _updateLocation(newLocation);
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 17));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _controller = controller,
            markers: _markers,
            onTap: _updateLocation,
          ),

          // Search bar overlay
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(6),
                  child: TextFormField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 16,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Search your location here...",
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF777E90),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF858585),
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.mic_none_outlined,
                          color: Color(0xFF858585),
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                const SizedBox(height: 8),
                if (_searchResults.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_searchResults[index]["description"]),
                          onTap: () {
                            _getPlaceDetails(_searchResults[index]["place_id"]);
                            setState(() => _searchResults.clear());
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Confirm location UI at bottom
          if (!_isSearching)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 342,
                width: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/Png/locationicon.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          // Wrap the Text widget with Expanded
                          child: Text(
                            "You're Location",
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            overflow:
                                TextOverflow
                                    .ellipsis, // Add ellipsis in case the text overflows
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentPlacemark != null
                              ? "${_currentPlacemark?.subLocality ?? ''}, ${_currentPlacemark?.locality ?? ''}"
                              : "",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        right: 40,
                        left: 80,
                      ),
                      child: GestureDetector(
                        onTap: _getUserLocation,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.my_location,
                              color: Color(0xFF418612),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Use Current Location",
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF418612),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 40, 0, 10),
                      child: SizedBox(
                        width: 298,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _confirmLocation,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0C448E), Color(0xFF0C448E)],
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 22,
                              ),
                              child: Text(
                                "Confirm",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
