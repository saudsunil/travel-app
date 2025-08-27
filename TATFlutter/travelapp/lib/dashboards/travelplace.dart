

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:travelapp/dashboards/travelplacedetails.dart';

// class TravelPlacePage extends StatefulWidget {
//   const TravelPlacePage({super.key});

//   @override
//   State<TravelPlacePage> createState() => _TravelPlacePageState();
// }

// class _TravelPlacePageState extends State<TravelPlacePage> {
//   List allPlaces = [];
//   List filteredPlaces = [];
//   List popularPlaces = [];
//   List<String> searchSuggestions = [];
//   bool isLoading = true;
//   String selectedCategory = 'All';
//   String selectedSource = 'All';
//   String searchQuery = '';

//   final List<Map<String, dynamic>> categories = [
//     {'name': 'All', 'icon': Icons.public},
//     {'name': 'mountains', 'icon': Icons.terrain},
//     {'name': 'temples', 'icon': Icons.account_balance},
//     {'name': 'rivers', 'icon': Icons.waves},
//     {'name': 'lakes', 'icon': Icons.water},
//     {'name': 'valley', 'icon': Icons.landscape},
//     {'name': 'city', 'icon': Icons.location_city},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchAllPlaces();
//     fetchPopularPlaces();
//   }

//   Future<void> fetchAllPlaces() async {
//     try {
//       final response = await http.get(Uri.parse("http://192.168.18.7:8000/user/all-travel-places/"));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final processed = data.map((e) => {
//           ...e,
//           'unique_key': '${e['id']}_${e['source'] ?? 'admin'}',
//           'category': (e['category'] ?? '').toString().toLowerCase(),
//         }).toList();

//         setState(() {
//           allPlaces = processed;
//           updateSuggestions();
//           applyFilters();
//           isLoading = false;
//         });
//       } else {
//         throw Exception("Failed to load all travel places");
//       }
//     } catch (e) {
//       debugPrint("Error loading all places: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> fetchPopularPlaces() async {
//     try {
//       final response = await http.get(Uri.parse("http://192.168.18.7:8000/user/popular-travel-places/"));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() => popularPlaces = data);
//       }
//     } catch (e) {
//       debugPrint("Error loading popular places: $e");
//     }
//   }

//   void updateSuggestions() {
//     searchSuggestions = allPlaces.map((p) => p['name'].toString()).toSet().toList();
//   }

//   void applyFilters() {
//     setState(() {
//       filteredPlaces = allPlaces.where((place) {
//         final categoryMatch = selectedCategory == 'All' || (place['category'] ?? '').toLowerCase() == selectedCategory.toLowerCase();
//         final sourceMatch = selectedSource == 'All' || (place['source'] ?? 'admin').toLowerCase() == selectedSource.toLowerCase();
//         return categoryMatch && sourceMatch;
//       }).toList();
//     });
//   }

//   void onCategorySelected(String category) {
//     selectedCategory = category;
//     applyFilters();
//   }

//   void onSearch(String query) {
//     searchQuery = query;
//     setState(() {
//       filteredPlaces = allPlaces.where((place) =>
//         place['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
//     });
//   }

//   void openDetailsPage(dynamic place) {
//     final placeId = place['id'];
//     final source = place['source'] ?? 'admin';

//     if (placeId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Place ID is missing.')),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TravelPlaceDetailsPage(
//           placeId: placeId,
//           source: source,
//         ),
//       ),
//     );
//   }

//   Widget buildGrid(List places) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 0.7,
//       ),
//       itemCount: places.length,
//       itemBuilder: (context, index) {
//         final place = places[index];
//         return GestureDetector(
//           onTap: () => openDetailsPage(place),
//           child: Column(
//             children: [
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: Image.network(
//                           place['cover_image'],
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
//                         ),
//                       ),
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.green.shade700.withOpacity(0.9),
//                           borderRadius: const BorderRadius.only(
//                             bottomLeft: Radius.circular(12),
//                             bottomRight: Radius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           place['name'],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13,
//                           ),
//                           textAlign: TextAlign.center,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Explore Nepal")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 12),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Autocomplete<String>(
//                       optionsBuilder: (textEditingValue) => searchSuggestions.where(
//                         (option) => option.toLowerCase().startsWith(textEditingValue.text.toLowerCase())),
//                       onSelected: onSearch,
//                       fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
//                         return TextField(
//                           controller: controller,
//                           focusNode: focusNode,
//                           onChanged: onSearch,
//                           decoration: InputDecoration(
//                             prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
//                             hintText: 'Search places...',
//                             contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                               borderSide: BorderSide(color: Colors.green.shade700),
//                             ),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   if (popularPlaces.isNotEmpty) ...[
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16.0),
//                       child: Text("Popular Destinations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     ),
//                     const SizedBox(height: 10),
//                     buildGrid(popularPlaces),
//                     const SizedBox(height: 16),
//                   ],
                 
