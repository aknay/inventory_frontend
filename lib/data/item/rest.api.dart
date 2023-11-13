import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/item/api.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/responses.dart';

class ItemRestApi extends ItemApi {
  @override
  Future<Either<ErrorResponse, Item>> createItem(
      {required Item item, required String teamId, required String token}) async {
    try {
      final response =
          await HttpHelper.post(url: ApiEndPoint.getItemEndPoint(), body: item.toJson(), token: token, teamId: teamId);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 201) {
        return Right(Item.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({required String teamId, required String token}) {
    // TODO: implement getItemList
    throw UnimplementedError();
  }
}
