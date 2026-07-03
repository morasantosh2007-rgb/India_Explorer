import 'package:flutter/material.dart';
import '../models/famous_place_model.dart';
import '../services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FamousPlacesPage extends StatefulWidget {
  final String stateName;
  final String cityName;

  const FamousPlacesPage(
      {super.key, required this.stateName, required this.cityName});

  @override
  State<FamousPlacesPage> createState() => _FamousPlacesPageState();
}

class _FamousPlacesPageState extends State<FamousPlacesPage> {
  final FirestoreService _service = FirestoreService();
  String search = "";

  void openMap(String place) async {
    final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$place, ${widget.cityName}, ${widget.stateName}");

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search places...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() => search = value.toLowerCase());
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<FamousPlaceModel>>(
              stream: _service.getFamousPlaces(
                  widget.stateName, widget.cityName),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final places = snapshot.data!
                    .where((p) =>
                p.name.toLowerCase().contains(search) ||
                    p.type.toLowerCase().contains(search))
                    .toList();

                return ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(place.name),
                        subtitle:
                        Text("${place.type} • ${place.description}"),
                        trailing: ElevatedButton(
                          onPressed: () => openMap(place.name),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text("View"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}