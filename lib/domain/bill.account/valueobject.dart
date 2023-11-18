// ignore_for_file: constant_identifier_names

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

typedef BillAccountId = String;

enum ZeroDecimalCurrency { BIF, CLP, DJF, GNF, JPY, KMF, KRW, MGA, PYG, RWF, UGX, VND, VUV, XAF, XOF, XPF }

enum CurrencyCode {
  USD,
  AED,
  AFN,
  ALL,
  AMD,
  ANG,
  AOA,
  ARS,
  AUD,
  AWG,
  AZN,
  BAM,
  BBD,
  BDT,
  BGN,
  BIF,
  BMD,
  BND,
  BOB,
  BRL,
  BSD,
  BWP,
  BYN,
  BZD,
  CAD,
  CDF,
  CHF,
  CLP,
  CNY,
  COP,
  CRC,
  CVE,
  CZK,
  DJF,
  DKK,
  DOP,
  DZD,
  EGP,
  ETB,
  EUR,
  FJD,
  FKP,
  GBP,
  GEL,
  GIP,
  GMD,
  GNF,
  GTQ,
  GYD,
  HKD,
  HNL,
  HRK,
  HTG,
  HUF,
  IDR,
  ILS,
  INR,
  ISK,
  JMD,
  JPY,
  KES,
  KGS,
  KHR,
  KMF,
  KRW,
  KYD,
  KZT,
  LAK,
  LBP,
  LKR,
  LRD,
  LSL,
  MAD,
  MDL,
  MGA,
  MKD,
  MMK,
  MNT,
  MOP,

  /// not longer valid MRO
  MUR,
  MVR,
  MWK,
  MXN,
  MYR,
  MZN,
  NAD,
  NGN,
  NIO,
  NOK,
  NPR,
  NZD,
  PAB,
  PEN,
  PGK,
  PHP,
  PKR,
  PLN,
  PYG,
  QAR,
  RON,
  RSD,
  RUB,
  RWF,
  SAR,
  SBD,
  SCR,
  SEK,
  SGD,
  SHP,

  ///old is SLL
  SLE,
  SOS,
  SRD,

  ///old is STD
  STN,
  SZL,
  THB,
  TJS,
  TOP,
  TRY,
  TTD,
  TWD,
  TZS,
  UAH,
  UGX,
  UYU,
  UZS,
  VND,
  VUV,
  WST,
  XAF,
  XCD,
  XOF,
  XPF,
  YER,
  ZAR,
  ZMW
}

enum AccountType {
  checking,
  savings,
  cash,
  creditCard,
  // lineOfCredit,
  otherAsset,
  otherLiability,
  mortgage,
  autoLoan,
  studentLoan,
  personalLoan,
  medicalDebt,
  otherDebt
}

String _toPascalCase(String name) {
  //https://stackoverflow.com/a/53719052
  final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
  final parts = name.split(beforeCapitalLetter);
  return toBeginningOfSentenceCase(parts.join(" "))!;
}

extension ToCase on AccountType {
  String get toSnakeCase {
    //ref: https://stackoverflow.com/a/57354678
    final exp = RegExp('(?<=[a-z])[A-Z]');
    return name.replaceAllMapped(exp, (m) => '_${m.group(0)}').toLowerCase();
  }

  String toTitleCase() => _toPascalCase(name);
}

enum AccountStatus { opened, closed, deleted }

