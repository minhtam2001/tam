import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/auth_token.dart';
import 'firebase_service.dart';

class ProductsService extends FirebaseService {
  ProductsService([AuthToken? authToken]) : super(authToken);

  Future<List<Product>> fetchProducts([bool filterByUser = false]) async {
    final List<Product> products = [];

    try {
      final filters =
          filterByUser ? 'orderBy = "creatorId"&equalTo="$userId"' : '';
      final productsUrl =
          Uri.parse('$databaseUrl/products.json?auth=$token&$filters');
      final response = await http.get(productsUrl);
      final productsMap = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        print(productsMap['error']);
        return products;
      }

      final userFavoritesUrl =
          Uri.parse('$databaseUrl/userFavorites/$userId.json?auth=$token');
      final userFavoritesRespone = await http.get(userFavoritesUrl);
      final userFavoritesMap = json.decode(userFavoritesRespone.body);

      productsMap.forEach((productId, product) {
        final isFavorite = (userFavoritesMap == null)
            ? false
            : (userFavoritesMap[productId] ?? false);
        products.add(
          Product.fromJson({
            'id': productId,
            ...product,
          }).copyWith(isFavorite: isFavorite),
        );
      });
      return products;
    } catch (error) {
      print(error);
      return products;
    }
  }

  Future<Product?> addProduct(Product product) async {
    try {
      final url = Uri.parse('$databaseUrl/products.json?auth=$token');
      final respone = await http.post(
        url,
        body: json.encode(
          product.toJson()
            ..addAll({
              'creatorId': userId,
            }),
        ),
      );

      if (respone.statusCode != 200) {
        throw Exception(json.decode(respone.body)['error']);
      }

      return product.copyWith(
        id: json.decode(respone.body)['name'],
      );
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final url =
          Uri.parse('$databaseUrl/products/${product.id}.json?auth=$token');
      final respone = await http.patch(
        url,
        body: json.encode(product.toJson()),
      );

      if (respone.statusCode != 200) {
        throw Exception(json.decode(respone.body)['error']);
      }
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final url =
          Uri.parse('$databaseUrl/products/$id.json?auth=$token');
      final respone = await http.delete(url);

      if (respone.statusCode != 200) {
        throw Exception(json.decode(respone.body)['error']);
      }
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> saveFavoriteStatus(Product product) async {
    try {
      final url =
          Uri.parse('$databaseUrl/userFavorites/$userId/${product.id}.json?auth=$token');
      final respone = await http.put(
        url,
        body: json.encode(
          product.isFavorite,
        ),
      );

      if (respone.statusCode != 200) {
        throw Exception(json.decode(respone.body)['error']);
      }
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}