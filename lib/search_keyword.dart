import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<SearchKeywordResult> searchKeyword(
  String keyword, {
  int page = 1,
}) async {
  final url = Uri.parse(
      'https://search.smzdm.com/?c=faxian&s=$keyword&order=time&v=b&p=$page');
  final response = await http.get(url, headers: {
    "cookie": "ssmx_ab=mxss14;",
    "user-agent":
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36",
    "Host": "search.smzdm.com"
  }).timeout(
    const Duration(seconds: 12),
    onTimeout: () => http.Response('Timeout', 408),
  );
  final String body = utf8.decode(response.bodyBytes);

  if (body != 'Timeout') {
    return compute(_extraSmzdmItem, body);
  } else {
    return SearchKeywordResult([], status: 'timeout');
  }
}

class SmzdmWidget extends StatelessWidget {
  final SmzdmItem item;
  final Color? color;
  final GestureTapCallback? onTap;

  const SmzdmWidget(
    this.item, {
    Key? key,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const numberSpacer = SizedBox(
      width: 8,
    );

    final theme = Theme.of(context);
    final backgroundColor = color ?? theme.colorScheme.onSecondary;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Text(item.title),
              Text(
                item.price,
                style: const TextStyle(color: Colors.red),
              ),
              Text(
                item.tag,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(75),
                  decoration:
                      item.isPastDue ? TextDecoration.lineThrough : null,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(item.zhi),
                      numberSpacer,
                      Text(item.buzhi),
                      numberSpacer,
                      Text(item.comment),
                    ],
                  ),
                  Row(
                    children: [
                      Text(item.time),
                      numberSpacer,
                      Text(item.platform),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SmzdmItem {
  final String id;
  final String title;
  final String price;
  final String tag;
  final String desc;
  final String zhi;
  final String buzhi;
  final String comment;
  final String time;
  final String platform;
  final String href;
  final bool isPastDue;

  SmzdmItem({
    required String? id,
    required String? title,
    required String? price,
    required String? tag,
    String? desc = '',
    required String? zhi,
    required String? buzhi,
    required String? comment,
    required String? time,
    required String? platform,
    required String? href,
    this.isPastDue = false,
  })  : id = (id ?? '').trim(),
        title = (title ?? '').trim(),
        price = (price ?? '').trim(),
        tag = (tag ?? '').trim(),
        desc = (desc ?? '').trim(),
        zhi = (zhi ?? '').trim(),
        buzhi = (buzhi ?? '').trim(),
        comment = (comment ?? '').trim(),
        time = (time ?? '').trim(),
        platform = (platform ?? '').trim(),
        href = (href ?? '').trim();
}

class SearchKeywordResult {
  final String status;
  final List<SmzdmItem> list;

  SearchKeywordResult(
    this.list, {
    this.status = 'success',
  });
}

SearchKeywordResult _extraSmzdmItem(String body) {
  final document = parse(body);
  final List<SmzdmItem> resList = [];
  final items = document.getElementsByClassName('feed-row-wide');

  for (var item in items) {
    final title = item.querySelector('.feed-nowrap');
    final price = item.querySelector('.z-highlight');
    final tag = item.querySelector('.feed-block-tags');
    final desc = item.querySelector('.feed-block-descripe-top');
    final zhi = item.querySelector('.z-icon-zhi-o-thin + span');
    final buzhi = item.querySelector('.z-icon-buzhi-o-thin + span');
    final comment = item.querySelector('.feed-btn-comment');
    final extras = item.querySelector('.feed-block-extras');
    final bool isPastDue = item.querySelector('.search-pastdue-mark') != null;

    final idRegExp = RegExp(r'/(\d+?)/');
    final String href = title?.attributes['href'] ?? '';
    String id = '';
    if (href.isNotEmpty) {
      final match = idRegExp.firstMatch(href);
      if (match?.groupCount == 1) {
        id = match!.group(1)!;
      }
    }

    resList.add(SmzdmItem(
      id: id,
      title: title?.text,
      price: price?.text,
      tag: tag?.text,
      zhi: zhi?.text,
      buzhi: buzhi?.text,
      comment: comment?.text,
      time: extras?.nodes[0].text,
      platform: extras?.nodes[1].text,
      href: href,
      isPastDue: isPastDue,
    ));
  }

  return SearchKeywordResult(resList);
}
