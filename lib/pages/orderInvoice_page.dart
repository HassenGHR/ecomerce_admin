// import 'package:admin/models/cart_model.dart';
// import 'package:admin/models/order_model.dart';
// import 'package:admin/repositories/firebase_order_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'dart:ui' as ui;

// import 'package:provider/provider.dart';

// class OrderInvoicePage extends StatefulWidget {
//   final String phone;
//   final String orderId;
//   final String userId;
//   final Function(bool)? onMarkIsRead;

//   OrderInvoicePage(
//       {required this.orderId,
//       required this.phone,
//       required this.userId,
//       this.onMarkIsRead});

//   @override
//   _OrderInvoicePageState createState() => _OrderInvoicePageState();
// }

// class _OrderInvoicePageState extends State<OrderInvoicePage> {
//   OrderModel? _order;
//   int quantity = 1;
//   int? day;
//   int? month;
//   int? year;
//   final _repo = FirebaseOrderRepository();
//   void fetchOrder() async {
//     OrderModel? order = await _repo.getOrderById(widget.orderId);
//     if (order != null) {
//       setState(() {
//         _order = order;
//       });
//     }
//   }

//   void _updateOrderItemQuantity(CartModel item, int newQuantity) {
//     setState(() {
//       _order!.items!.firstWhere((i) => i.item.id == item.item.id).quantity =
//           newQuantity;
//       _order!.totalPrice = _calculateTotalPrice();
//     });
//   }

//   double _calculateTotalPrice() {
//     double totalPrice = 0;
//     for (var item in _order!.items!) {
//       totalPrice += item.item.price * item.quantity!;
//     }
//     return totalPrice;
//   }

//   void _removeOrderItem(CartModel item) {
//     setState(() {
//       _order!.items!.remove(item);
//       _order!.totalPrice = _calculateTotalPrice();
//     });
//   }

//   void extractDate(String dateStr) {
//     if (dateStr.contains(' ')) {
//       // Format: "15 October 2024"
//       List<String> parts = dateStr.split(' ');

//       // Extract day, month, and year
//       day = int.parse(parts[0]);
//       month = _getMonthFromString(
//           parts[1]); // Helper function to convert month name to number
//       year = int.parse(parts[2]);
//     } else if (dateStr.contains('T')) {
//       // Format: "2024-10-21T23:53:17.751630"
//       DateTime parsedDate = DateTime.parse(dateStr);

//       // Extract day, month, and year
//       day = parsedDate.day;
//       month = parsedDate.month;
//       year = parsedDate.year;
//     }
//   }

// // Helper function to convert month name to number
//   int _getMonthFromString(String monthStr) {
//     Map<String, int> months = {
//       'January': 1,
//       'February': 2,
//       'March': 3,
//       'April': 4,
//       'May': 5,
//       'June': 6,
//       'July': 7,
//       'August': 8,
//       'September': 9,
//       'October': 10,
//       'November': 11,
//       'December': 12,
//     };
//     return months[monthStr]!;
//   }

//   int _parseMonth(String monthStr) {
//     // Convert month string to month index
//     switch (monthStr.toLowerCase()) {
//       case 'january':
//         return 1;
//       case 'february':
//         return 2;
//       case 'march':
//         return 3;
//       case 'april':
//         return 4;
//       case 'may':
//         return 5;
//       case 'june':
//         return 6;
//       case 'july':
//         return 7;
//       case 'august':
//         return 8;
//       case 'september':
//         return 9;
//       case 'october':
//         return 10;
//       case 'november':
//         return 11;
//       case 'december':
//         return 12;
//       default:
//         throw ArgumentError('Invalid month: $monthStr');
//     }
//   }

//   Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
//     return await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("تأكيد"),
//         content: const Text("هل أنت متأكد من حذف هذا العنصر؟"),
//         actions: <Widget>[
//           ElevatedButton(
//             child: const Text("لا"),
//             onPressed: () {
//               Navigator.of(context).pop(false); // Return false if user cancels
//             },
//           ),
//           ElevatedButton(
//             child: const Text("نعم"),
//             onPressed: () {
//               Navigator.of(context).pop(true); // Return true if user confirms
//             },
//           ),
//         ],
//       ),
//     );
//   }

  

