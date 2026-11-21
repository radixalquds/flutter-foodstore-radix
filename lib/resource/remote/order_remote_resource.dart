import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_foodstore/resource/model/order_model.dart';
import 'package:flutter_foodstore/resource/model/paging_model.dart';

class OrderRemoteResource {
  final Dio _dio;

  OrderRemoteResource(this._dio);

  Future<Either<String, PagingModel>> fetchOrders({int page = 1}) async {
    try {
      final targetPage = page < 1 ? 1 : page;
      final response = await _dio.get('customer/my-orders?page=$targetPage');

      // Ambil wrapper pagination Laravel
      final paginationData = response.data['data'];
      
      // Ambil array list transaksi dari dalam paginationData['data']
      final List listData = paginationData['data'] ?? [];

      final result = PagingModel(
        currentPage: paginationData['current_page'] ?? 1,
        lastPage: paginationData['last_page'] ?? 1,
        data: listData.map((e) => OrderModel.fromMap(e)).toList(),
      );

      return Right(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Left(e.response?.statusCode?.toString() ?? '401');
      } else {
        return Left(e.response?.data['message'] ?? e.toString());
      }
    } catch (e) {
      print('ERROR PARSING ORDER: $e');
      return Left('Parsing Error: ${e.toString()}');
    }
  }

  Future<Either<String, dynamic>> detailOrder(String snapToken) async {
    try {
      final response = await _dio.get('customer/my-orders/$snapToken');
      return Right(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Left(e.response?.statusCode?.toString() ?? '401');
      } else {
        return Left(e.response?.data['message'] ?? e.toString());
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> reviewProduct(
    int transactionDetailId,
    int productId,
    int rating,
    String review,
  ) async {
    try {
      final response = await _dio.post(
        'customer/ratings',
        data: {
          'transaction_detail_id': transactionDetailId,
          'product_id': productId,
          'rating': rating,
          'review': review,
        },
      );
      return Right(response.data['message'] ?? 'Berhasil memberikan ulasan');
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Gagal mengirim ulasan');
    } catch (e) {
      return Left(e.toString());
    }
  }
}