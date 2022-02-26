import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' show launch;

import 'models.dart';
import 'search_keyword.dart';

class UnreadList extends StatefulWidget {
  final List<SmzdmItem> smzdmItemList;
  final String keyword;

  const UnreadList(
    this.smzdmItemList, {
    Key? key,
    required this.keyword,
  }) : super(key: key);

  @override
  _UnreadListState createState() => _UnreadListState();
}

class _UnreadListState extends State<UnreadList> {
  late SharedPreferences prefs;
  KeywordItemModel keywordItemModel = KeywordItemModel();
  Completer completer = Completer();

  _UnreadListState() {
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();

    final keywordItemString = prefs.getString(widget.keyword);
    if (keywordItemString != null) {
      keywordItemModel = keywordItemModelFromJson(keywordItemString);
    }
    completer.complete(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          IconButton(
            onPressed: () async {
              keywordItemModel.readList = [];

              prefs.setString(
                  widget.keyword, keywordItemModelToJson(keywordItemModel));
            },
            icon: const Icon(Icons.block),
          ),
          IconButton(
            onPressed: () async {
              keywordItemModel.readList = widget.smzdmItemList
                  .map((e) => e.id)
                  .where((element) => element.isNotEmpty)
                  .toList();

              prefs.setString(
                  widget.keyword, keywordItemModelToJson(keywordItemModel));
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: FutureBuilder(
          future: completer.future,
          builder: (context, snapshot) {
            final theme = Theme.of(context);

            return !snapshot.hasData
                ? const SizedBox.shrink()
                : ListView(
                    children: [
                      for (var item in widget.smzdmItemList)
                        Dismissible(
                          key: Key(item.title),
                          confirmDismiss: (dir) async {
                            switch (dir) {
                              case DismissDirection.endToStart:
                                break;
                              case DismissDirection.startToEnd:
                                widget.smzdmItemList.remove(item);
                                if (item.id.isNotEmpty) {
                                  final isExist = keywordItemModel.readList
                                      .contains(item.id);
                                  if (!isExist) {
                                    keywordItemModel.readList.add(item.id);
                                  }
                                }
                                prefs.setString(widget.keyword,
                                    keywordItemModelToJson(keywordItemModel));
                                return true;
                              default:
                            }
                            return false;
                          },
                          child: SmzdmWidget(
                            item,
                            color: keywordItemModel.readList.contains(item.id)
                                ? theme.disabledColor
                                : null,
                            onTap: () {
                              if (item.href.isNotEmpty) {
                                launch(item.href);
                              }
                            },
                          ),
                        ),
                    ],
                  );
          }),
    );
  }
}
