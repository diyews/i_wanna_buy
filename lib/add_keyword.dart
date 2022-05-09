import 'package:flutter/material.dart';

import 'package:i_wanna_buy/search_keyword.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddKeyword extends StatefulWidget {
  const AddKeyword({Key? key}) : super(key: key);

  @override
  _AddKeywordState createState() => _AddKeywordState();
}

class _AddKeywordState extends State<AddKeyword> {
  final TextEditingController _controller = TextEditingController();
  List<SmzdmItem> itemList = [];

  search() async {
    final searchText = _controller.text;
    if (searchText.isEmpty) return;

    itemList.addAll(await searchKeyword(searchText).then((res) => res.list));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          controller: _controller,
          cursorColor: Colors.white,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) {
            search();
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: IconButton(
              onPressed: () async {
                search();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          final theme = Theme.of(context);
          final item = itemList[index];

          return Dismissible(
            key: Key(item.title),
            onDismissed: (dir) {
              itemList.removeAt(index);
            },
            child: SmzdmWidget(
              item,
              color: index.isEven ? theme.dividerColor : null,
            ),
          );
        },
      ),
      floatingActionButton: _controller.text.isEmpty
          ? const SizedBox.shrink()
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                final List<String> items =
                    prefs.getStringList('keywords') ?? [];
                items.add(_controller.text);

                prefs.setStringList('keywords', items);
                Navigator.pop(context);
              },
            ),
    );
  }
}
