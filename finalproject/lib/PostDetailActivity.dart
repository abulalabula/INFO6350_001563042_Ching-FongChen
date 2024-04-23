import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PostDetailActivity extends StatelessWidget {
  final Map<String, dynamic> post;
  final List<String>
      imagePaths; // Holds Base64 strings/ URLs from Firestore

  PostDetailActivity({Key? key, required this.post, required this.imagePaths})
      : super(key: key);

  Widget buildThumbnail(BuildContext context, String imagePath) {
    try {
      Uint8List bytes = base64Decode(imagePath);
      return GestureDetector(
        onTap: () => _openFullScreenImage(context, Image.memory(bytes)),
        child: Image.memory(bytes, fit: BoxFit.cover, width: 100, height: 100),
      );
    } catch (e) {
      return GestureDetector(
        onTap: () => _openFullScreenImageFromUrl(context, imagePath),
        child: Image.network(imagePath,
            fit: BoxFit.cover, width: 100, height: 100),
      );
    }
  }

  void _openFullScreenImage(BuildContext context, Widget image) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(),
        body: Center(child: image),
      ),
    ));
  }

  void _openFullScreenImageFromUrl(BuildContext context, String url) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Image.network(url, fit: BoxFit.contain)),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(post['title'] ?? 'Post Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display thumbnails for all images in a 2x2 grid
            GridView.builder(
              shrinkWrap: true, // Spaces for grid
              physics:
                  NeverScrollableScrollPhysics(), // Stop scrolling for GridView
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10, // Space between columns
                mainAxisSpacing: 10, // Space between rows
                childAspectRatio: 1, 
              ),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return buildThumbnail(context, imagePaths[index]);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Description: ${post['description']}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Price: \$${post['price']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
