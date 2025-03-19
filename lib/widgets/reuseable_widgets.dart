import 'package:admin/models/product_model.dart';
import 'package:admin/widgets/product_form.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableWidgets {
  static Future<void> showDeleteConfirmationDialog(
    BuildContext context, {
    required String productName,
    required VoidCallback onDelete,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: theme.cardColor,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: _buildContentBox(context, productName, onDelete),
          ),
        );
      },
    );
  }

  static Widget _buildContentBox(
      BuildContext context, String productName, VoidCallback onDelete) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            color: theme.iconTheme.color,
            size: 56,
          ),
          const SizedBox(height: 20),
          Text(
            'Remove Product?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to remove "$productName"? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onDelete();
                    Navigator.of(context).pop();
                    _showSuccessDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showSuccessDialog(BuildContext context) {
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        confettiController.play();
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
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
                      const Text(
                        'Product Removed Successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The product has been removed from the inventory',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
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
              Positioned(
                top: -50,
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: ConfettiWidget(
                    confettiController: confettiController,
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
                      Colors.purple,
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

  static List<String> extractImageUrls(List<Map<String, String>> imageUrls) {
    final List<String> urls = [];

    for (var imageUrl in imageUrls) {
      // Add the `cover_image` URL if it exists
      if (imageUrl.containsKey("cover_image") &&
          imageUrl["cover_image"] != null) {
        urls.add(imageUrl["cover_image"]!);
      }

      // Add the `image1` URL if it exists
      if (imageUrl.containsKey("image1") && imageUrl["image1"] != null) {
        urls.add(imageUrl["image1"]!);
      }
    }

    return urls;
  }

  static void showProductForm(BuildContext context,
      {ProductModel? product, Function(ProductModel)? onSubmit}) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      builder: (context) => ProductForm(product: product, onSubmit: onSubmit),
    );
  }

  static DateTime getStartTimeForTimeFrame(String timeFrame, DateTime now) {
    switch (timeFrame.toLowerCase()) {
      case 'daily':
        return DateTime(now.year, now.month, now.day);
      case 'weekly':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'monthly':
        return DateTime(now.year, now.month, 1);
      default:
        throw Exception("Invalid time frame: $timeFrame");
    }
  }

  static formatPrice(double price) => '${price.toStringAsFixed(2)} \دج';
  static formatDate(DateTime date) => DateFormat.yMd().format(date);

  static DateTime parseDate(String dateStr) {
    try {
      if (dateStr.contains('-') && dateStr.contains('T')) {
        // ISO 8601 format: "2024-10-21T23:53:17.751630"
        return DateTime.parse(dateStr);
      } else if (dateStr.contains(' ')) {
        // Format: "15 October 2024"
        DateFormat inputFormat = DateFormat('dd MMMM yyyy');
        return inputFormat.parse(dateStr);
      } else {
        throw FormatException("Unknown date format");
      }
    } catch (e) {
      print("Error parsing date: $e");
      rethrow;
    }
  }
}
