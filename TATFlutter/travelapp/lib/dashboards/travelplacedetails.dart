
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';

// class TravelPlaceDetailsPage extends StatefulWidget {
//   final int placeId;
//   const TravelPlaceDetailsPage({super.key, required this.placeId});

//   @override
//   State<TravelPlaceDetailsPage> createState() => _TravelPlaceDetailsPageState();
// }

// class _TravelPlaceDetailsPageState extends State<TravelPlaceDetailsPage> {
//   Map<String, dynamic>? place;
//   double? distanceInKm;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchPlaceDetails();
//   }

//  Future<Position> getUserLocation() async {
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {throw Exception('Location services are disabled.');}

//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       throw Exception('Location permission denied.');
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     throw Exception('Location permission permanently denied.');
//   }

//    return await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.medium, // or .high
//   );

  
// }


//   Future<void> fetchPlaceDetails() async {
//     final url = Uri.parse("http://192.168.18.7:8000/user/travel-places/${widget.placeId}/");

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       try {
//         final data = jsonDecode(response.body);

//         final userPosition = await getUserLocation();
//         final double placeLat = double.tryParse(data['latitude'].toString()) ?? 0.0;
//         final double placeLng = double.tryParse(data['longitude'].toString()) ?? 0.0;

//         final distance = Geolocator.distanceBetween(
//           userPosition.latitude,
//           userPosition.longitude,
//           placeLat,
//           placeLng,
//         );

//         setState(() {
//           place = data;
//           distanceInKm = distance / 1000;
//           isLoading = false;
//         });
//       } catch (e) {
//         print("❌ Error: $e");
//       }
//     } else {
//       print("❌ Failed to load place. Status: ${response.statusCode}");
//     }
//   }

//   Widget buildInfoRow(String title, dynamic value) {
//     if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10.0),
//       child: RichText(
//         text: TextSpan(
//           style: const TextStyle(fontSize: 15, color: Colors.black),
//           children: [
//             TextSpan(
//               text: "$title: ",
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
             
//             ),
//             TextSpan(
//               text: value.toString(),
            
//                       ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading || place == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     List<String> imageUrls = [];
//     if (place!['cover_image'] != null) {
//       imageUrls.add(place!['cover_image']);
//     }
//     if (place!['images'] != null) {
//       for (var img in place!['images']) {
//         imageUrls.add(img['image']);
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(place!['name'] ?? 'Details'),
//       ),
//       body: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           if (imageUrls.isNotEmpty)
//             CarouselSlider(
//               options: CarouselOptions(
//                 height: 250,
//                 viewportFraction: 1.0,
//                 autoPlay: true,
//                 enlargeCenterPage: false,
//               ),
//               items: imageUrls.map((url) {
//                 return Image.network(
//                   url,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   errorBuilder: (ctx, error, stackTrace) =>
//                       const Icon(Icons.broken_image, size: 50),
//                 );
//               }).toList(),
//             ),

//           // Card with info
//           Container(
//             width: double.infinity,
//             color: Colors.grey.shade100, // light grey background
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   place!['name'],
//                   style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),

//                 // Location
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Icon(Icons.location_on, size: 20, color: Colors.grey),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         place!['location'],
//                         style: const TextStyle(
//                             color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),

//                 // Category
//                 Row(
//                   children: [
//                     const Icon(Icons.category, size: 20, color: Colors.grey),
//                     const SizedBox(width: 6),
//                     Text(
//                       place!['category'].toString().toUpperCase(),
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Distance
//                 if (distanceInKm != null)
//                   Text(
//                     "📍 ${distanceInKm!.toStringAsFixed(2)} km away",
//                     style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                   ),
//                 const SizedBox(height: 16),

//                 // Info rows
//                 buildInfoRow("Estimated cost", place!['estimated_cost']),
//                 buildInfoRow("Best time to visit", place!['best_time_to_visit']),
//                 buildInfoRow("Travel duration", place!['duration_to_visit']),
//                 buildInfoRow("Full address", place!['full_address']),

//                 const SizedBox(height: 10),

//                 // Transport
//                 const Text(
//                   "Transport",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   place!['available_transport'] ?? "No transport",
//                   style: const TextStyle(fontSize: 15),
//                   textAlign: TextAlign.justify,
//                 ),

//                 const SizedBox(height: 16),

//                 // Description
//                 const Text(
//                   "Description",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   place!['description'] ?? "No description available",
//                   style: const TextStyle(fontSize: 15),
//                   textAlign: TextAlign.justify,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import 'hotelinfo.dart';

import 'mapinfo.dart';

class TravelPlaceDetailsPage extends StatefulWidget {
  final int placeId;
  final String source;

  const TravelPlaceDetailsPage({super.key, required this.placeId, required this.source});

  @override
  State<TravelPlaceDetailsPage> createState() => _TravelPlaceDetailsPageState();
}

class _TravelPlaceDetailsPageState extends State<TravelPlaceDetailsPage> {
  Map<String, dynamic>? place;
  double? distanceInKm;
  bool isLoading = true;
  String selectedMode = 'car';

  @override
  void initState() {
    super.initState();
    fetchPlaceDetails();
  }

  Future<Position> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
  }

  Future<void> fetchPlaceDetails() async {
    final url = Uri.parse("http://10.0.2.2:8000/user/travel-places/${widget.placeId}/?source=${widget.source}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final userPosition = await getUserLocation();
        final double placeLat = double.tryParse(data['latitude'].toString()) ?? 0.0;
        final double placeLng = double.tryParse(data['longitude'].toString()) ?? 0.0;

        final distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          placeLat,
          placeLng,
        );

        setState(() {
          place = data;
          distanceInKm = distance / 1000;
          isLoading = false;
        });
      } catch (e) {
        print("❌ Error decoding JSON or location: $e");
      }
    } else {
      print("❌ Failed to fetch place: ${response.statusCode}");
    }
  }

  String estimateTravelDuration(double distanceKm, String mode) {
    double speedKmH;
    switch (mode) {
      case 'walking': speedKmH = 5; break;
      case 'bike': speedKmH = 25; break;
      case 'flight': speedKmH = 700; break;
      case 'car':
      default: speedKmH = 50;
    }
    final durationHours = distanceKm / speedKmH;
    if (durationHours < 1) {
      final minutes = (durationHours * 60).round();
      return '$minutes min';
    } else {
      final hours = durationHours.floor();
      final minutes = ((durationHours - hours) * 60).round();
      return '$hours h ${minutes.toString().padLeft(2, '0')} min';
    }
  }

  Widget buildInfoRow(String title, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.black),
          children: [
            TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextSpan(text: value.toString()),
          ],
        ),
      ),
    );
  }

  Widget buildTravelModeSelector() {
    final modes = {
      'car': Icons.directions_car,
      'bike': Icons.directions_bike,
      'walking': Icons.directions_walk,
      'flight': Icons.flight,
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: modes.entries.map((entry) {
        final isSelected = selectedMode == entry.key;
        return GestureDetector(
          onTap: () => setState(() => selectedMode = entry.key),
          child: Column(
            children: [
              Icon(entry.value, size: 30, color: isSelected ? Colors.green : Colors.grey),
              const SizedBox(height: 4),
              Text(entry.key[0].toUpperCase() + entry.key.substring(1),
                style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.green : Colors.grey)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildBottomBarItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || place == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<String> imageUrls = [];
    if (place!['cover_image'] != null) imageUrls.add(place!['cover_image']);
    if (place!['images'] != null) {
      for (var img in place!['images']) {
        imageUrls.add(img['image']);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(place!['name'] ?? 'Details')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (imageUrls.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(height: 250, viewportFraction: 1.0, autoPlay: true),
              items: imageUrls.map((url) {
                return Image.network(url, fit: BoxFit.cover, width: double.infinity,
                  errorBuilder: (ctx, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                );
              }).toList(),
            ),

          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place!['name'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    Expanded(child: Text(place!['location'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.category, color: Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    Text(place!['category'].toString().toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),

                if (distanceInKm != null)
                  Text("📍 ${distanceInKm!.toStringAsFixed(2)} km away", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),

                if (distanceInKm != null) buildTravelModeSelector(),
                const SizedBox(height: 12),

                if (distanceInKm != null)
                  buildInfoRow("Estimated travel duration", estimateTravelDuration(distanceInKm!, selectedMode)),
                const SizedBox(height: 10),

                buildInfoRow("Estimated cost", place!['estimated_cost']),
                buildInfoRow("Best time to visit", place!['best_time_to_visit']),
                buildInfoRow("Full address", place!['full_address']),
                const SizedBox(height: 10),

                const Text("Transport", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(place!['available_transport'] ?? "No transport available", style: const TextStyle(fontSize: 15), textAlign: TextAlign.justify),

                const SizedBox(height: 16),
                const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(place!['description'] ?? "No description available", style: const TextStyle(fontSize: 15), textAlign: TextAlign.justify),

                const SizedBox(height: 20),
                const Divider(height: 1, color: Colors.grey),

                Container(
                  color: Colors.green.shade700,
                  height: 70,
                  child: Row(
                    children: [
                      buildBottomBarItem(
                        icon: Icons.hotel,
                        label: 'Hotels',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelInfoPage(
                              placeName: place!['name'],
                              latitude: double.tryParse(place!['latitude'].toString()) ?? 0.0,
                              longitude: double.tryParse(place!['longitude'].toString()) ?? 0.0,
                            ),
                          ),
                        ),
                      ),
                     
                      Container(width: 1, height: double.infinity, color: Colors.white54),
                      buildBottomBarItem(
                        icon: Icons.map,
                        label: 'Map',
                        onTap: () {
                          double lat = double.tryParse(place!['latitude'].toString()) ?? 0.0;
                          double lng = double.tryParse(place!['longitude'].toString()) ?? 0.0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapInfoPage(
                                latitude: lat,
                                longitude: lng,
                                label: place!['name'],
                              ),
                            ),
                          );
                        },
                      ),
                      Container(width: 1, height: double.infinity, color: Colors.white54),
                      buildBottomBarItem(
                        icon: Icons.bookmark_border,
                        label: 'Save',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to favorites')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
