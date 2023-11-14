import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/purchase.order/api.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';

class PurchaseOrderRestApi extends PurchaseOrderApi {
  @override
  Future<Either<ErrorResponse, PurchaseOrder>> createItem(
      {required PurchaseOrder purchaseOrder, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getPurchaseOrderEndPoint(), body: purchaseOrder.toJson(), token: token, teamId: teamId);
      log("purchase order create response code ${response.statusCode}");
      log("purchase order create response ${jsonDecode(response.body)}");
      if (response.statusCode == 201) {
        return Right(PurchaseOrder.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
  // @override
  // Future<Either<ErrorResponse, Item>> createItem(
  //     {required Item item, required String teamId, required String token}) async {
  //   try {
  //     final response =
  //         await HttpHelper.post(url: ApiEndPoint.getItemEndPoint(), body: item.toJson(), token: token, teamId: teamId);
  //     log("team create response code ${response.statusCode}");
  //     log("team create response ${jsonDecode(response.body)}");
  //     if (response.statusCode == 201) {
  //       return Right(Item.fromJson(jsonDecode(response.body)));
  //     }
  //     return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
  //   } catch (e) {
  //     log("the error is $e");
  //     return Left(ErrorResponse.withOtherError(message: e.toString()));
  //   }
  // }

  // @override
  // Future<Either<ErrorResponse, ListResponse<Item>>> getItemList({required String teamId, required String token}) {
  //   // TODO: implement getItemList
  //   throw UnimplementedError();
  // }
}
