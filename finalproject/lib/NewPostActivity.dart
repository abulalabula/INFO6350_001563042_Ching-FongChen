import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';

class NewPostActivity extends StatefulWidget {
  const NewPostActivity({Key? key}) : super(key: key);

  @override
  State<NewPostActivity> createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {
  final _formKey = GlobalKey<FormState>();
  late String _title, _description, _price;
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles = [];

  DateTime? _endDate;

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (index >= _imageFiles!.length) {
          _imageFiles!.add(pickedFile);
        } else {
          _imageFiles![index] = pickedFile;
        }
        setState(() {});
      }
    } catch (e) {
      print("Failed to pick image: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), // Initial date is current date
        firstDate: DateTime.now(), // Earliest 
        lastDate: DateTime(2100), // Latest allowable date
        );
    if (pickedDate != null) {
      _selectTime(pickedDate);
    }
  }

  Future<void> _selectTime(DateTime pickedDate) async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(), // Initial time set to the current time
        );
    if (pickedTime != null) {
      setState(() {
        _endDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Widget _imagePickerButton(int index) {
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.black.withOpacity(0.5)),
        ),
        child: _imageFiles != null &&
                index < _imageFiles!.length &&
                _imageFiles![index].path.isNotEmpty
            ? Image.file(File(_imageFiles![index].path), fit: BoxFit.cover)
            : Icon(Icons.add_photo_alternate, color: Colors.grey[600]),
      ),
    );
  }

  void _submitPost() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      List<String> imageUrls = [];

      // Upload images to Firebase Storage and get URLs
      for (var imageFile in _imageFiles!) {
        if (imageFile.path.isNotEmpty) {
          File file = File(imageFile.path);
          String fileName =
              'images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
          var ref = FirebaseStorage.instance.ref().child(fileName);
          var uploadTask = await ref.putFile(file);
          var downloadUrl = await uploadTask.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        }
      }

      Map<String, dynamic> newPost = {
        'title': _title,
        'description': _description,
        'price': _price,
        'images': imageUrls // Store image URLs -> Firestore
      };

      // Save data to Firestore
      FirebaseFirestore.instance.collection('posts').add(newPost);

      await DatabaseHelper.instance.addPost({
        'title': _title,
        'description': _description,
        'price': _price,
        'image': imageUrls.join(';') 
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post added successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Add New Post', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a price'
                    : null,
                onSaved: (value) => _price = value!,
              ),
              // countdown setting
              TextButton(
                onPressed: _selectDate,
                child: Text(
                  _endDate == null
                      ? '(Optional) Set Bidding End Date & Time'
                      : 'Ends on: ${_endDate!.toLocal()}',
                ),
              ),
              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _imagePickerButton(index);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPost,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
