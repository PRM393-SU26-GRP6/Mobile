import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/discount_model.dart';
import 'package:flutter/foundation.dart';

/// Discount / promotion endpoints (customer validate + owner CRUD):
///
/// Customer:
/// - POST /discounts/validate
///
/// Owner:
/// - GET  /owner/discounts
/// - POST /owner/discounts
/// - PUT  /owner/discounts/{id}
/// - PUT  /owner/discounts/{id}/status
/// - DELETE /owner/discounts/{id}
class DiscountApiService extends BaseApiService {
  DiscountApiService(super.dio);

  /// Customer: validate a discount code against a booking draft.
  /// Returns null on transport error so the UI can fall back to "invalid".
  Future<ValidateDiscountResponseDto?> validateDiscount(
      ValidateDiscountRequestDto request) async {
    try {
      final headers = await authJsonHeaders();
      final res = await dio.post<dynamic>(
        '${Env.baseUrl}/api/v1/discounts/validate',
        data: request.toJson(),
        options: Options(headers: headers),
      );
      if (res.data != null && res.data is Map<String, dynamic>) {
        if (res.data['data'] != null) {
          return ValidateDiscountResponseDto.fromJson(res.data['data']);
        }
        return ValidateDiscountResponseDto.fromJson(res.data);
      }
      return null;
    } catch (e) {
      debugPrint('validateDiscount error: $e');
      return null;
    }
  }

  /// Owner: list discounts owned by the current owner.
  Future<List<DiscountDto>> getOwnerDiscounts() async {
    try {
      final headers = await authHeaders();
      final res = await dio.get<dynamic>(
        '${Env.baseUrl}/api/v1/owner/discounts',
        options: Options(headers: headers),
      );
      final list = BaseApiService.extractList(res.data);
      return list
          .map((e) => DiscountDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('getOwnerDiscounts error: $e');
      return [];
    }
  }

  /// Owner: create a discount.
  Future<bool> createDiscount(DiscountDto discount) async {
    try {
      final headers = await authJsonHeaders();
      await dio.post<dynamic>(
        '${Env.baseUrl}/api/v1/owner/discounts',
        data: discount.toJson(),
        options: Options(headers: headers),
      );
      return true;
    } catch (e) {
      debugPrint('createDiscount error: $e');
      return false;
    }
  }

  /// Owner: update an existing discount.
  Future<bool> updateDiscount(String id, DiscountDto discount) async {
    try {
      final headers = await authJsonHeaders();
      await dio.put<dynamic>(
        '${Env.baseUrl}/api/v1/owner/discounts/$id',
        data: discount.toJson(),
        options: Options(headers: headers),
      );
      return true;
    } catch (e) {
      debugPrint('updateDiscount error: $e');
      return false;
    }
  }

  /// Owner: toggle discount active/inactive.
  Future<bool> toggleDiscountStatus(String id) async {
    try {
      final headers = await authHeaders();
      await dio.put<dynamic>(
        '${Env.baseUrl}/api/v1/owner/discounts/$id/status',
        options: Options(headers: headers),
      );
      return true;
    } catch (e) {
      debugPrint('toggleDiscountStatus error: $e');
      return false;
    }
  }

  /// Owner: delete a discount.
  Future<bool> deleteDiscount(String id) async {
    try {
      final headers = await authHeaders();
      await dio.delete<dynamic>(
        '${Env.baseUrl}/api/v1/owner/discounts/$id',
        options: Options(headers: headers),
      );
      return true;
    } catch (e) {
      debugPrint('deleteDiscount error: $e');
      return false;
    }
  }
}