//                  const Divider(height: 30, thickness: 1.2, color: Colors.grey),

//                 // "Choose your Destinations?" title outside the card
// const Padding(
//   padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//   child: Text(
//     "Choose your Destinations?",
//     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//   ),
// ),

// // Card containing category + source filters
//  Container(
//     width: double.infinity,
//     decoration: BoxDecoration(
//       color: Colors.white,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.2),
//           spreadRadius: 1,
//           blurRadius: 4,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Horizontal Category Chips
//           SizedBox(
//             height: 40,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final category = categories[index];
//                 final isSelected = selectedCategory == category['name'];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: ChoiceChip(
//                     avatar: Icon(
//                       category['icon'],
//                       size: 18,
//                       color: isSelected ? Colors.white : Colors.black,
//                     ),
//                     label: Text(category['name']),
//                     selected: isSelected,
//                     onSelected: (_) {
//                       setState(() {
//                         selectedCategory = category['name'];
//                         applyFilters();
//                       });
//                     },
//                     selectedColor: Colors.green.shade700,
//                     backgroundColor: Colors.grey.shade200,
//                     labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 16),


//           // Source Filter Chips
//           Wrap(
//             spacing: 10,
//             children: [
//               ChoiceChip(
//                 avatar: Icon(Icons.public, size: 20, color: selectedSource == 'All' ? Colors.white : Colors.black),
//                 label: const Text('All'),
//                 selected: selectedSource == 'All',
//                 onSelected: (_) {
//                   setState(() {
//                     selectedSource = 'All';
//                     applyFilters();
//                   });
//                 },
//                 selectedColor: Colors.green.shade700,
//                 backgroundColor: Colors.grey.shade200,
//                 labelStyle: TextStyle(color: selectedSource == 'All' ? Colors.white : Colors.black),
//               ),
//               ChoiceChip(
//                 avatar: Icon(Icons.admin_panel_settings, size: 20, color: selectedSource == 'admin' ? Colors.white : Colors.black),
//                 label: const Text('By admin'),
//                 selected: selectedSource == 'admin',
//                 onSelected: (_) {
//                   setState(() {
//                     selectedSource = 'admin';
//                     applyFilters();
//                   });
//                 },
//                 selectedColor: Colors.green.shade700,
//                 backgroundColor: Colors.grey.shade200,
//                 labelStyle: TextStyle(color: selectedSource == 'admin' ? Colors.white : Colors.black),
//               ),
//               ChoiceChip(
//                 avatar: Icon(Icons.person, size: 20, color: selectedSource == 'user' ? Colors.white : Colors.black),
//                 label: const Text('By user'),
//                 selected: selectedSource == 'user',
//                 onSelected: (_) {
//                   setState(() {
//                     selectedSource = 'user';
//                     applyFilters();
//                   });
//                 },
//                 selectedColor: Colors.green.shade700,
//                 backgroundColor: Colors.grey.shade200,
//                 labelStyle: TextStyle(color: selectedSource == 'user' ? Colors.white : Colors.black),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   ),

     
             
//                   const SizedBox(height: 20),
//                   filteredPlaces.isEmpty
//                       ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text("No places found for this filter.")))
//                       : buildGrid(filteredPlaces),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travelapp/dashboards/travelplacedetails.dart';

class TravelPlacePage extends StatefulWidget {
  const TravelPlacePage({super.key});

  @override
  State<TravelPlacePage> createState() => _TravelPlacePageState();
}

