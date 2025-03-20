import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class ProfilePicturePicker extends StatefulWidget {
  final File? selectedFile;
  final Function(File?) onImagePicked;

  const ProfilePicturePicker({
    Key? key,
    this.selectedFile,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  _ProfilePicturePickerState createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    if (await _requestPermission(source)) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        widget.onImagePicked(imageFile); // Update the selected file
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission denied")),
      );
    }

  }

  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.status;

    if (status.isGranted) {
      return true; // Permission is already granted
    }

    if (status.isDenied) {
      // Request permission again
      PermissionStatus newStatus = await permission.request();
      return newStatus.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Open app settings if permanently denied
      openAppSettings();
      return false;
    }

    return false;
  }

  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission = (source == ImageSource.camera)
        ? Permission.camera
        : Permission.photos;

    return await requestPermission(permission);
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: CircleAvatar(
        radius: 37,
        backgroundImage: widget.selectedFile == null
            ? AssetImage('assets/images/avatar.png') as ImageProvider
            : FileImage(widget.selectedFile!),
        child: widget.selectedFile == null
            ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
            : null,
      ),
    );
  }
}