class CurrencyNameMap {
  static const Map<String, String> map = {
    "AED": "United Arab Emirates dirham",
    "AFN": "Afghan afghani",
    "ALL": "Albanian lek",
    "AMD": "Armenian dram",
    "ANG": "Netherlands Antillean guilder",
    "AOA": "Angolan kwanza",
    "ARS": "Argentine peso",
    "AUD": "Australian dollar",
    "AWG": "Aruban florin",
    "AZN": "Azerbaijani manat",
    "BAM": "Bosnia and Herzegovina convertible mark",
    "BBD": "Barbados dollar",
    "BDT": "Bangladeshi taka",
    "BGN": "Bulgarian lev",
    "BHD": "Bahraini dinar",
    "BIF": "Burundian franc",
    "BMD": "Bermudian dollar",
    "BND": "Brunei dollar",
    "BOB": "Boliviano",
    "BOV": "Bolivian Mvdol (funds code)",
    "BRL": "Brazilian real",
    "BSD": "Bahamian dollar",
    "BTN": "Bhutanese ngultrum",
    "BWP": "Botswana pula",
    "BYN": "Belarusian ruble",
    "BZD": "Belize dollar",
    "CAD": "Canadian dollar",
    "CDF": "Congolese franc",
    "CHE": "WIR euro (complementary currency)",
    "CHF": "Swiss franc",
    "CHW": "WIR franc (complementary currency)",
    "CLF": "Unidad de Fomento (funds code)",
    "CLP": "Chilean peso",
    "COP": "Colombian peso",
    "COU": "Unidad de Valor Real (UVR) (funds code)[9]",
    "CRC": "Costa Rican colon",
    "CUC": "Cuban convertible peso",
    "CUP": "Cuban peso",
    "CVE": "Cape Verdean escudo",
    "CZK": "Czech koruna",
    "DJF": "Djiboutian franc",
    "DKK": "Danish krone",
    "DOP": "Dominican peso",
    "DZD": "Algerian dinar",
    "EGP": "Egyptian pound",
    "ERN": "Eritrean nakfa",
    "ETB": "Ethiopian birr",
    "EUR": "Euro",
    "FJD": "Fiji dollar",
    "FKP": "Falkland Islands pound",
    "GBP": "Pound sterling",
    "GEL": "Georgian lari",
    "GHS": "Ghanaian cedi",
    "GIP": "Gibraltar pound",
    "GMD": "Gambian dalasi",
    "GNF": "Guinean franc",
    "GTQ": "Guatemalan quetzal",
    "GYD": "Guyanese dollar",
    "HKD": "Hong Kong dollar",
    "HNL": "Honduran lempira",
    "HRK": "Croatian kuna",
    "HTG": "Haitian gourde",
    "HUF": "Hungarian forint",
    "IDR": "Indonesian rupiah",
    "ILS": "Israeli new shekel",
    "INR": "Indian rupee",
    "IQD": "Iraqi dinar",
    "IRR": "Iranian rial",
    "ISK": "Icelandic króna (plural: krónur)",
    "JMD": "Jamaican dollar",
    "JOD": "Jordanian dinar",
    "JPY": "Japanese yen",
    "KES": "Kenyan shilling",
    "KGS": "Kyrgyzstani som",
    "KHR": "Cambodian riel",
    "KMF": "Comoro franc",
    "KPW": "North Korean won",
    "KRW": "South Korean won",
    "KWD": "Kuwaiti dinar",
    "KYD": "Cayman Islands dollar",
    "KZT": "Kazakhstani tenge",
    "LAK": "Lao kip",
    "LBP": "Lebanese pound",
    "LKR": "Sri Lankan rupee",
    "LRD": "Liberian dollar",
    "LSL": "Lesotho loti",
    "LYD": "Libyan dinar",
    "MAD": "Moroccan dirham",
    "MDL": "Moldovan leu",
    "MGA": "Malagasy ariary",
    "MKD": "North Macedonian denar",
    "MMK": "Myanmar kyat",
    "MNT": "Mongolian tögrög",
    "MOP": "Macanese pataca",
    "MRU[12]": "Mauritanian ouguiya",
    "MUR": "Mauritian rupee",
    "MVR": "Maldivian rufiyaa",
    "MWK": "Malawian kwacha",
    "MXN": "Mexican peso",
    "MXV": "Mexican Unidad de Inversion (UDI) (funds code)",
    "MYR": "Malaysian ringgit",
    "MZN": "Mozambican metical",
    "NAD": "Namibian dollar",
    "NGN": "Nigerian naira",
    "NIO": "Nicaraguan córdoba",
    "NOK": "Norwegian krone",
    "NPR": "Nepalese rupee",
    "NZD": "New Zealand dollar",
    "OMR": "Omani rial",
    "PAB": "Panamanian balboa",
    "PEN": "Peruvian sol",
    "PGK": "Papua New Guinean kina",
    "PHP": "Philippine peso[13]",
    "PKR": "Pakistani rupee",
    "PLN": "Polish złoty",
    "PYG": "Paraguayan guaraní",
    "QAR": "Qatari riyal",
    "RON": "Romanian leu",
    "RSD": "Serbian dinar",
    "CNY": "Renminbi[14]",
    "RUB": "Russian ruble",
    "RWF": "Rwandan franc",
    "SAR": "Saudi riyal",
    "SBD": "Solomon Islands dollar",
    "SCR": "Seychelles rupee",
    "SDG": "Sudanese pound",
    "SEK": "Swedish krona (plural: kronor)",
    "SGD": "Singapore dollar",
    "SHP": "Saint Helena pound",
    "SLE": "Sierra Leonean leone",
    "SOS": "Somali shilling",
    "SRD": "Surinamese dollar",
    "SSP": "South Sudanese pound",
    "STN": "São Tomé and Príncipe dobra",
    "SVC": "Salvadoran colón",
    "SYP": "Syrian pound",
    "SZL": "Swazi lilangeni",
    "THB": "Thai baht",
    "TJS": "Tajikistani somoni",
    "TMT": "Turkmenistan manat",
    "TND": "Tunisian dinar",
    "TOP": "Tongan paʻanga",
    "TRY": "Turkish lira",
    "TTD": "Trinidad and Tobago dollar",
    "TWD": "New Taiwan dollar",
    "TZS": "Tanzanian shilling",
    "UAH": "Ukrainian hryvnia",
    "UGX": "Ugandan shilling",
    "USD": "United States dollar",
    "USN": "United States dollar (next day) (funds code)",
    "UYI": "Uruguay Peso en Unidades Indexadas (URUIURUI) (funds code)",
    "UYU": "Uruguayan peso",
    "UYW": "Unidad previsional[16]",
    "UZS": "Uzbekistan sum",
    "VED": "Venezuelan digital bolívar[17]",
    "VES": "Venezuelan sovereign bolívar[13]",
    "VND": "Vietnamese đồng",
    "VUV": "Vanuatu vatu",
    "WST": "Samoan tala",
    "XAF": "CFA franc BEAC",
    "XAG": "Silver (one troy ounce)",
    "XAU": "Gold (one troy ounce)",
    "XBA": "European Composite Unit (EURCO) (bond market unit)",
    "XBB": "European Monetary Unit (E.M.U.-6) (bond market unit)",
    "XBC": "European Unit of Account 9 (E.U.A.-9) (bond market unit)",
    "XBD": "European Unit of Account 17 (E.U.A.-17) (bond market unit)",
    "XCD": "East Caribbean dollar",
    "XDR": "Special drawing rights",
    "XOF": "CFA franc BCEAO",
    "XPD": "Palladium (one troy ounce)",
    "XPF": "CFP franc (franc Pacifique)",
    "XPT": "Platinum (one troy ounce)",
    "XSU": "SUCRE",
    "XTS": "Code reserved for testing",
    "XUA": "ADB Unit of Account",
    "XXX": "No currency",
    "YER": "Yemeni rial",
    "ZAR": "South African rand",
    "ZMW": "Zambian kwacha",
    "ZWL": "Zimbabwean dollar",
  };

  static Option<String> currencyNameOrNone(String code) {
    return optionOf(map[code]);
  }

  static List<Currency> get currencyCodeAndNameUiModelList {
    return CurrencyCode.values
        .map((e) => Currency(code: e.name, name: CurrencyNameMap.currencyNameOrNone(e.name).toNullable()!))
        .toList();
  }
}

class Currency {
  final String code;
  final String name;

  const Currency({required this.code, required this.name});

  CurrencyCode get toCurrencyCode => CurrencyCode.values.byName(code);
}
