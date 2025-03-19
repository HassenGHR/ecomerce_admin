import 'dart:io';

import 'package:admin/blocs/products/product_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProductForm extends StatefulWidget {
  final ProductModel? product;
  final Function(ProductModel)? onSubmit;

  const ProductForm({Key? key, this.product, this.onSubmit}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController priceDescController;
  late String productId;
  late String? selectedCategory;
  late Color selectedColor;
  late bool isAvailable;
  late ConfettiController _confettiController;

  late List<String> imageUrls;
  late List<Map<String, String>> uploadedImageUrls;

  final ImagePicker _picker1 = ImagePicker();
  final ImagePicker _picker2 = ImagePicker();
  XFile? _imageFile1;
  XFile? _imageFile2;

  final List<String> categories = [
    'حلويات',
    'مشروبات',
    'شاي',
    'مكسرات',
    'تغليف'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  void _initializeFormData() {
    final product = widget.product;
    productId = product?.id ?? const Uuid().v4();
    titleController = TextEditingController(text: product?.title ?? '');
    descriptionController =
        TextEditingController(text: product?.description ?? '');
    priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    priceDescController =
        TextEditingController(text: product?.priceDescription ?? '');
    selectedCategory = product?.category ?? categories[0];
    selectedColor = product?.color ?? Colors.blue;
    isAvailable = product?.isAvailable ?? true;
    imageUrls =
        product?.imageUrls != null ? _extractImageUrls(product!.imageUrls) : [];
    uploadedImageUrls = [];
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    priceDescController.dispose();
    _confettiController.dispose();

    super.dispose();
  }

  List<String> _extractImageUrls(List<Map<String, String>> imageUrls) {
    return imageUrls
        .expand((map) => [
              if (map['cover_image'] != null) map['cover_image']!,
              if (map['image1'] != null) map['image1']!,
            ])
        .toList();
  }

  Set<String> uploadedImageHashes =
      {}; // A local set to store hashes of uploaded images

  Future<void> _handleImagePicker(ImageSource source, bool isCoverImage) async {
    try {
      final ImagePicker picker = isCoverImage ? _picker1 : _picker2;
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return; // No file selected

      setState(() {
        if (isCoverImage) {
          _imageFile1 = pickedFile;
        } else {
          _imageFile2 = pickedFile;
        }
      });

      // Generate a hash for the selected file
      final fileHash = await _generateFileHash(pickedFile.path);

      // Check if the hash already exists locally
      if (uploadedImageHashes.contains(fileHash)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This image has already been uploaded.')),
        );
        return;
      }

      // Upload the image
      final productBloc = BlocProvider.of<ProductBloc>(context);
      String imageUrl =
          await productBloc.repository.uploadImage(pickedFile.path);

      if (imageUrl.isNotEmpty) {
        // Add the hash to the local set to avoid duplicates
        uploadedImageHashes.add(fileHash);

        final containsCoverImage =
            uploadedImageUrls.any((map) => map.containsKey("cover_image"));
        final containsImage1 =
            uploadedImageUrls.any((map) => map.containsKey("image1"));

        if (containsCoverImage && containsImage1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Both cover image and image1 are already added.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer))),
          );
          return;
        }

        // Add the new map only if it's not already present
        setState(() {
          uploadedImageUrls.add(
              isCoverImage ? {"cover_image": imageUrl} : {"image1": imageUrl});
        });
        // Reorder the list to ensure "image1" comes first
        uploadedImageUrls.sort((a, b) {
          if (a.containsKey("image1")) {
            return -1; // Move "image1" to the top
          } else if (b.containsKey("image1")) {
            return 1; // Keep "image1" higher
          }
          return 0; // Maintain other order
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error picking image: $e',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error))),
      );
    }
  }

  Future<String> _generateFileHash(String filePath) async {
    final fileBytes = await File(filePath).readAsBytes();
    return sha256.convert(fileBytes).toString();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate() &&
        (uploadedImageUrls.length == 2 || widget.product != null)) {
      try {
        final product = ProductModel(
          id: productId,
          title: titleController.text,
          description: descriptionController.text,
          category: selectedCategory!,
          color: selectedColor,
          price: double.tryParse(priceController.text) ?? 0.0,
          priceDescription: priceDescController.text,
          isAvailable: isAvailable,
          imageUrls: widget.product != null
              ? widget.product!.imageUrls
              : uploadedImageUrls,
        );
        final productBloc = BlocProvider.of<ProductBloc>(context);
        if (widget.product == null) {
          bool isSuccess = await productBloc.repository.addProduct(product);
          if (isSuccess) {
            _showSuccessDialog();
            _showSuccessSnackbar();
            _confettiController.play();
          }
        } else if (widget.product != null) {
          bool isSuccess =
              await productBloc.repository.updateProductInDatabase(product);
          if (isSuccess) {
            _showSuccessDialog();
            _showSuccessSnackbar();
            _confettiController.play();
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Error: ${e.toString()}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        border: Border.fromBorderSide(
          BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            width: 1.w,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(theme),
                    const SizedBox(height: 24),
                    _buildBasicInformation(theme),
                    const SizedBox(height: 24),
                    _buildCategoryAndFeatures(theme),
                    const SizedBox(height: 24),
                    _buildPricingSection(theme),
                    const SizedBox(height: 24),
                    _buildAvailabilitySection(theme),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.canvasColor,
            theme.canvasColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Theme.of(context).dividerColor, width: 3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.product == null ? 'Add New Product' : 'Edit Product',
              style: theme.textTheme.titleLarge),
          _buildCloseButton(theme),
        ],
      ),
    );
  }

  Widget _buildCloseButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(Icons.close, color: theme.iconTheme.color),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Product Images', theme),
        const SizedBox(height: 12),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              width: 2.w, // Responsive border width
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
            itemBuilder: (context, index) {
              if (imageUrls.isEmpty) {
                return _buildAddImageContainers(theme);
              }
              return _buildImagePreview(imageUrls[index], null);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageContainers(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _imageFile1 == null
            ? _buildImageUploadButton(
                onTap: () => _showImagePickerBottomSheet(true, theme),
                label: 'Add Cover Image',
              )
            : _buildImagePreview(_imageFile1!.path, () {
                setState(() {
                  _imageFile1 = null;
                  uploadedImageUrls
                      .removeWhere((image) => image.containsKey('cover_image'));
                });
              }),
        const SizedBox(width: 12),
        _imageFile2 == null
            ? _buildImageUploadButton(
                onTap: () => _showImagePickerBottomSheet(false, theme),
                label: 'Add Image 1',
              )
            : _buildImagePreview(_imageFile2!.path, () {
                setState(() {
                  _imageFile2 = null;
                  uploadedImageUrls
                      .removeWhere((image) => image.containsKey('image1'));
                });
              }),
      ],
    );
  }

  Widget _buildImageUploadButton({
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String url, Function()? onRemove) {
    return Stack(
      children: [
        Container(
          width: 110,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: url.startsWith('http')
                  ? NetworkImage(url) as ImageProvider
                  : FileImage(File(url)),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        imageUrls.isEmpty
            ? Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget _buildBasicInformation(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information', theme),
        const SizedBox(height: 12),
        _buildTextField(
          controller: titleController,
          label: 'Product Title',
          theme: theme,
          icon: Icons.shopping_bag_outlined,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a title' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: descriptionController,
          label: 'Description',
          icon: Icons.description_outlined,
          theme: theme,
          maxLines: 3,
          // validator: (value) =>
          //     value?.isEmpty ?? true ? 'Please enter a description' : null,
        ),
      ],
    );
  }

  Widget _buildCategoryAndFeatures(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Category & Features', theme),
        const SizedBox(height: 12),
        _buildCategoryDropdown(theme),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        // borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        borderRadius: BorderRadius.circular(12),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.category_outlined, color: Colors.grey),
          suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          border: InputBorder.none,

          // Add padding to align with items
        ),
        icon: const SizedBox(), // Removes default dropdown arrow icon
        // Style for the button when dropdown is closed
        selectedItemBuilder: (BuildContext context) {
          return categories.map<Widget>((
            String value,
          ) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(value, style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }).toList();
        },
        // Style for items in dropdown menu
        items: categories.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.cardColor),
              child: Row(
                children: [
                  // Optional: Add an icon specific to each category
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: theme.iconTheme.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(value, style: theme.textTheme.titleMedium),
                  ),
                  // Optional: Add a subtle hint color for selected item
                  if (value == selectedCategory)
                    Icon(
                      Icons.check,
                      size: 18,
                      color: theme.iconTheme.color,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedCategory = newValue!;
          });
        },
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pricing', theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: priceController,
                label: 'Price',
                theme: theme,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a price' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: priceDescController,
                label: 'Price Description',
                theme: theme,
                icon: Icons.description_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 2.w, // Responsive border width
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                  isAvailable
                      ? Icons.visibility_outlined
                      : Icons.visibility_off,
                  color: theme.iconTheme.color),
              const SizedBox(width: 12),
              Text(isAvailable ? 'Available for Sale' : 'Not Available',
                  style: theme.textTheme.titleMedium),
            ],
          ),
          Switch(
            value: isAvailable,
            onChanged: (bool value) {
              setState(() {
                isAvailable = value;
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: _handleSubmit,
        child: const Text(
          'Submit',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    required ThemeData theme,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.inputDecorationTheme.labelStyle,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
      ),
      validator: validator,
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(title, style: theme.textTheme.titleLarge);
  }

  void _showImagePickerBottomSheet(bool isFirstImage, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              color: theme.cardColor,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 2.w, // Responsive border width
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose Image Source",
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildImageSourceButton(
                      icon: Icons.camera_alt,
                      label: "Camera",
                      onTap: () {
                        Navigator.pop(context);
                        _handleImagePicker(ImageSource.camera, isFirstImage);
                      },
                    ),
                    _buildImageSourceButton(
                      icon: Icons.photo_library,
                      label: "Gallery",
                      onTap: () {
                        Navigator.pop(context);
                        _handleImagePicker(ImageSource.gallery, isFirstImage);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Main Content
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Add space for confetti at the top
                      const SizedBox(height: 20),

                      // Success Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green.shade400,
                          size: 70,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Success Message
                      Text(
                        imageUrls.isEmpty
                            ? 'Product Added Successfully!'
                            : "Product Edited Successfully!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        imageUrls.isEmpty
                            ? 'Your product has been added to the inventory'
                            : 'Your product has been Edited in the inventory',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Continue Button
                      ElevatedButton(
                        onPressed: () {
                          int count = 2; // Number of screens to pop
                          Navigator.of(context).popUntil((_) => count-- <= 0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Confetti positioned above the dialog
              Positioned(
                top: -50, // Position above the dialog
                child: SizedBox(
                  height: 200, // Fixed height for confetti
                  width: 200, // Fixed width for confetti
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.05,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(imageUrls.isEmpty
                ? 'Product added successfully'
                : 'Product edited successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
