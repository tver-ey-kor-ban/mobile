import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_picker_service.dart';

/// Reusable widget for picking and displaying images
class ImagePickerWidget extends StatefulWidget {
  final Function(File?) onImageSelected;
  final File? initialImage;
  final double height;
  final double width;
  final String? placeholderText;
  final bool allowMultiple;
  final Function(List<File>)? onMultipleImagesSelected;
  final int maxImages;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImage,
    this.height = 200,
    this.width = double.infinity,
    this.placeholderText,
    this.allowMultiple = false,
    this.onMultipleImagesSelected,
    this.maxImages = 5,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  File? _selectedImage;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    final image = await _imagePickerService.showImageSourceBottomSheet(context);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (image != null) {
          _selectedImage = image;
          _selectedImages = [image];
        }
      });
      widget.onImageSelected(image);
    }
  }

  Future<void> _pickMultipleImages() async {
    setState(() {
      _isLoading = true;
    });

    final images = await _imagePickerService.pickMultipleFromGallery(
      maxImages: widget.maxImages,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _selectedImages = images;
        _selectedImage = images.isNotEmpty ? images.first : null;
      });
      widget.onImageSelected(_selectedImage);
      widget.onMultipleImagesSelected?.call(images);
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _selectedImages = [];
    });
    widget.onImageSelected(null);
    widget.onMultipleImagesSelected?.call([]);
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _selectedImage =
          _selectedImages.isNotEmpty ? _selectedImages.first : null;
    });
    widget.onImageSelected(_selectedImage);
    widget.onMultipleImagesSelected?.call(_selectedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main image display area
        GestureDetector(
          onTap: _isLoading ? null : _pickImage,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.placeholderText ?? 'Tap to add photo',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
          ),
        ),

        // Action buttons
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Change'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],

        // Multiple images option
        if (widget.allowMultiple) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickMultipleImages,
              icon: const Icon(Icons.photo_library),
              label: Text(
                  'Select Multiple (${_selectedImages.length}/${widget.maxImages})'),
            ),
          ),
        ],

        // Multiple images preview
        if (widget.allowMultiple && _selectedImages.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
