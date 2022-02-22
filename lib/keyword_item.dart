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
  SmzdmItem? smzdmFirst;
  bool loading = false;
  ReFetchSmzdmChangeNotifier? reFetchSmzdmChangeNotifier;

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
    setState(() {
      loading = true;
    });

    fetchISOString = DateTime.now().toIso8601String();

    final List<SmzdmItem> itemList = [];

    final List<Future> futureList = [];

    for (var i = 1; i <= 10; ++i) {
      futureList.add(searchKeyword(widget.keyword, page: i).then((list) {
        if (i == 1 && list.length > 1) {
          smzdmFirst = list.first;
        }

        final filteredList = list.where((element) {
          int zhi = int.parse(element.zhi);
          return zhi >= 10;
        });
        return filteredList;
      }));
    }

    final itemListList = await Future.wait(futureList);
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
            MaterialPageRoute(
              builder: (_) => UnreadList(smzdmItemList),
            ));
      },
      child: SizedBox(
        height: 40,
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
                  : smzdmItemList.isEmpty
                      ? const SizedBox.shrink()
                      : RawMaterialButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          constraints: const BoxConstraints.tightFor(
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            print(smzdmFirst);
                          },
                          elevation: 2.0,
                          fillColor: Colors.blue,
                          child: Text(
                            '${smzdmItemList.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          shape: const CircleBorder(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
