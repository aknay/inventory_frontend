import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/team/rest.api.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'helpers/sign.in.response.dart';

void main() async {
  final teamApi = TeamRestApi();
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

  test('populate', () async {
    // Get all time zones available in the timezone package
    tz.initializeTimeZones();
    var locations = tz.timeZoneDatabase.locations;
    // final locations = tz.initializeTimeZones();

    print(locations.length); // => 429
    print(locations.keys.first); // => "Africa/Abidjan"
    print(locations.keys.last); //

    // // Print the list of ISO 8601 time zone offsets
    // for (final locationName in locations) {
    //   try {
    //     final location = tz.getLocation(locationName);
    //     final offset = location.offsetAt(DateTime.now());

    //     // Format offset as ISO 8601
    //     final offsetString = offset.toString();

    //     print('$locationName: $offsetString');
    //   } catch (e) {
    //     // Handle any exceptions (some locations may not have valid offsets)
    //     print('Error getting offset for $locationName: $e');
    //   }
    // }
  });

  test('creating team should be succeful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
  });
}
