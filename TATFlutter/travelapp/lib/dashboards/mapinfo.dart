import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapInfoPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? label;

  const MapInfoPage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label,
  });

  @override
  State<MapInfoPage> createState() => _MapInfoPageState();
}

class _MapInfoPageState extends State<MapInfoPage> {
  bool _launchFailed = false;

  @override
  void initState() {
    super.initState();
    _launchMaps();
  }

  Future<void> _launchMaps() async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}${widget.label != null ? Uri.encodeComponent('(${widget.label})') : ''}';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      setState(() {
        _launchFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Location')
   
      ),
      body: Center(
        child: _launchFailed
            ? Text(
                'Could not launch maps.',
                style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
              )
            : Text(
                'Opening location in Maps...',
                style: TextStyle(color:Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
