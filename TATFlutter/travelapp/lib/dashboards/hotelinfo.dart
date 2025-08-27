
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class HotelInfoPage extends StatefulWidget {
//   final String placeName;

//   const HotelInfoPage({super.key, required this.placeName});

//   @override
//   State<HotelInfoPage> createState() => _HotelInfoPageState();
// }

// class _HotelInfoPageState extends State<HotelInfoPage> {
//   DateTime? checkInDate;
//   DateTime? checkOutDate;
//   int numberOfPeople = 1;

//   bool isLoading = false;
//   String? errorMessage;
//   List<dynamic> hotels = [];

//   Future<void> pickDate(bool isCheckIn) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );

//     if (picked != null) {
//       setState(() {
//         if (isCheckIn) {
//           checkInDate = picked;
//           if (checkOutDate != null && checkOutDate!.isBefore(checkInDate!)) {
//             checkOutDate = null;
//           }
//         } else {
//           checkOutDate = picked;
//         }
//       });
//     }
//   }

//   String formatDate(DateTime? date) {
//     if (date == null) return 'Select';
//     return DateFormat('yyyy-MM-dd').format(date);
//   }

//   Future<String?> getGeoId(String placeName) async {
//     final uri = Uri.parse(
//       'https://tripadvisor16.p.rapidapi.com/api/v1/hotels/searchLocation?query=$placeName',
//     );

//     try {
//       final response = await http.get(
//         uri,
//         headers: {
//           'X-RapidAPI-Key': 'e4dae3eed6msh6b1f7cc254e7d77p1a2dd2jsn5a3a0fb89596',
//           'X-RapidAPI-Host': 'tripadvisor16.p.rapidapi.com',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print("📍 Location search response: $data");

      
        
//         final geoId = data['data']?[0]?['geoId'];
//         return geoId?.toString();
//       } else {
//         setState(() {
//           errorMessage =
//               'Failed to fetch location ID. Status code: ${response.statusCode}';
//         });
//         return null;
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Exception fetching location ID: $e';
//       });
//       return null;
//     }
//   }

//   Future<void> fetchHotels() async {
//     if (checkInDate == null || checkOutDate == null) {
//       setState(() {
//         errorMessage = "Please select both check-in and check-out dates.";
//       });
//       return;
//     }

//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//       hotels = [];
//     });

//     final geoId = await getGeoId(widget.placeName);
//     if (geoId == null) {
//       setState(() {
//         isLoading = false;
//         errorMessage = "Could not get location geoId.";
//       });
//       return;
//     }

//     final checkInStr = formatDate(checkInDate);
//     final checkOutStr = formatDate(checkOutDate);

//     final uri = Uri.parse(
//       'https://tripadvisor16.p.rapidapi.com/api/v1/hotels/searchHotels'
//       '?geoId=$geoId&checkIn=$checkInStr&checkOut=$checkOutStr&pageNumber=1&currencyCode=NRP',
//     );

//     try {
//       final response = await http.get(
//         uri,
//         headers: {
//           'X-RapidAPI-Key': 'e4dae3eed6msh6b1f7cc254e7d77p1a2dd2jsn5a3a0fb89596',
//           'X-RapidAPI-Host': 'tripadvisor16.p.rapidapi.com',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print("🏨 Hotels response: $data");

//         setState(() {
//           hotels = data['data']?['data'] ?? [];
//         });
//       } else {
//         print('🔥 Response Code: ${response.statusCode}');
//         print('🔥 Response Body: ${response.body}');
//         setState(() {
//           errorMessage =
//               'Failed to fetch hotels. Status code: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = "Exception fetching hotels: $e";
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Widget buildHotelItem(dynamic hotel) {
//     final name = hotel['title'] ?? 'Unknown';
//     final primaryInfo = hotel['primaryInfo'] ?? '';
//     final rating = hotel['bubbleRating']?['rating']?.toString() ?? 'N/A';
//     final ratingCount = hotel['bubbleRating']?['count'] ?? '';
//     final price = hotel['priceForDisplay'] ?? 'N/A';

//     final photoUrlTemplate =
//         hotel['cardPhotos']?[0]?['sizes']?['urlTemplate'] ?? '';

//     final photoUrl = photoUrlTemplate.isNotEmpty
//         ? photoUrlTemplate.replaceAll('{width}', '100').replaceAll('{height}', '60')
//         : null;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         leading: photoUrl != null
//             ? Image.network(photoUrl, width: 100, fit: BoxFit.cover)
//             : const SizedBox(width: 100, child: Icon(Icons.hotel)),
//         title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text('$primaryInfo\nRating: $rating ($ratingCount)'),
//         trailing: Text(price,
//             style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Find Hotels')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade400),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: InkWell(
//                           onTap: () => pickDate(true),
//                           child: Padding(
//                             padding: const EdgeInsets.all(14),
//                             child: Text(
//                               'Check-in\n${formatDate(checkInDate)}',
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(width: 1, height: 50, color: Colors.grey.shade400),
//                       Expanded(
//                         child: InkWell(
//                           onTap: () => pickDate(false),
//                           child: Padding(
//                             padding: const EdgeInsets.all(14),
//                             child: Text(
//                               'Check-out\n${formatDate(checkOutDate)}',
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Divider(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Column(
//                       children: [
//                         const Text('Number of People'),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 if (numberOfPeople > 1) {
//                                   setState(() => numberOfPeople--);
//                                 }
//                               },
//                               icon: const Icon(Icons.remove_circle),
//                             ),
//                             Text('$numberOfPeople',
//                                 style: const TextStyle(fontSize: 18)),
//                             IconButton(
//                               onPressed: () => setState(() => numberOfPeople++),
//                               icon: const Icon(Icons.add_circle),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: fetchHotels,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green.shade700,
//                 minimumSize: const Size.fromHeight(50),
//               ),
//               child: const Text("Find Hotels", style: TextStyle(fontSize: 16)),
//             ),
//             const SizedBox(height: 16),
//             if (errorMessage != null)
//               Text(errorMessage!, style: const TextStyle(color: Colors.red)),
//             if (isLoading) const CircularProgressIndicator(),
//             if (!isLoading && hotels.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: hotels.length,
//                   itemBuilder: (context, index) => buildHotelItem(hotels[index]),
//                 ),
//               ),
//             if (!isLoading && hotels.isEmpty && errorMessage == null)
//               const Text('No hotels found.'),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'hoteldetails.dart';



class HotelInfoPage extends StatefulWidget {
  final String placeName;
  final double latitude;
  final double longitude;

  const HotelInfoPage({
    super.key,
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<HotelInfoPage> createState() => _HotelInfoPageState();
}

enum SortFilter { None, Price, Distance, Rating }
enum SortOrder { LowToHigh, HighToLow }

class _HotelInfoPageState extends State<HotelInfoPage> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int numberOfPeople = 1;

  bool isLoading = false;
  String? errorMessage;
  List<dynamic> hotels = [];

  SortFilter selectedFilter = SortFilter.None;
  SortOrder selectedOrder = SortOrder.LowToHigh;

  final String username = 'saudsunil205_testAPI';
  final String password = 'saudsunil205Test@2025';

  Future<void> pickDate(bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
          if (checkOutDate != null && checkOutDate!.isBefore(checkInDate!)) {
            checkOutDate = null;
          }
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Select';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void applyFilter() {
    if (selectedFilter == SortFilter.None) return;

    Comparator<dynamic> comparator;

    switch (selectedFilter) {
      case SortFilter.Price:
        comparator = (a, b) {
          double aPrice = double.tryParse(a['total'].toString()) ?? 0;
          double bPrice = double.tryParse(b['total'].toString()) ?? 0;
          return aPrice.compareTo(bPrice);
        };
        break;
      case SortFilter.Distance:
        comparator = (a, b) {
          double aDist = (a['distanceValue'] ?? 0).toDouble();
          double bDist = (b['distanceValue'] ?? 0).toDouble();
          return aDist.compareTo(bDist);
        };
        break;
      case SortFilter.Rating:
        comparator = (a, b) {
          double aRate = double.tryParse(a['hotelRating']?.toString() ?? '') ?? 0;
          double bRate = double.tryParse(b['hotelRating']?.toString() ?? '') ?? 0;
          return aRate.compareTo(bRate);
        };
        break;
      default:
        return;
    }

    hotels.sort(comparator);
    if (selectedOrder == SortOrder.HighToLow) {
      hotels = hotels.reversed.toList();
    }
  }

  Future<void> fetchHotels() async {
    if (checkInDate == null || checkOutDate == null) {
      setState(() => errorMessage = "Please select check-in and check-out dates.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      hotels = [];
    });

    final url = Uri.parse("https://travelnext.works/api/hotel-api-v6/hotel_search");

    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "user_id": username,
      "user_password": password,
      "access": "Test",
      "ip_address": "160.250.254.141",
      "requiredCurrency": "NPR",
      "nationality": "NP",
      "checkin": formatDate(checkInDate),
      "checkout": formatDate(checkOutDate),
      "latitude": widget.latitude,
      "longitude": widget.longitude,
      "city_name": widget.placeName,
      "country_name": "Nepal",
      "radius": 30,
      "maxResult": 20,
      "hotelCodes": [],
      "occupancy": [
        {
          "room_no": 1,
          "adult": numberOfPeople,
          "child": 0,
          "child_age": [0]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);

      print("🏨 Hotel Search Raw Response: $data");

      final result = data["itineraries"];
      if (result != null && result is List) {
        setState(() {
          hotels = result;
          applyFilter();
        });
      } else {
        setState(() => errorMessage = "No hotels found.");
      }
    } catch (e) {
      setState(() => errorMessage = "Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Widget buildHotelItem(dynamic hotel) {
  //   final name = hotel['hotelName'] ?? 'Unknown Hotel';
  //   final address = hotel['address'] ?? 'No address';
  //   final rating = hotel['hotelRating']?.toString() ?? 'N/A';
  //   final price = hotel['total']?.toString() ?? 'N/A';
  //   final currency = hotel['currency'] ?? 'NPR';
  //   final imageUrl = hotel['thumbNailUrl'] ?? '';

  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     child: ListTile(
  //       leading: imageUrl.isNotEmpty
  //           ? Image.network(imageUrl, width: 100, fit: BoxFit.cover)
  //           : const Icon(Icons.hotel, size: 40),
  //       title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
  //       subtitle: Text('$address\n⭐ Rating: $rating'),
  //       trailing: Text('$currency $price',
  //           style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
  //     ),
  //   );
  // }
  Widget buildHotelItem(dynamic hotel) {
  final name = hotel['hotelName'] ?? 'Unknown Hotel';
  final address = hotel['address'] ?? 'No address';
  final rating = hotel['hotelRating']?.toString() ?? 'N/A';
  final price = hotel['total']?.toString() ?? 'N/A';
  final currency = hotel['currency'] ?? 'NPR';
  final imageUrl = hotel['thumbNailUrl'] ?? '';

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HotelDetailsPage(hotelData: hotel,
          checkInDate: checkInDate!,
          checkOutDate: checkOutDate!,
          numberOfPeople: numberOfPeople,),
        ),
      );
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? Image.network(imageUrl, width: 100, fit: BoxFit.cover)
            : const Icon(Icons.hotel, size: 40),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$address\n⭐ Rating: $rating'),
        trailing: Text('$currency $price',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    ),
  );
}


  Widget buildFilterButton(SortFilter filterType, String label) {
    bool isSelected = (selectedFilter == filterType);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (filterType == SortFilter.None) {
              selectedFilter = SortFilter.None;
              selectedOrder = SortOrder.LowToHigh;
            } else if (selectedFilter == filterType) {
              selectedOrder = selectedOrder == SortOrder.LowToHigh
                  ? SortOrder.HighToLow
                  : SortOrder.LowToHigh;
            } else {
              selectedFilter = filterType;
              selectedOrder = SortOrder.LowToHigh;
            }
            applyFilter();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade700 : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? Colors.green.shade900 : Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isSelected && filterType != SortFilter.None) ...[
                const SizedBox(width: 4),
                Icon(
                  selectedOrder == SortOrder.LowToHigh
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search hotels for ${widget.placeName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(true),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              'Check-in\n${formatDate(checkInDate)}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 50, color: Colors.grey.shade400),
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(false),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              'Check-out\n${formatDate(checkOutDate)}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        const Text('Number of People'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (numberOfPeople > 1) {
                                  setState(() => numberOfPeople--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle),
                            ),
                            Text('$numberOfPeople', style: const TextStyle(fontSize: 18)),
                            IconButton(
                              onPressed: () => setState(() => numberOfPeople++),
                              icon: const Icon(Icons.add_circle),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchHotels,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Find Hotels",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1.5),
            const SizedBox(height: 8),
            Row(
              children: [
                buildFilterButton(SortFilter.None, 'None'),
                buildFilterButton(SortFilter.Distance, 'Distance'),
                buildFilterButton(SortFilter.Rating, 'Rating'),
                buildFilterButton(SortFilter.Price, 'Price'),
              ],
            ),
            const SizedBox(height: 12),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            if (isLoading)
              const CircularProgressIndicator(),
            if (!isLoading && hotels.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: hotels.length,
                  itemBuilder: (context, index) => buildHotelItem(hotels[index]),
                ),
              ),
            if (!isLoading && hotels.isEmpty && errorMessage == null)
              const Text('No hotels found.'),
          ],
        ),
      ),
    );
  }
}
