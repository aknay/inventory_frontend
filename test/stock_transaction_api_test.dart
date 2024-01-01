import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/item/item.repository.dart';
import 'package:inventory_frontend/data/stock.transaction/stock.transaction.repository.dart';
import 'package:inventory_frontend/data/team/rest.api.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';

void main() async {
  final teamApi = TeamRestApi();
  final itemApi = ItemRepository();
  final stockTransactionRepo = StockTransactionRepository();
  // final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;

  setUpAll(() async {
    const email = "abc@someemail.com";
    const password = "nakbi6785!";

    Map<String, dynamic> signUpData = {};
    signUpData["email"] = email;
    signUpData["password"] = password;

    await http.post(Uri.parse("http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=abcdefg"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(signUpData));

    Map<String, dynamic> data = {};
    data["email"] = email;
    data["password"] = password;
    data["returnSecureToken"] = true;

    final response = await http.post(
        Uri.parse("http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=abcdefg"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data));

    final signInResponse = SignInResponse.fromJson(jsonDecode(response.body));

    firstUserAccessToken = signInResponse.idToken!;
  });

  test('creating stx wiht stock in should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.lineItems.first.quantity, 7);
    expect(stx.lineItems.first.oldStockLevel, 0);
    expect(stx.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError =
          await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }
  });

  test('creating stx with stock out should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.lineItems.first.quantity, 7);
    expect(stx.lineItems.first.oldStockLevel, 0);
    expect(stx.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError =
          await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }

    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 3);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      final stx = stCreatedOrError.toIterable().first;
      expect(stx.lineItems.first.quantity, 3);
      expect(stx.lineItems.first.oldStockLevel, 7);
      expect(stx.lineItems.first.newStockLevel, 4);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 4);
      }
    }
  });

  test('creating stx with stock adjust should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.lineItems.first.quantity, 7);
    expect(stx.lineItems.first.oldStockLevel, 0);
    expect(stx.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError =
          await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }

    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 3);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      final stx = stCreatedOrError.toIterable().first;
      expect(stx.lineItems.first.quantity, 3);
      expect(stx.lineItems.first.oldStockLevel, 7);
      expect(stx.lineItems.first.newStockLevel, 4);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 4);
      }
    }

    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 10);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      final stx = stCreatedOrError.toIterable().first;
      expect(stx.lineItems.first.quantity, 10);
      expect(stx.lineItems.first.oldStockLevel, 4);
      expect(stx.lineItems.first.newStockLevel, 10);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 10);
      }
    }
  });

  test('delete stx with stock adjust should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stxWithStockIn = stCreatedOrError.toIterable().first;
    expect(stxWithStockIn.lineItems.first.quantity, 7);
    expect(stxWithStockIn.lineItems.first.oldStockLevel, 0);
    expect(stxWithStockIn.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError =
          await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }
    StockTransaction stxWithStockOut;
    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 3);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      stxWithStockOut = stCreatedOrError.toIterable().first;
      expect(stxWithStockOut.lineItems.first.quantity, 3);
      expect(stxWithStockOut.lineItems.first.oldStockLevel, 7);
      expect(stxWithStockOut.lineItems.first.newStockLevel, 4);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 4);
      }
    }
    StockTransaction stxWithStockAdjust;
    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 10);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      stxWithStockAdjust = stCreatedOrError.toIterable().first;
      expect(stxWithStockAdjust.lineItems.first.quantity, 10);
      expect(stxWithStockAdjust.lineItems.first.oldStockLevel, 4);
      expect(stxWithStockAdjust.lineItems.first.newStockLevel, 10);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 10);
      }
    }

    {
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockAdjust.id!, teamId: team.id!, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError =
          await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 4);
    }

    {
      //delete stock out transaction and check item count

      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockOut.id!, teamId: team.id!, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError =
          await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }

    {
      //delete stock in transaction and check item count

      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockIn.id!, teamId: team.id!, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError =
          await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 0);
    }
  });

  test('you can list stock transactions', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.lineItems.first.quantity, 7);
    expect(stx.lineItems.first.oldStockLevel, 0);
    expect(stx.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError =
          await itemApi.getItem(itemId: tShirtItem.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }
    {
        final stockTransactionListOrError =
        await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken);
        expect(stockTransactionListOrError.isRight(), true);
    }
  });

}
