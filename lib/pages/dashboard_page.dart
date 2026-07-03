import 'package:flutter/material.dart';
import 'states_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            // CONTENTS SECTION
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "🇮🇳 Incredible India",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "A land of heritage, culture, diversity and endless beauty",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // QUICK FACTS (horizontal scroll)
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  InfoTile("Capital", "New Delhi"),
                  InfoTile("Population", "1.4B+"),
                  InfoTile("States", "28"),
                  InfoTile("Languages", "1000+"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "India is one of the world's oldest civilizations, rich in culture, traditions, architecture and natural beauty. From the Himalayas to beaches, every place tells a story.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StatesPage()),
                  );
                },
                child: const Text("Explore India",
                    style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//  SMALL TILE
class InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const InfoTile(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}