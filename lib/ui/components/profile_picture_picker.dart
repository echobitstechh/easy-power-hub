import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePicturePicker extends StatefulWidget {
  final File? selectedFile;
  final Function(File?) onImagePicked;
  final double size;
  final String? defaultImage;
  final bool showEditIcon;

  const ProfilePicturePicker({
    super.key,
    this.selectedFile,
    required this.onImagePicked,
    this.size = 80,
    this.defaultImage,
    this.showEditIcon = true,
  });

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final isGranted = await _requestPermission(source);
      if (!isGranted) return;

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

  Future<bool> _requestPermission(ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await (Platform.isAndroid ? Permission.photos : Permission.photos).request();
    }

    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
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
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (widget.selectedFile != null) {
      return FileImage(widget.selectedFile!);
    } else if (widget.defaultImage != null && widget.defaultImage!.isNotEmpty) {
      if (widget.defaultImage!.startsWith('http')) {
        return CachedNetworkImageProvider(widget.defaultImage!);
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