import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:travelapp/pages/crossauth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPlaceFormPage extends StatefulWidget {
  const AddPlaceFormPage({super.key});

  @override
  State<AddPlaceFormPage> createState() => _AddPlaceFormPageState();
}

class _AddPlaceFormPageState extends State<AddPlaceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final costController = TextEditingController();
  final timeController = TextEditingController();
  final transportController = TextEditingController();
  final durationController = TextEditingController();
  final addressController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  String selectedCategory = 'mountains';
  File? coverImage;
  File? videoFile;
  List<File> galleryImages = [];
  final picker = ImagePicker();

  bool showSubmissionMessage = false;
  bool showDuplicateError = false;

  @override
  void initState() {
    super.initState();
    loadDraft();
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('draft_place_form')) {
      final draftData = jsonDecode(prefs.getString('draft_place_form')!);
      setState(() {
        nameController.text = draftData['name'] ?? '';
        locationController.text = draftData['location'] ?? '';
        selectedCategory = draftData['category'] ?? 'mountains';
        descriptionController.text = draftData['description'] ?? '';
        latitudeController.text = draftData['latitude'] ?? '';
        longitudeController.text = draftData['longitude'] ?? '';
        costController.text = draftData['cost'] ?? '';
        timeController.text = draftData['time'] ?? '';
        transportController.text = draftData['transport'] ?? '';
        durationController.text = draftData['duration'] ?? '';
        addressController.text = draftData['address'] ?? '';

        if (draftData['cover_image'] != null) coverImage = File(draftData['cover_image']);
        if (draftData['video'] != null) videoFile = File(draftData['video']);
        if (draftData['images'] != null) {
          galleryImages = (draftData['images'] as List).map((path) => File(path)).toList();
        }
      });
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_place_form');
  }

  Future<void> saveDraftLocally() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> draftData = {
      'name': nameController.text,
      'location': locationController.text,
      'category': selectedCategory,
      'description': descriptionController.text,
      'latitude': latitudeController.text,
      'longitude': longitudeController.text,
      'cost': costController.text,
      'time': timeController.text,
      'transport': transportController.text,
      'duration': durationController.text,
      'address': addressController.text,
      'cover_image': coverImage?.path,
      'video': videoFile?.path,
      'images': galleryImages.map((file) => file.path).toList(),
    };
    await prefs.setString('draft_place_form', jsonEncode(draftData));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved successfully')));
  }

  Future<void> pickCoverImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      String path = picked.path;
      if (path.toLowerCase().endsWith('.heic')) {
        String jpgPath = path.replaceAll('.heic', '.jpg');
        final renamed = await File(path).copy(jpgPath);
        setState(() => coverImage = renamed);
      } else {
        setState(() => coverImage = File(path));
      }
    }
  }

  Future<void> pickVideo() async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) setState(() => videoFile = File(picked.path));
  }

  Future<void> pickGalleryImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      List<File> converted = [];
      for (var img in picked) {
        String path = img.path;
        if (path.toLowerCase().endsWith('.heic')) {
          String jpgPath = path.replaceAll('.heic', '.jpg');
          converted.add(await File(path).copy(jpgPath));
        } else {
          converted.add(File(path));
        }
      }
      setState(() => galleryImages.addAll(converted));
    }
  }

  void clearFormFields() {
    nameController.clear();
    locationController.clear();
    descriptionController.clear();
    costController.clear();
    timeController.clear();
    transportController.clear();
    durationController.clear();
    addressController.clear();
    latitudeController.clear();
    longitudeController.clear();
    coverImage = null;
    videoFile = null;
    galleryImages = [];
    selectedCategory = 'mountains';
  }

  Future<void> submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a cover image')));
      return;
    }
    final token = await getAuthToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    try {
      var uri = Uri.parse("http://10.0.2.2:8000/user/user-places/submit/");
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = nameController.text;
      request.fields['location'] = locationController.text;
      request.fields['category'] = selectedCategory;
      request.fields['description'] = descriptionController.text;
      request.fields['latitude'] = latitudeController.text;
      request.fields['longitude'] = longitudeController.text;
      if (costController.text.isNotEmpty) request.fields['estimated_cost'] = costController.text;
      if (timeController.text.isNotEmpty) request.fields['best_time_to_visit'] = timeController.text;
      if (transportController.text.isNotEmpty) request.fields['available_transport'] = transportController.text;
      if (durationController.text.isNotEmpty) request.fields['duration_to_visit'] = durationController.text;
      if (addressController.text.isNotEmpty) request.fields['full_address'] = addressController.text;

      request.files.add(await http.MultipartFile.fromPath('cover_image', coverImage!.path));
      if (videoFile != null) request.files.add(await http.MultipartFile.fromPath('video', videoFile!.path));
      for (var file in galleryImages) {
        request.files.add(await http.MultipartFile.fromPath('images', file.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          showSubmissionMessage = true;
          showDuplicateError = false;
        });
        clearFormFields();
        clearDraft();
        
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text(
        'Place submitted successfully!',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: const Duration(seconds: 3),
    ),);
        
      } else if (response.statusCode == 400 && response.body.contains("already exists")) {
        setState(() => showDuplicateError = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This place already exists.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: ${response.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget buildFormField(String label, TextEditingController controller, bool required, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            labelStyle: const TextStyle(color: Colors.black87),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.green.shade700),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.green.shade700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.green.shade700, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: required ? (value) => value!.isEmpty ? 'Required' : null : null,
        ),
      ),
    );
  }

  Widget buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: pickCoverImage,
          child: const Text("Select Cover Image(jpg*,png*)"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
            foregroundColor: Colors.black, // black text color
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        if (coverImage != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(coverImage!, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () => setState(() => coverImage = null),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: pickVideo,
          child: const Text("Select Video"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
            foregroundColor: Colors.black, // black text color
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        if (videoFile != null)
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Icon(Icons.videocam, size: 60)),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () => setState(() => videoFile = null),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: pickGalleryImages,
          child: Text(galleryImages.isEmpty ? "Select Images(jpg*,png*)" : "Choose More Images(jpg*,png*)"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
            foregroundColor: Colors.black, // black text color
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (galleryImages.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: galleryImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      galleryImages[index],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => galleryImages.removeAt(index)),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Your Place")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (showSubmissionMessage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        "Thank you! The place you explored will be reviewed and approved within a few hours or up to 24 hrs.",
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  buildFormField("Name", nameController, true),
                  buildFormField("Location", locationController, true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: DropdownButtonFormField(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green.shade700),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ['mountains', 'temples', 'rivers', 'city', 'valley', 'treks', 'lakes']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedCategory = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildFormField("Description", descriptionController, true, maxLines: 3),

                  // Latitude and Longitude fields side by side
                  Row(
                    children: [
                      Expanded(
                        child: buildFormField("Latitude", latitudeController, true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildFormField("Longitude", longitudeController, true),
                      ),
                    ],
                  ),

                  // Friendly message below both fields
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 12),
                    child: Text(
                      "Choose exact latitude and longitude of place for accurate location. You can get it from Google Maps.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  buildFormField("Estimated Cost", costController, false),
                  buildFormField("Best Time to Visit", timeController, false),
                  buildFormField("Available Transport", transportController, false),
                  buildFormField("Duration to Visit", durationController, false),
                  buildFormField("Full Address", addressController, false),

                  const SizedBox(height: 10),

                  // Media section after full address
                  buildMediaSection(),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: saveDraftLocally,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                          child: const Text("Save Draft"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => submitForm(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                          child: const Text("Submit Place"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
