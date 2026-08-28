// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ProductService {
//   static const String baseUrl = "http://localhost:8080/api/products";

//   static Future<String> saveProduct({
//     required String name,
//     required double price,
//     required int quantity,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "name": name,
//           "price": price,
//           "quantity": quantity,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return "Product saved successfully";
//       } else {
//         return "Failed to save product";
//       }
//     } catch (e) {
//       return "Error: $e";
//     }
//   }
// }
