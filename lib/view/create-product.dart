// import 'package:flutter/material.dart';
// import '../service/product-service.dart';

// class ProductFormScreen extends StatefulWidget {
//   const ProductFormScreen({super.key});

//   @override
//   State<ProductFormScreen> createState() => _ProductFormScreenState();
// }

// class _ProductFormScreenState extends State<ProductFormScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();
//   final TextEditingController qtyController = TextEditingController();

//   bool isLoading = false;

//   void saveProduct() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     final response = await ProductService.saveProduct(
//       name: nameController.text,
//       price: double.parse(priceController.text),
//       quantity: int.parse(qtyController.text),
//     );

//     setState(() => isLoading = false);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(response)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Product Registration')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: 'Product Name'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter product name' : null,
//               ),
//               TextFormField(
//                 controller: priceController,
//                 decoration: const InputDecoration(labelText: 'Price'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter price' : null,
//               ),
//               TextFormField(
//                 controller: qtyController,
//                 decoration: const InputDecoration(labelText: 'Quantity'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter quantity' : null,
//               ),
//               const SizedBox(height: 20),
//               isLoading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: saveProduct,
//                       child: const Text('Save Product'),
//                     )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
