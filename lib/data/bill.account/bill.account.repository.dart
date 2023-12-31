import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/config/api.endpoint.dart';
import 'package:inventory_frontend/data/http.helper.dart';
import 'package:inventory_frontend/domain/bill.account/api.dart';
import 'package:inventory_frontend/domain/bill.account/entities.dart';
import 'package:inventory_frontend/domain/errors/response.dart';
import 'package:inventory_frontend/domain/responses.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bill.account.repository.g.dart';

class BillAccountRepository extends BillAccountApi {
  @override
  Future<Either<ErrorResponse, ListResponse<BillAccount>>> list({required String teamId, required String token}) async {
    try {
      Map<String, String> map = {};
      map["team_id"] = teamId;
      final response =
          await HttpHelper.getWithQuery(url: ApiEndPoint.getBillAccountEndPoint(), token: token, query: map);
      log("team create response code ${response.statusCode}");
      log("team create response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        final listResponse = ListResponse.fromJson(jsonDecode(response.body), BillAccount.fromJson);
        return Right(listResponse);
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }

  @override
  Future<Either<ErrorResponse, BillAccount>> get({
    required String billAccountId,
    required String teamId,
    required String token,
  }) async {
    try {
      final response = await HttpHelper.get(
          url: ApiEndPoint.getBillAccountEndPoint(billAccountId: billAccountId), token: token, teamId: teamId);
      log("bill account get response code ${response.statusCode}");
      log("bill account get response ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return Right(BillAccount.fromJson(jsonDecode(response.body)));
      }
      return Left(ErrorResponse.withStatusCode(message: "having error", statusCode: response.statusCode));
    } catch (e) {
      log("the error is $e");
      return Left(ErrorResponse.withOtherError(message: e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
BillAccountRepository billAccountRepository(BillAccountRepositoryRef ref) {
  return BillAccountRepository();
}
