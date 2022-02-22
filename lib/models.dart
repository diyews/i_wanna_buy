import 'dart:convert';

import 'package:flutter/cupertino.dart';

KeywordItemModel keywordItemModelFromJson(String str) =>
    KeywordItemModel.fromJson(json.decode(str));

String keywordItemModelToJson(KeywordItemModel data) =>
    json.encode(data.toJson());

class KeywordItemModel {
  KeywordItemModel({
    this.date = '',
    this.unread = false,
  });

  String date;
  bool unread;

  factory KeywordItemModel.fromJson(Map<String, dynamic> json) =>
      KeywordItemModel(
        date: json["date"],
        unread: json["unread"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "unread": unread,
      };
}

class ReFetchSmzdmChangeNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
