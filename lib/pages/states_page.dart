import 'package:flutter/material.dart';
import '../models/state_model.dart';
import '../services/firestore_service.dart';
import 'cities_page.dart';

class StatesPage extends StatefulWidget {
  const StatesPage({super.key});

  @override
  State<StatesPage> createState() => _StatesPageState();
}

class _StatesPageState extends State<StatesPage> {
  final FirestoreService _service = FirestoreService();
  String search = "";

  // 🔥 SHOW TOP PLACES (BOTTOM SHEET)
  void showTopPlaces(String stateName) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(15),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Top Places in $stateName",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder(
                  stream: _service.getCities(stateName),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final cities = snapshot.data!;

                    return ListView.builder(
                      itemCount:
                      cities.length > 3 ? 3 : cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];

                        return ListTile(
                          leading: const Icon(Icons.place,
                              color: Colors.orange),
                          title: Text(city.name),
                          subtitle:
                          const Text("Top attractions available"),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore States and UT"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [

          //  SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search State...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() => search = value.toLowerCase());
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<StateModel>>(
              stream: _service.getStates(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final states = snapshot.data!
                    .where((s) =>
                    s.name.toLowerCase().contains(search))
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: states.length,
                  itemBuilder: (context, index) {
                    final state = states[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CitiesPage(stateName: state.name),
                          ),
                        );
                      },

                      // 🔥 ADDED THIS (LONG PRESS)
                      onLongPress: () {
                        showTopPlaces(state.name);
                      },

                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade300,
                              Colors.deepOrange.shade400
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            state.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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