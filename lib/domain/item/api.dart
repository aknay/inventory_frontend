import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/responses.dart';

abstract class ItemApi {
  Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({required String teamId, required String token});
  Future<Either<ErrorResponse, Item>> createItem({required Item item, required String teamId, required String token});
}