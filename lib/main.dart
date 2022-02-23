import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_keyword.dart';
import 'keyword_item.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wymsm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> keywordList = [];
  final ReFetchSmzdmChangeNotifier reFetchSmzdmChangeNotifier =
      ReFetchSmzdmChangeNotifier();

  @override
  void initState() {
    super.initState();

    retrieveKeyword();
  }

  retrieveKeyword() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      keywordList = prefs.getStringList('keywords') ?? [];
    });
  }

  @override
  void dispose() {
    super.dispose();

    reFetchSmzdmChangeNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddKeyword(),
                ),
              );

              retrieveKeyword();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              final res = await showDialog(
                  context: context,
                  builder: (context) {
                    return const _ZhiCountDialog();
                  });

              if (res == true) {
                reFetchSmzdmChangeNotifier.notify();
              }
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: keywordList.isEmpty
          ? const Center(child: Text('Empty'))
          : InheritedProvider(
              create: (_) => reFetchSmzdmChangeNotifier,
              child: RefreshIndicator(
                onRefresh: () async {
                  reFetchSmzdmChangeNotifier.notify();
                },
                child: ListView.builder(
                  itemCount: keywordList.length,
                  itemBuilder: (context, index) {
                    final keyword = keywordList[index];

                    return Dismissible(
                      confirmDismiss: (dir) async {
                        switch (dir) {
                          case DismissDirection.endToStart:
                            break;
                          case DismissDirection.startToEnd:
                            final keyword = keywordList[index];
                            keywordList.removeAt(index);
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setStringList('keywords', keywordList);
                            prefs.remove(keyword);
                            return true;
                          default:
                        }
                        return false;
                      },
                      key: Key(keyword),
                      child: KeywordItem(keyword),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _ZhiCountDialog extends StatefulWidget {
  const _ZhiCountDialog({Key? key}) : super(key: key);

  @override
  _ZhiCountDialogState createState() => _ZhiCountDialogState();
}

class _ZhiCountDialogState extends State<_ZhiCountDialog> {
  late int zhiCount;
  late SharedPreferences prefs;
  final Completer completer = Completer();

  _ZhiCountDialogState() {
    SharedPreferences.getInstance().then((_prefs) {
      prefs = _prefs;
      zhiCount = _prefs.getInt('zhiCount') ?? 10;
      completer.complete(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: completer.future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return AlertDialog(
              content: NumberPicker(
                value: zhiCount,
                minValue: 1,
                maxValue: 20,
                onChanged: (value) => setState(() {
                  zhiCount = value;
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    prefs.setInt('zhiCount', zhiCount);
                    Navigator.pop(context, true);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          } else {
            return Container();
          }
        });
  }
}
