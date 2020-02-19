import 'dart:ui';

import 'package:bgm/component/item_detail.dart';
import 'package:bgm/global/dio3.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class FavorItem extends StatefulWidget {
  FavorItem(this.id, {Key key, this.doing = false}) : super(key: key);
  final bool doing;
  final int id;

  @override
  _FavorItemState createState() => _FavorItemState();
}

class _FavorItemState extends State<FavorItem>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  double width = 1080;
  var data1, data2, data3; //1:bgm官方条目详情 2:czy0729/Bangumi-Subject条目数据 3:官方收藏状态
  Map<String, dynamic> showMap = {};
  bool isLoading = true;
  Animation<double> animation;
  AnimationController controller;

  Future<void> _getData() async {
    try {
      response = await dio.get('/subject/${widget.id}',
          queryParameters: {'responseGroup': 'large'});
      data1 = response.data;
      response = await dio.get(
          'https://cdn.jsdelivr.net/gh/czy0729/Bangumi-Subject@master/data/${(widget.id / 100).floor()}/${widget.id}.json');
      data2 = response.data;
      response = await dio.get('/collection/${widget.id}');
      if (response.data['code'] != 400) {
        data3 = response.data;
        showMap['rating'] = data3['rating'];

        var lastTouch =
            DateTime.fromMillisecondsSinceEpoch(data3['lasttouch'] * 1000);
        showMap['description2'] +=
            '${lastTouch.year}-${lastTouch.month.toString().padLeft(2)}-${lastTouch.day.toString().padLeft(2)}';
        if (data3['tag'] != null &&
            data3['tag'] != [] &&
            data3['tag'][0] != '') {
          showMap['description2'] += ' /';
          for (var v in data3['tag']) {
            showMap['description2'] += ' $v';
          }
        }
      }

      showMap['src'] = data1['images']['large'];
      showMap['name'] = data1['name_cn'] != '' ? data1['name'] : '';
      showMap['nameCN'] =
          data1['name_cn'] != '' ? data1['name_cn'] : data1['name'];
      showMap['description1'] = '${data1['eps_count']}话';

      if (data1['air_date'] == '0000-00-00') {
        Iterable<Match> matches =
            RegExp(r'\d{4}年\d{1,2}月(\d{1,2}日)?').allMatches('${data2['info']}');
        String timeStr = matches
            .toList()[0][0]
            .toString()
            .replaceAll('年', '-')
            .replaceAll('月', '-')
            .replaceAll('日', '');
        if (timeStr[timeStr.length - 1] == '-') {
          if (timeStr.length == 7) {
            timeStr = timeStr.substring(0, 4) + '0' + timeStr.substring(5, 6);
          }
          timeStr += '01';
        }
        var _time = DateTime.parse(timeStr);
        data1['air_date'] = _time.toString().substring(0, 10);
        showMap['description1'] += ' / ${_time.year}年${_time.month}月';
        if (matches.toList()[0][0].toString().length > 8) {
          showMap['description1'] += '${_time.day}日';
        }
      } else {
        showMap['description1'] +=
            ' / ${data1['air_date'].toString().substring(0, 4)}年${data1['air_date'].toString().substring(5, 7)}月${data1['air_date'].toString().substring(8)}日';
      }

      for (var v in data2['staff']) {
        if ('导演' == v['desc'] || '原作' == v['desc'] || '人物设计' == v['desc']) {
          showMap['description1'] += ' / ${v['name']}';
        }
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    ['src', 'name', 'nameCN', 'description1', 'description2', 'rating']
        .forEach((v) => showMap.putIfAbsent(v, () => ''));

    controller = AnimationController(
        duration: Duration(milliseconds: 2500), vsync: this);
    animation = Tween(begin: 0.22, end: 0.33).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);

    _getData().then((_) {
      setState(() {
          isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    var subTextStyle = TextStyle(
        fontWeight: FontWeight.normal, color: Colors.grey[600], fontSize: 13.2);

    return Container(
      height: 154,
      child: !isLoading
          ? FlatButton(
              padding: EdgeInsets.only(top: 6, bottom: 6),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left:15,right: 25),
                    width: 90,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 5,
                      ),
                    ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: ExtendedImage.network('${showMap['src']}'),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 3, bottom: 3),
                    width: width - 145,
                    child: Flex(
                      direction: Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "${showMap['nameCN']} ",
                                style: TextStyle(
                                    color: Colors.black,
                                    height: 1.6,
                                    fontSize: 14.5)),
                            TextSpan(
                                text: showMap['name'],
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromRGBO(0, 0, 0, 0.65),
                                    height: 1.6))
                          ]),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                        ),
                        Expanded(
                            flex: 3,
                            child: Center(
                              widthFactor: 1,
                              child: Text(
                                showMap['description1'],
                                maxLines: 2,
                                style: subTextStyle,
                              ),
                            )),
                        Expanded(
                            child: Row(
                          children: <Widget>[
                            showMap['rating'] != 0
                                ? Row(children: <Widget>[
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellow[600],
                                      size: 15,
                                    ),
                                    Text('${showMap['rating']}',
                                        style: TextStyle(
                                            color: Colors.yellow[600],
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13)),
                                    Text(' / ', style: subTextStyle),
                                  ])
                                : Text(''),
                            Text(
                              showMap['description2'],
                              style: subTextStyle,
                            ),
                          ],
                        ))
                      ],
                    ),
                  )
                ],
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ItemDetail(
                              data1['id'],
                              data1: data1,
                              data2: data2,
                              data3: data3,
                            )));
              },
            )
          : FadeTransition(
              opacity: animation,
              child: Center(
                heightFactor: 0.5,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 30, right: 15),
                      width: 90,
                      height: 120,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                      width: width - 140,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                height: 22,
                                width: width - 180,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(22),
                                )),
                            Container(
                                height: 16,
                                width: width - 240,
                                margin: EdgeInsets.only(top: 10, bottom: 42),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(16),
                                )),
                            Container(
                                height: 16,
                                width: width - 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(16),
                                ))
                          ]),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  dispose() {
    controller.dispose();
    super.dispose();
  }
}
