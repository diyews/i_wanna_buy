import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i_wanna_buy/unread_list.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'search_keyword.dart';

class KeywordItem extends StatefulWidget {
  final String keyword;

  const KeywordItem(this.keyword, {Key? key}) : super(key: key);

  @override
  _KeywordItemState createState() => _KeywordItemState();
}

class _KeywordItemState extends State<KeywordItem> {
  final currentISOString = DateTime.now().toIso8601String();
  String fetchISOString = DateTime.now().toIso8601String();
  KeywordItemModel keywordItem = KeywordItemModel();
  List<SmzdmItem> smzdmItemList = [];
  bool loading = false;
  ReFetchSmzdmChangeNotifier? reFetchSmzdmChangeNotifier;
  int toReadCount = 0;
  int timeoutCount = 0;

  @override
  void initState() {
    super.initState();

    queryData();
  }

  queryData() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonStr = prefs.getString(widget.keyword);

    if (jsonStr != null) {
      keywordItem = keywordItemModelFromJson(jsonStr);
    }

    startFetch();
  }

  startFetch() async {
    toReadCount = 0;
    timeoutCount = 0;
    setState(() {
      loading = true;
    });

    fetchISOString = DateTime.now().toIso8601String();

    final prefs = await SharedPreferences.getInstance();
    final zhiCount = prefs.getInt('zhiCount') ?? 10;
    final String? keywordItemString = prefs.getString(widget.keyword);
    KeywordItemModel keywordItemModel = KeywordItemModel();
    if (keywordItemString != null) {
      keywordItemModel = keywordItemModelFromJson(keywordItemString);
    }

    final List<SmzdmItem> itemList = [];
    final List<Future<List<SmzdmItem>>> futureList = [];

    for (var i = 1; i <= 10; ++i) {
      futureList.add(searchKeyword(widget.keyword, page: i).then((result) {
        final list = result.list;
        // early return of timeout
        if (result.status == 'timeout') {
          timeoutCount++;
          return list;
        }

        final filteredList = list.where((element) {
          int zhi = int.parse(element.zhi);
          return zhi >= zhiCount;
        }).toList();
        final toReadList = filteredList.where((element) {
          if (element.id.isNotEmpty) {
            return !keywordItemModel.readList.contains(element.id);
          }
          return true;
        });
        toReadCount += toReadList.length;
        return filteredList;
      }));
    }

    List<Iterable<SmzdmItem>> itemListList = [];
    try {
      itemListList = await Future.wait(futureList);
    } catch (_) {}

    for (var _itemList in itemListList) {
      itemList.addAll(_itemList);
    }

    setState(() {
      smzdmItemList = itemList;
      loading = false;
    });
  }

  reFetchListener() {
    smzdmItemList.clear();
    startFetch();
  }

  setupReFetchListener(ReFetchSmzdmChangeNotifier notifier) {
    if (reFetchSmzdmChangeNotifier != null) return;
    reFetchSmzdmChangeNotifier = notifier;

    notifier.addListener(reFetchListener);
  }

  @override
  void dispose() {
    super.dispose();

    reFetchSmzdmChangeNotifier?.removeListener(reFetchListener);
  }

  @override
  Widget build(BuildContext context) {
    setupReFetchListener(context.read<ReFetchSmzdmChangeNotifier>());

    return InkWell(
      onTap: () {
        if (smzdmItemList.isEmpty) return;

        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => UnreadList(
                smzdmItemList,
                keyword: widget.keyword,
              ),
            ));
      },
      child: SizedBox(
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(widget.keyword),
            ),
            Positioned(
              right: 12,
              child: loading
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      children: [
                        if (timeoutCount != 0)
                          _MyRawMaterialButton(
                            onPressed: () {},
                            child: Text(
                              '$timeoutCount',
                              style: const TextStyle(color: Colors.white),
                            ),
                            fillColor: Colors.grey.shade600,
                          ),
                        if (toReadCount != 0)
                          const SizedBox(
                            width: 8,
                          ),
                        if (toReadCount != 0)
                          _MyRawMaterialButton(
                            onPressed: () {},
                            child: Text(
                              '$toReadCount',
                              style: const TextStyle(color: Colors.white),
                            ),
                            fillColor: Colors.green.shade600,
                          ),
                        if (smzdmItemList.isNotEmpty)
                          const SizedBox(
                            width: 8,
                          ),
                        if (smzdmItemList.isNotEmpty)
                          _MyRawMaterialButton(
                            onPressed: () {},
                            child: Text(
                              '${smzdmItemList.length}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            fillColor: Colors.blue,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyRawMaterialButton extends RawMaterialButton {
  const _MyRawMaterialButton({
    Key? key,
    required onPressed,
    fillColor,
    child,
  }) : super(
          key: key,
          onPressed: onPressed,
          fillColor: fillColor,
          child: child,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          constraints: const BoxConstraints.tightFor(
            width: 24,
            height: 24,
          ),
          elevation: 2.0,
          shape: const CircleBorder(),
        );
}
