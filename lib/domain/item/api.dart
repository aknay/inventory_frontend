import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/payloads.dart';
import 'package:inventory_frontend/domain/item/requests.dart';
import 'package:inventory_frontend/domain/responses.dart';

abstract class ItemApi {
  Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({
    required String teamId,
    required String token,
    String? startingAfterItemId,
  });

  Future<Either<ErrorResponse, Item>> createItem({required Item item, required String teamId, required String token});
  Future<Either<ErrorResponse, Item>> getItem({required String itemId, required String teamId, required String token});
  Future<Either<ErrorResponse, Item>> createImage({required ItemVariationImageRequest request, required String token});
  Future<Either<ErrorResponse, Unit>> updateItemVariation({
    required ItemVariationPayload payload,
    required String itemId,
    required String itemVariationId,
    required String teamId,
    required String token,
  });
  Future<Either<ErrorResponse, Item>> editItem(
      {required PayloadItem payloadItem, required String itemId, required String teamId, required String token});
  Future<Either<ErrorResponse, Unit>> deleteItem(
      {required String itemId, required String teamId, required String token});

  Future<Either<ErrorResponse, Unit>> deleteItemVariation(
      {required String itemId, required String itemVariationId, required String teamId, required String token});
}
