import 'package:flutter/material.dart';

import 'search_keyword.dart';

class UnreadList extends StatefulWidget {
  final List<SmzdmItem> smzdmItemList;

  const UnreadList(this.smzdmItemList, {Key? key}) : super(key: key);

  @override
  _UnreadListState createState() => _UnreadListState();
}

class _UnreadListState extends State<UnreadList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: ListView(
        children: [
          for (var item in widget.smzdmItemList) SmzdmWidget(item),
        ],
      ),
    );
  }
}