//   @override
//   void initState() {
//     fetchOrder();
  
//     super.initState();
//   }

//   DateTime parseDate(String dateStr) {
//     try {
//       if (dateStr.contains('-') && dateStr.contains('T')) {
//         // ISO 8601 format: "2024-10-21T23:53:17.751630"
//         return DateTime.parse(dateStr);
//       } else if (dateStr.contains(' ')) {
//         // Format: "15 October 2024"
//         DateFormat inputFormat = DateFormat('dd MMMM yyyy');
//         return inputFormat.parse(dateStr);
//       } else {
//         throw FormatException("Unknown date format");
//       }
//     } catch (e) {
//       print("Error parsing date: $e");
//       rethrow;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {

//     if (_order == null) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     } else {
//       extractDate(_order!.date!);
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('فاتورة الطلب'),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context, true);
//             },
//           ),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.save),
//                     onPressed: () async {
//                       if (_order!.totalPrice != 0.00) {
//                         bool status =
//                             await addOrUpdateOrder(widget.orderId, _order!);
//                         if (status) {
//                           Fluttertoast.showToast(msg: "تم حفظ طلبك بنجاح");
//                           // if (context.mounted) {
//                           //   Navigator.pop(context);
//                           // }
//                           setState(() {});
//                           // String? responde = await sendOrderNotification(
//                           //     widget.orderId, widget.phone, widget.userId);
//                           // if (responde == "Notification sent successfully") {

//                           // } else {
//                           //   Fluttertoast.showToast(
//                           //       msg:
//                           //           "فشل في إرسال طلبك! أعد المحاولة أو قم بتسجيل الدخول من جديد");
//                           // }
//                         } else {
//                           Fluttertoast.showToast(msg: "فشل في تحديث طلبك! ");
//                         }
//                       } else {
//                         Fluttertoast.showToast(
//                           msg: "يرجى إضافة المشتريات لإرسال طلبك",
//                         );
//                       }
//                     },
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.picture_as_pdf),
//                     onPressed: () async {
//                       if (_order != null) {
//                         // DateFormat inputFormat = DateFormat('dd MMMM yyyy');
//                         DateTime dateTime = parseDate(_order!.date!);
//                         final invoice = Invoice(
//                             supplier: const Supplier(
//                                 name: 'Oasis Delivery ',
//                                 address: 'Khmiss El Khechna, Boumerdes',
//                                 phone: "0697476363"),
//                             customer: Customer(
//                                 name: _order!.user!.name,
//                                 address: _order!.user!.address,
//                                 phone: _order!.user!.phone),
//                             info: InvoiceInfo(
//                               date: dateTime,
//                               description: 'First Order Invoice',
//                               number:
//                                   '${DateTime.now().day}${_order!.items!.length}',
//                             ),
//                             items: _order!.items!);

//                         final pdfFile =
//                             await PdfInvoicePdfHelper.generate(invoice);

