
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_foodstore/resource/model/checkout_model.dart';
import 'package:flutter_foodstore/resource/model/location_model.dart';
import 'package:flutter_foodstore/resource/model/shipping_cost_model.dart';

class CheckoutRemoteResource {
  final Dio _dio;

  CheckoutRemoteResource(this._dio);

  // Mengambil List dari berbagai kemungkinan format respons API.
  List<dynamic>? _extractList(dynamic response) {
    if (response is List) {
      return response;
    }

    if (response is Map) {
      final data = response['data'];

      if (data is List) {
        return data;
      }

      final results = response['results'];

      if (results is List) {
        return results;
      }
    }

    return null;
  }

  String _errorMessage(dynamic response) {
    if (response is Map) {
      return (response['message'] ??
              response['error'] ??
              response['meta'] ??
              'Format respons API tidak sesuai')
          .toString();
    }

    return 'Format respons API tidak sesuai';
  }

  // SEARCH LOCATION
  Future<Either<String, List<LocationModel>>> getLocation(
    String search,
  ) async {
    try {
      final response = await _dio.get(
        'public/search-destination',
        queryParameters: {'search': search},
      );

      final data = _extractList(response.data);

      if (data == null) {
        return Left(_errorMessage(response.data));
      }

      final result = data
          .whereType<Map>()
          .map((e) => LocationModel.fromMap(
                Map<String, dynamic>.from(e),
              ))
          .toList();

      return Right(result);
    } on DioException catch (e) {
      return Left(_errorMessage(e.response?.data ?? {}));
    } catch (e) {
      return Left('Gagal mencari lokasi: $e');
    }
  }

  // CHECK SHIPPING COST
  Future<Either<String, List<ShippingCostModel>>> getShippingCost(
    int cityId,
    int weight,
    String courierName,
  ) async {
    try {
      final response = await _dio.post(
        'public/check-ongkir',
        data: {
          'destination': cityId,
          'weight': weight,
          'courier': courierName,
        },
      );

      final data = _extractList(response.data);

      if (data == null) {
        return Left(_errorMessage(response.data));
      }

      final result = data
          .whereType<Map>()
          .map((e) => ShippingCostModel.fromMap(
                Map<String, dynamic>.from(e),
              ))
          .toList();

      return Right(result);
    } on DioException catch (e) {
      return Left(_errorMessage(e.response?.data ?? {}));
    } catch (e) {
      return Left('Gagal menghitung ongkir: $e');
    }
  }

  // CHECKOUT MIDTRANS
  Future<Either<String, String>> checkOut(
    CheckoutModel checkout,
  ) async {
    try {
      final response = await _dio.post(
        'customer/checkout',
        data: {
          'province_name': checkout.provinceName,
          'city_name': checkout.cityName,
          'district_name': checkout.districtName,
          'subdistrict_name': checkout.subdistrictName,
          'zip_code': checkout.zipCode,
          'full_address': checkout.fullAddress,
          'weight': checkout.weight,
          'shipping_courier': checkout.shippingCourier,
          'shipping_service': checkout.shippingService,
          'shipping_cost': checkout.shippingCost,
          'total': checkout.total,
        },
      );

      final responseData = response.data;

      if (responseData is Map) {
        final data = responseData['data'];

        if (data is Map && data['snap_token'] != null) {
          return Right(data['snap_token'].toString());
        }

        if (responseData['snap_token'] != null) {
          return Right(responseData['snap_token'].toString());
        }
      }

      return const Left(
        'Snap token tidak ditemukan dalam respons server.',
      );
    } on DioException catch (e) {
      return Left(
        _errorMessage(e.response?.data ?? {
          'message': 'Terjadi kesalahan koneksi'
        }),
      );
    } catch (e) {
      return Left('Gagal checkout: $e');
    }
  }
}
