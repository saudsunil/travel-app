import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HotelDetailsPage extends StatelessWidget {
  final dynamic hotelData;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfPeople;

  const HotelDetailsPage({
    super.key,
    required this.hotelData,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfPeople,
  });

  @override
  Widget build(BuildContext context) {
    final name = hotelData['hotelName'] ?? 'Unknown Hotel';
    final address = hotelData['address'] ?? 'No address';
    final rating = hotelData['hotelRating']?.toString() ?? 'N/A';
    final price = hotelData['total']?.toString() ?? 'N/A';
    final currency = hotelData['currency'] ?? 'NPR';
    final imageUrl = hotelData['thumbNailUrl'] ?? '';
    final facilities = hotelData['facilities'] as List<dynamic>? ?? [];

    final checkIn = DateFormat('yyyy-MM-dd').format(checkInDate);
    final checkOut = DateFormat('yyyy-MM-dd').format(checkOutDate);

    final List<String> galleryImages = hotelData['gallery'] != null && hotelData['gallery'] is List
        ? List<String>.from(hotelData['gallery'])
        : imageUrl.isNotEmpty
            ? [imageUrl]
            : [];

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          // Full-width images (no horizontal padding)
          SizedBox(
            height: 220,
            width: double.infinity,
            child: galleryImages.isNotEmpty
                ? PageView.builder(
                    itemCount: galleryImages.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        galleryImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 100),
                      );
                    },
                  )
                : const Icon(Icons.hotel, size: 100),
          ),

          // Main scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('⭐ Hotel Rating: $rating'),
                const SizedBox(height: 8),
                Text('📍 $address'),
                const SizedBox(height: 16),

                // Check-in & Check-out aligned like 📍
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Check-in: $checkIn')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Check-out: $checkOut')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people_alt, size: 18),
                    const SizedBox(width: 8),
                    Text('Guests: $numberOfPeople'),
                  ],
                ),
                const SizedBox(height: 16),

                if (facilities.isNotEmpty) ...[
                  const Text('Facilities:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: facilities
                        .map((f) => Chip(
                              label: Text(f.toString()),
                              backgroundColor: Colors.green.shade50,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          // Fixed Book Now button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Booking process available soon.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                'Book Now - $currency $price',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
