import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_progress_bar.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  /// [AddProductScreen] is a StatefulWidget (or StatelessWidget) that provides:
  /// - A form to add or edit a product
  /// - Validation for each input field
  /// - An option to attach an image
  /// - A call to the provider or service to handle saving/uploading
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _taxController = TextEditingController();
  String _productType = 'Product';
  final _imagePicker = ImagePicker();

  // For mobile
  File? _imageFile;
  // For web
  Uint8List? _webImage;
  String? _imageName;

  // Example methods or important calls within this screen might include:
  // 1. initState(): Initializes any required controllers or listens to streams.
  // 2. build(BuildContext context): Builds the UI with form fields and a submit button.
  // 3. _submitProduct(): Gathers form data, validates input, and sends the product details to the API or provider.
  // 4. _pickImage() (if any): Opens a file picker or camera plugin to get an image.
  // 5. _showProgressDialog() (if any): Displays upload progress or loading indicator.

  ///   ---------------

  ///   - Calls the relevant provider or service to handle the actual logic (e.g., API call).
  ///   - Handles success or failure scenarios with a message or navigation.

  /// Make sure each widget or function has a brief comment describing its purpose.
  /// Ensure that any asynchronous operations (e.g., image upload, network calls) are
  /// documented to indicate what they do and how they handle potential errors or progress.

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        _imageName = pickedFile.name;
        if (kIsWeb) {
          // Handle web
          var bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
        } else {
          // Handle mobile
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  ///   _submitProduct()
  void _submitForm() async {
    ///   - Validates each field.
    if (!_formKey.currentState!.validate()) return;

    ///   Collects all data from form fields:
    try {
      final product = Product(
        productName: _productNameController.text,
        productType: _productType,
        price: double.parse(_priceController.text),
        tax: double.parse(_taxController.text),
        image: _imageName ?? '',
      );

      if (kIsWeb) {
        await context.read<ProductProvider>().addProduct(
              product,
              _webImage,
            );
      } else {
        await context.read<ProductProvider>().addProduct(
              product,
              _imageFile?.path,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully')),
        );
      }
    } catch (e) {
      print('Error in submit form: $e'); // Add this for debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImagePreview() {
    if (_webImage != null && kIsWeb) {
      return Image.memory(
        _webImage!,
        fit: BoxFit.cover,
      );
    } else if (_imageFile != null && !kIsWeb) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 50),
        Text('Tap to add image'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _productType,
                  decoration: InputDecoration(
                    labelText: 'Product Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Product', 'Service']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _productType = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _taxController,
                  decoration: InputDecoration(
                    labelText: 'Tax Rate (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter tax rate';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildImagePreview(),
                  ),
                ),
                SizedBox(height: 16),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    if (provider.isUploading) {
                      return CustomProgressIndicator(
                        progress: provider.uploadProgress,
                      );
                    }
                    return ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text('Add Product'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    super.dispose();
  }
}