class _TravelPlacePageState extends State<TravelPlacePage> {
  List allPlaces = [];
  List filteredPlaces = [];
  List popularPlaces = [];
  List<String> searchSuggestions = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  String selectedSource = 'All';
  String searchQuery = '';

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.public},
    {'name': 'mountains', 'icon': Icons.terrain},
    {'name': 'temples', 'icon': Icons.account_balance},
    {'name': 'rivers', 'icon': Icons.waves},
    {'name': 'lakes', 'icon': Icons.water},
    {'name': 'valley', 'icon': Icons.landscape},
    {'name': 'city', 'icon': Icons.location_city},
  ];

  @override
  void initState() {
    super.initState();
    fetchAllPlaces();
    fetchPopularPlaces();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAllPlaces() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:8000/user/all-travel-places/"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final processed = data.map((e) => {
          ...e,
          'unique_key': '${e['id']}_${e['source'] ?? 'admin'}',
          'category': (e['category'] ?? '').toString().toLowerCase(),
        }).toList();

        setState(() {
          allPlaces = processed;
          updateSuggestions();
          applyFilters();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load all travel places");
      }
    } catch (e) {
      debugPrint("Error loading all places: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPopularPlaces() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.18.7:8000/user/popular-travel-places/"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => popularPlaces = data);
      }
    } catch (e) {
      debugPrint("Error loading popular places: $e");
    }
  }

  void updateSuggestions() {
    searchSuggestions = allPlaces.map((p) => p['name'].toString()).toSet().toList();
  }

  void applyFilters() {
    setState(() {
      filteredPlaces = allPlaces.where((place) {
        final categoryMatch = selectedCategory == 'All' || (place['category'] ?? '').toLowerCase() == selectedCategory.toLowerCase();
        final sourceMatch = selectedSource == 'All' || (place['source'] ?? 'admin').toLowerCase() == selectedSource.toLowerCase();
        return categoryMatch && sourceMatch;
      }).toList();
    });
  }

  void onCategorySelected(String category) {
    selectedCategory = category;
    applyFilters();
  }

  void onSearch(String query) {
    searchQuery = query;
    setState(() {
      filteredPlaces = allPlaces.where((place) =>
        place['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void openDetailsPage(dynamic place) {
    final placeId = place['id'];
    final source = place['source'] ?? 'admin';

    if (placeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place ID is missing.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TravelPlaceDetailsPage(
          placeId: placeId,
          source: source,
        ),
      ),
    );
  }

  Widget buildGrid(List places) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return GestureDetector(
          onTap: () => openDetailsPage(place),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          place['cover_image'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700.withOpacity(0.9),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          place['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
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
      appBar: AppBar(title: const Text("Explore Nepal")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: RawAutocomplete<String>(
                      textEditingController: _searchController,
                      focusNode: _searchFocusNode,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (!_searchFocusNode.hasFocus || textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return searchSuggestions.where((option) =>
                          option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        _searchController.text = selection;
                        onSearch(selection);
                        _searchFocusNode.unfocus();
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: onSearch,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                            hintText: 'Search places...',
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.green.shade700),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(option),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (popularPlaces.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Popular Destinations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    buildGrid(popularPlaces),
                    const SizedBox(height: 16),
                  ],
                  const Divider(height: 30, thickness: 1.2, color: Colors.grey),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Text("Choose your Destinations?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected = selectedCategory == category['name'];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ChoiceChip(
                                    avatar: Icon(
                                      category['icon'],
                                      size: 18,
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                    label: Text(category['name']),
                                    selected: isSelected,
                                    onSelected: (_) {
                                      setState(() {
                                        selectedCategory = category['name'];
                                        applyFilters();
                                      });
                                    },
                                    selectedColor: Colors.green.shade700,
                                    backgroundColor: Colors.grey.shade200,
                                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            children: [
                              ChoiceChip(
                                avatar: Icon(Icons.public, size: 20, color: selectedSource == 'All' ? Colors.white : Colors.black),
                                label: const Text('All'),
                                selected: selectedSource == 'All',
                                onSelected: (_) {
                                  setState(() {
                                    selectedSource = 'All';
                                    applyFilters();
                                  });
                                },
                                selectedColor: Colors.green.shade700,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(color: selectedSource == 'All' ? Colors.white : Colors.black),
                              ),
                              ChoiceChip(
                                avatar: Icon(Icons.admin_panel_settings, size: 20, color: selectedSource == 'admin' ? Colors.white : Colors.black),
                                label: const Text('By admin'),
                                selected: selectedSource == 'admin',
                                onSelected: (_) {
                                  setState(() {
                                    selectedSource = 'admin';
                                    applyFilters();
                                  });
                                },
                                selectedColor: Colors.green.shade700,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(color: selectedSource == 'admin' ? Colors.white : Colors.black),
                              ),
                              ChoiceChip(
                                avatar: Icon(Icons.person, size: 20, color: selectedSource == 'user' ? Colors.white : Colors.black),
                                label: const Text('By user'),
                                selected: selectedSource == 'user',
                                onSelected: (_) {
                                  setState(() {
                                    selectedSource = 'user';
                                    applyFilters();
                                  });
                                },
                                selectedColor: Colors.green.shade700,
                                backgroundColor: Colors.grey.shade200,
                                labelStyle: TextStyle(color: selectedSource == 'user' ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  filteredPlaces.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text("No places found for this filter.")))
                      : buildGrid(filteredPlaces),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }
}
