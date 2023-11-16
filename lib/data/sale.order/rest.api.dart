import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/sale.order/api.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';

class SaleOrderRestApi extends SaleOrderApi {
  @override
  Future<Either<ErrorResponse, SaleOrder>> issuedSaleOrder(
      {required SaleOrder saleOrder, required String teamId, required String token}) async {
    try {
      final response = await HttpHelper.post(
          url: ApiEndPoint.getSaleOrderEndPoint(), body: saleOrder.toJson(), token: token, teamId: teamId);
      log("purchase order create response code ${response.statusCode}");
      log("purchase order create response ${jsonDecode(response.body)}");
      if (response.statusCode == 201) {
        return Right(SaleOrder.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  // @override
  // Future<Either<ErrorResponse, PurchaseOrder>> receivedItems({required PurchaseOrder purchaseOrder, required String teamId, required String token}) async {
  //   try {
  //     final response = await HttpHelper.post(
  //         url: ApiEndPoint.getReceivedItemsPurchaseOrderEndPoint(purchaseOrderId: purchaseOrder.id!), token: token, teamId: teamId);
  //     log("purchase order create response code ${response.statusCode}");
  //     log("purchase order create response ${jsonDecode(response.body)}");
  //     if (response.statusCode == 200) {
  //       return Right(PurchaseOrder.fromJson(jsonDecode(response.body)));
  //     }
  //     return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
  //   } catch (e) {
  //     log("the error is $e");
  //     return Left(ErrorResponse.withOtherError(message: e.toString()));
  //   }
  // }
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
