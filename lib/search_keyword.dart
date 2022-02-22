import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<List<SmzdmItem>> searchKeyword(
  String keyword, {
  int page = 1,
}) async {
  final url = Uri.parse(
      'https://search.smzdm.com/?c=faxian&s=$keyword&order=time&v=b&p=$page');
  final response = await http.get(url);
  final String body = utf8.decode(response.bodyBytes);

  final List<SmzdmItem> resList = await compute(_extraSmzdmItem, body);

  return resList;
}

class SmzdmWidget extends StatelessWidget {
  final SmzdmItem item;
  final bool isEven;

  const SmzdmWidget(this.item, {Key? key, this.isEven = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const numberSpacer = SizedBox(
      width: 8,
    );

    return Container(
      color: isEven ? const Color(0xffe4e4e4) : Colors.white,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(item.title),
          Text(
            item.price,
            style: const TextStyle(color: Colors.red),
          ),
          Text(
            item.tag,
            style: const TextStyle(color: Colors.black38),
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
    );
  }
}

class SmzdmItem {
  final String title;
  final String price;
  final String tag;
  final String desc;
  final String zhi;
  final String buzhi;
  final String comment;
  final String time;
  final String platform;

  SmzdmItem({
    required String? title,
    required String? price,
    required String? tag,
    String? desc = '',
    required String? zhi,
    required String? buzhi,
    required String? comment,
    required String? time,
    required String? platform,
  })  : title = (title ?? '').trim(),
        price = (price ?? '').trim(),
        tag = (tag ?? '').trim(),
        desc = (desc ?? '').trim(),
        zhi = (zhi ?? '').trim(),
        buzhi = (buzhi ?? '').trim(),
        comment = (comment ?? '').trim(),
        time = (time ?? '').trim(),
        platform = (platform ?? '').trim();
}

List<SmzdmItem> _extraSmzdmItem(String body) {
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

    resList.add(SmzdmItem(
        title: title?.text,
        price: price?.text,
        tag: tag?.text,
        zhi: zhi?.text,
        buzhi: buzhi?.text,
        comment: comment?.text,
        time: extras?.nodes[0].text,
        platform: extras?.nodes[1].text));
  }

  return resList;
}
