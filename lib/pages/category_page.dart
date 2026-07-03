import 'package:flutter/material.dart';
import 'places_page.dart';
import 'tourist_places_page.dart';

class CategoryPage extends StatelessWidget {
  final String stateName;
  final String cityName;

  const CategoryPage({
    super.key,
    required this.stateName,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //TOURIST ATTRACTIONS (NEW HYBRID PAGE)
            buildTouristButton(context),

            // RESTAURANTS
            buildButton(
                context, "Restaurants", "catering.restaurant"),

            // HOSPITALS
            buildButton(
                context, "Hospitals", "healthcare.hospital"),
          ],
        ),
      ),
    );
  }

  // TOURIST BUTTON (SPECIAL)
  Widget buildTouristButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          backgroundColor: Colors.orange,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TouristPlacesPage(
                stateName: stateName,
                cityName: cityName,
              ),
            ),
          );
        },
        child: const Text("Tourist Attractions"),
      ),
    );
  }

  // COMMON BUTTON
  Widget buildButton(
      BuildContext context, String title, String type) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          backgroundColor: Colors.orange,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlacesPage(
                cityName: cityName,
                type: type,
              ),
            ),
          );
        },
        child: Text(title),
      ),
    );
  }
}