import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePicturePicker extends StatefulWidget {
  final File? selectedFile;
  final Function(File?) onImagePicked;
  final double size;
  final String? defaultImage;
  final bool showEditIcon;

  const ProfilePicturePicker({
    Key? key,
    this.selectedFile,
    required this.onImagePicked,
    this.size = 80,
    this.defaultImage,
    this.showEditIcon = true,
  }) : super(key: key);

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      bool granted = await _handlePermission(source);
      if (!granted) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        widget.onImagePicked(File(pickedFile.path));
      }
    } catch (e, stackTrace) {
      debugPrint('Error picking image: $e\n$stackTrace');
      _showErrorDialog('Failed to pick image: ${e.toString()}');
    }
  }

  Future<bool> _handlePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
    } else {
      if (Platform.isAndroid) {
        // Handle Android storage permissions
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) return true;

        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) return true;
      } else {
        // iOS only needs permission for camera, not gallery
        return true;
      }
    }

    if (await Permission.camera.isPermanentlyDenied ||
        await Permission.photos.isPermanentlyDenied) {
      _showPermissionDialog();
    }
    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Please enable permissions in settings"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Open Settings"),
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _getBackgroundImage(),
            child: _showPlaceholderIcon(),
          ),

         // if (widget.showEditIcon)
            // Positioned(
            //   bottom: 0,
            //   right: 0,
            //   child: Container(
            //     padding: const EdgeInsets.all(4),
            //     decoration: const BoxDecoration(
            //       color: Colors.blue,
            //       shape: BoxShape.circle,
            //     ),
            //     child: const Icon(Icons.edit, color: Colors.white, size: 20),
            //   ),
            // ),
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (widget.selectedFile != null) {
      return FileImage(widget.selectedFile!);
    } else if (widget.defaultImage != null && widget.defaultImage!.isNotEmpty) {
      if (widget.defaultImage!.startsWith('http')) {
        return NetworkImage(widget.defaultImage!);
      } else {
        return AssetImage(widget.defaultImage!);
      }
    }
    return null;
  }

  Widget? _showPlaceholderIcon() {
    if (widget.selectedFile == null &&
        (widget.defaultImage == null || widget.defaultImage!.isEmpty)) {
      return Icon(
        Icons.camera_alt,
        size: widget.size * 0.4,
        color: Colors.white,
      );
    }
    return null;
  }
}