//                         PdfHelper.openPdfViewer(
//                           context,
//                           pdfFile,
//                         );
//                       }
//                     },
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'رقم الطلب: ${_order!.id!.substring(2, 7)}',
//                   textDirection: ui.TextDirection.rtl,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'التاريخ: $day / $month / $year',
//                   textDirection: ui.TextDirection.rtl,
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   _order!.user?.name == ""
//                       ? 'الإسم: /'
//                       : 'الإسم: ${_order!.user?.name}',
//                   textDirection: ui.TextDirection.rtl,
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   _order!.user?.phone == ""
//                       ? 'الهاتف: /'
//                       : 'الهاتف: ${_order!.user?.phone}',
//                   textDirection: ui.TextDirection.rtl,
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   _order!.user?.address == ""
//                       ? 'العنوان: /'
//                       : 'العنوان: ${_order!.user?.address}',
//                   textDirection: ui.TextDirection.rtl,
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'العناصر:',
//                   textDirection: ui.TextDirection.rtl,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Table(
//                     border: TableBorder.all(color: Colors.grey),
//                     textDirection: ui.TextDirection.rtl,
//                     columnWidths: const {
//                       0: FlexColumnWidth(0.5),
//                       1: FlexColumnWidth(0.3),
//                       2: FlexColumnWidth(0.3),
//                       3: FlexColumnWidth(0.2),
//                     },
//                     children: [
//                       const TableRow(
//                         children: [
//                           TableCell(
//                               child: Padding(
//                                   padding: EdgeInsets.all(8),
//                                   child: Text(
//                                     'المنتج',
//                                     textDirection: ui.TextDirection.rtl,
//                                   ))),
//                           TableCell(
//                               child: Padding(
//                                   padding: EdgeInsets.all(8),
//                                   child: Text(
//                                     'الكمية',
//                                     textDirection: ui.TextDirection.rtl,
//                                   ))),
//                           TableCell(
//                               child: Padding(
//                                   padding: EdgeInsets.all(8),
//                                   child: Text(
//                                     'السعر',
//                                     textDirection: ui.TextDirection.rtl,
//                                   ))),
//                           TableCell(
//                               child: Padding(
//                                   padding: EdgeInsets.all(8),
//                                   child: Text(
//                                     'حذف',
//                                     textDirection: ui.TextDirection.rtl,
//                                   ))),
//                         ],
//                       ),
//                       for (var item in _order!.items!)
//                         TableRow(children: [
//                           TableCell(
//                             verticalAlignment:
//                                 TableCellVerticalAlignment.middle,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8),
//                               child: Center(
//                                 child: Text(
//                                   item.item.title,
//                                   textDirection: ui.TextDirection.rtl,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           TableCell(
//                             verticalAlignment:
//                                 TableCellVerticalAlignment.middle,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8),
//                               child: Row(children: [
//                                 Container(
//                                   width: 10,
//                                   height: 50,
//                                   child: Center(
//                                     child: Text(
//                                       item.quantity.toString(),
//                                       style: const TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 5,
//                                 ),
//                                 Stack(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           bottom:
//                                               15.0), // Add space between the icons
//                                       child: IconButton(
//                                         icon: const Icon(Icons.arrow_drop_up),
//                                         iconSize: 16,
//                                         onPressed: () {
//                                           setState(() {
//                                             item.quantity++;
//                                           });
//                                           _updateOrderItemQuantity(
//                                               item, item.quantity);
//                                         },
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           top:
//                                               15.0), // Add space between the icons
//                                       child: IconButton(
//                                         icon: const Icon(Icons.arrow_drop_down),
//                                         iconSize: 16,
//                                         onPressed: () {
//                                           setState(() {
//                                             if (item.quantity > 0) {
//                                               item.quantity--;
//                                             }
//                                           });
//                                           _updateOrderItemQuantity(
//                                               item, item.quantity);
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ]),
//                             ),
//                           ),
//                           TableCell(
//                             verticalAlignment:
//                                 TableCellVerticalAlignment.middle,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8),
//                               child:
//                                   Center(child: Text('${item.item.price} دج')),
//                             ),
//                           ),
//                           TableCell(
//                             verticalAlignment:
//                                 TableCellVerticalAlignment.middle,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8),
//                               child: IconButton(
//                                 icon: const Icon(Icons.delete),
//                                 onPressed: () async {
//                                   bool confirmDelete =
//                                       await _showDeleteConfirmationDialog(
//                                           context);
//                                   if (confirmDelete) {
//                                     _removeOrderItem(item);
//                                   }
//                                 },
//                               ),
//                             ),
//                           ),
//                         ])
//                     ]),
//                 const SizedBox(height: 20),
//                 const Divider(
//                   thickness: 2,
//                   indent: 50,
//                   endIndent: 50,
//                 ),
//                 const SizedBox(
//                   height: 15,
//                 ),
//                 Text(
//                   'السعر الكلي: ${_order!.totalPrice} دج',
//                   textDirection: ui.TextDirection.rtl,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//   }
// }
