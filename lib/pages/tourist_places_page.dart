import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';

class TouristPlacesPage extends StatefulWidget {
  final String stateName;
  final String cityName;

  const TouristPlacesPage({
    super.key,
    required this.stateName,
    required this.cityName,
  });

  @override
  State<TouristPlacesPage> createState() => _TouristPlacesPageState();
}

class _TouristPlacesPageState extends State<TouristPlacesPage> {
  final FirestoreService _service = FirestoreService();

  List apiPlaces = [];
  bool loading = true;
  String search = "";

  @override
  void initState() {
    super.initState();
    fetchApiPlaces();
  }

  // OPEN GOOGLE MAPS (FIXED)
  void openMap({
    required String name,
    double lat = 0,
    double lon = 0,
  }) async {
    Uri url;

    // If coordinates available → use them WITH city context
    if (lat != 0 && lon != 0) {
      url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lon(${Uri.encodeComponent(name)}, ${Uri.encodeComponent(widget.cityName)})",
      );
    }
    // Firestore → use name + city + state
    else {
      String query =
          "$name, ${widget.cityName}, ${widget.stateName}, India";

      url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}",
      );
    }

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // FETCH API
  Future<void> fetchApiPlaces() async {
    String apiKey = "9b93414646de4179a87b6a1194dcc8d3";

    try {
      String geoUrl =
          "https://api.geoapify.com/v1/geocode/search?text=${widget.cityName}, India&apiKey=$apiKey";

      final geoRes = await http.get(Uri.parse(geoUrl));
      final geoData = json.decode(geoRes.body);

      if (geoData['features'] == null ||
          geoData['features'].isEmpty) {
        setState(() => loading = false);
        return;
      }

      double lat = geoData['features'][0]['properties']['lat'];
      double lon = geoData['features'][0]['properties']['lon'];

      String url =
          "https://api.geoapify.com/v2/places?categories=tourism.sights&filter=circle:$lon,$lat,8000&limit=25&apiKey=$apiKey";

      final res = await http.get(Uri.parse(url));
      final data = json.decode(res.body);

      setState(() {
        apiPlaces = data['features'] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // 🎨 CARD UI
  Widget buildCard(
      String title,
      String subtitle,
      double lat,
      double lon,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.place, color: Colors.orange),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              openMap(
                name: title,
                lat: lat,
                lon: lon,
              );
            },
            child: const Text("View"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),

      body: Column(
        children: [

          // SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search attractions...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // FIRESTORE
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("⭐ Top Attractions",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                  StreamBuilder(
                    stream: _service.getFamousPlaces(
                        widget.stateName, widget.cityName),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final places = snapshot.data!
                          .where((p) => p.name
                          .toLowerCase()
                          .contains(search))
                          .toList();

                      return Column(
                        children: places.map<Widget>((place) {
                          return buildCard(
                            place.name,
                            place.description,
                            0,
                            0,
                          );
                        }).toList(),
                      );
                    },
                  ),

                  // 📍 API
                  if (!loading && apiPlaces.isNotEmpty) ...[

                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("📍 Nearby Attractions",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),

                    Column(
                      children: apiPlaces.where((p) {
                        final place = p['properties'];
                        String name =
                        (place['name'] ?? "").toLowerCase();

                        return name.contains(search);
                      }).map<Widget>((p) {
                        final place = p['properties'];

                        return buildCard(
                          place['name'] ??
                              place['formatted'] ??
                              "No Name",
                          place['formatted'] ?? "",
                          place['lat'] ?? 0.0,
                          place['lon'] ?? 0.0,
                        );
                      }).toList(),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}