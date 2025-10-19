import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

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
    this.size = 120,
    this.defaultImage,
    this.showEditIcon = true,
  });

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  Uint8List? _pickedProfileImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isHovered = false;
  String get _initials => 'AB'; // You can compute initials dynamically later

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // compresses a bit
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _pickedProfileImageBytes = file.readAsBytesSync();
      });
      widget.onImagePicked(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: size,
            width: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pickedProfileImageBytes == null &&
                  widget.selectedFile == null &&
                  (widget.defaultImage == null ||
                      widget.defaultImage!.isEmpty)
                  ? Colors.grey.shade600
                  : Colors.white.withOpacity(0.2),
              image: _getProfileImage(),
            ),
            child: _showInitials(),
          ),
          AnimatedOpacity(
            opacity: _isHovered ? 0.6 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (widget.showEditIcon)
            InkWell(
              onTap: _pickImage,
              child: AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }

  DecorationImage? _getProfileImage() {
    if (_pickedProfileImageBytes != null) {
      return DecorationImage(
        image: MemoryImage(_pickedProfileImageBytes!),
        fit: BoxFit.cover,
      );
    } else if (widget.selectedFile != null) {
      return DecorationImage(
        image: FileImage(widget.selectedFile!),
        fit: BoxFit.cover,
      );
    } else if (widget.defaultImage != null && widget.defaultImage!.isNotEmpty) {
      if (widget.defaultImage!.startsWith('http')) {
        return DecorationImage(
          image: CachedNetworkImageProvider(widget.defaultImage!),
          fit: BoxFit.cover,
        );
      } else {
        return DecorationImage(
          image: AssetImage(widget.defaultImage!) as ImageProvider,
          fit: BoxFit.cover,
        );
      }
    }
    return null;
  }

  Widget? _showInitials() {
    if (_pickedProfileImageBytes == null &&
        widget.selectedFile == null &&
        (widget.defaultImage == null || widget.defaultImage!.isEmpty)) {
      return Text(
        _initials,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return null;
  }
}
