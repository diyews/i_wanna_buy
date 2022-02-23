import 'dart:convert';

import 'package:flutter/cupertino.dart';

KeywordItemModel keywordItemModelFromJson(String str) =>
    KeywordItemModel.fromJson(json.decode(str));

String keywordItemModelToJson(KeywordItemModel data) =>
    json.encode(data.toJson());

class KeywordItemModel {
  KeywordItemModel({
    this.date = '',
    readList,
  }) : readList = readList ?? [];

  String date;
  List<String> readList;

  factory KeywordItemModel.fromJson(Map<String, dynamic> json) =>
      KeywordItemModel(
        date: json["date"],
        readList: List<String>.from(json["readList"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "readList": List<dynamic>.from(readList.map((x) => x)),
      };
}

class ReFetchSmzdmChangeNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
