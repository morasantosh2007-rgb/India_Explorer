import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PlacesPage extends StatefulWidget {
  final String cityName;
  final String type;

  const PlacesPage({
    super.key,
    required this.cityName,
    required this.type,
  });

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  List places = [];
  bool loading = true;
  String search = "";

  @override
  void initState() {
    super.initState();
    getPlaces();
  }

  // 📍 OPEN GOOGLE MAPS
  void openMap(double lat, double lon) async {
    final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lon");

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> getPlaces() async {
    String apiKey = "9b93414646de4179a87b6a1194dcc8d3";

    try {
      // 🔥 STEP 1: GET CITY COORDINATES
      String geoUrl =
          "https://api.geoapify.com/v1/geocode/search?text=${widget.cityName}, India&apiKey=$apiKey";

      final geoResponse = await http.get(Uri.parse(geoUrl));
      final geoData = json.decode(geoResponse.body);

      if (geoData['features'] == null ||
          geoData['features'].isEmpty) {
        setState(() => loading = false);
        return;
      }

      double lat = geoData['features'][0]['properties']['lat'];
      double lon = geoData['features'][0]['properties']['lon'];

      // 🔥 STEP 2: FETCH PLACES (IMPROVED)
      String placesUrl =
          "https://api.geoapify.com/v2/places?categories=${widget.type}&filter=circle:$lon,$lat,3000&bias=proximity:$lon,$lat&limit=20&apiKey=$apiKey";

      final response = await http.get(Uri.parse(placesUrl));
      final data = json.decode(response.body);

      List rawPlaces = data['features'] ?? [];

      // 🔥 STEP 3: FILTER ONLY CURRENT CITY
      List filteredPlaces = rawPlaces.where((p) {
        final place = p['properties'];

        String address =
        (place['formatted'] ?? "").toLowerCase();

        return address.contains(widget.cityName.toLowerCase());
      }).toList();

      setState(() {
        places = filteredPlaces;
        loading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => loading = false);
    }
  }

  // 🎨 ICON BASED ON TYPE
  IconData getIcon() {
    if (widget.type.contains("tourism")) return Icons.place;
    if (widget.type.contains("restaurant")) return Icons.restaurant;
    if (widget.type.contains("hospital")) return Icons.local_hospital;
    return Icons.location_on;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
        backgroundColor: Colors.orange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search places...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          // 📋 LIST
          Expanded(
            child: places.isEmpty
                ? const Center(
                child: Text(
                    "No places found for this city"))
                : ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place =
                places[index]['properties'];

                String name =
                (place['name'] ??
                    place['formatted'] ??
                    "")
                    .toLowerCase();

                String address =
                (place['formatted'] ?? "")
                    .toLowerCase();

                // 🔥 SEARCH FILTER (name + address)
                if (!name.contains(search) &&
                    !address.contains(search)) {
                  return const SizedBox();
                }

                double lat =
                    place['lat'] ?? 0.0;
                double lon =
                    place['lon'] ?? 0.0;

                return Card(
                  elevation: 4,
                  margin:
                  const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      getIcon(),
                      color: Colors.orange,
                    ),
                    title: Text(
                      place['name'] ??
                          place['formatted'] ??
                          "No Name",
                      style: const TextStyle(
                          fontWeight:
                          FontWeight.bold),
                    ),
                    subtitle: Text(
                      place['formatted'] ??
                          "No address",
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                          Icons.map,
                          color: Colors.green),
                      onPressed: () {
                        openMap(lat, lon);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}