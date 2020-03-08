import 'dart:ui';

import 'package:bgm/component/chilboard.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../global/dio3.dart';
import 'item_detail_favour.dart';

class ItemDetail extends StatefulWidget {
  ItemDetail(this.id,
      {Key key, this.data1, this.data2, this.data3, this.calendar = false})
      : super(key: key);
  final Map<String, dynamic> data1, data2, data3;
  final int id;
  final bool calendar;

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  ScrollController controller = ScrollController();
  bool hide = false, loading = true;
  Map<String, dynamic> data1 = {}, data2 = {}, data3, eps = {};
  double height = 1980, width = 1080, appBarOpacity = 0;
  int offsetY = 0;
  Color coverColor1 = Colors.grey[200], coverColor2 = Colors.grey[200];
  var anchorKey = GlobalKey();

  Future<void> getItemData() async {
    if (widget.data1 == null || widget.calendar) {
      try {
        response = await dio.get('/subject/${widget.id}?responseGroup=large');
        data1 = response.data;
      } catch (e) {}
    } else {
      data1 = widget.data1;
    }

    if (widget.data2 == null) {
      try {
        response = await dio.get(
            'https://cdn.jsdelivr.net/gh/czy0729/Bangumi-Subject@master/data/${(widget.id / 100).floor()}/${widget.id}.json');
        data2 = response.data;
      } on DioError catch (e) {
        // 未被收录，会返回该id段所有条目信息，导致大小超过50MB返回403
        if (e.response.statusCode == 403) {
          data2 = {
            "rating": {
              "total": 0,
              "count": {
                "1": 0,
                "2": 0,
                "3": 0,
                "4": 0,
                "5": 0,
                "6": 0,
                "7": 0,
                "8": 0,
                "9": 0,
                "10": 0
              },
              "score": 0
            },
            "summary": "",
            "info": '',
            "tags": [],
            "eps": [],
            "crt": [],
            "staff": [],
            "relations": [],
          };
        }
      }
    } else {
      data2 = widget.data2;
    }

    if (widget.data3 != null) {
      data3 = widget.data3;
    }

    getImageFromProvider(ExtendedNetworkImageProvider(data1['images']['large']))
        .then((image) {
      getColorFromImage(image).then((color) {
        setState(() {
          coverColor1 = Color.fromRGBO(color[0], color[1], color[2], 1);
          coverColor2 = Color.fromRGBO(color[0], color[1], color[2], 0.1);
        });
      });
    });

    _checkNullData();
    setState(() {});
  }

  void _checkNullData() {
    data1.forEach((key, value) {
      if (value == null && (key == 'crt' || key == 'staff' || key == 'eps')) {
        data1[key] = [];
      }
    });
    for (var key in ['crt', 'staff', 'eps']) {
      data1.putIfAbsent(key, () => []);
    }
  }

  List<Widget> crtList() {
    WebViewController _controller;
    String _title = "详情";
    List<Widget> _temp = [];
    List _crtList = data1['crt'] == null ? [] : data1['crt'];

    if (_crtList.isEmpty) {
      return [Text('暂无角色信息', style: TextStyle(fontSize: 15))];
    } else {
      for (var item in _crtList) {
        _temp.add(GestureDetector(
          child: Container(
              width: 250,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: ExtendedImage.network(
                      item['images']['grid'],
                      cache: true,
                      loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: CircularProgressIndicator(),
                            );
                            break;
                          case LoadState.completed:
                            return null;
                            break;
                          case LoadState.failed:
                            state.reLoadImage();
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                            break;
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 12),
                      width: 150,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(item['name'],
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 132, 180, 1),
                                    fontSize: 14.8)),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: '${item['role_name']} ',
                                      style: TextStyle(color: Colors.grey)),
                                  TextSpan(
                                      text: item['name_cn'] == ''
                                          ? item['name']
                                          : item['name_cn'],
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(102, 102, 102, 1)))
                                ],
                              ),
                            ),
                            item['actors'] != null
                                ? RichText(
                                    text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: 'CV: ',
                                          style: TextStyle(color: Colors.grey)),
                                      TextSpan(
                                          text: item['actors'][0]['name'],
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  102, 102, 102, 1)))
                                    ],
                                  ))
                                : Container()
                          ])),
                ],
              )),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (contFext) => Scaffold(
                    appBar: AppBar(
                      title: Text(_title),
                    ),
                    body: WebView(
                      initialUrl: item['url'],
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (controller) {
                        _controller = controller;
                      },
                      onPageFinished: (url) {
                        _controller
                            .evaluateJavascript("document.title")
                            .then((result) {
                          setState(() {
                            _title = 'result';
                          });
                        });
                      },
                    ),
                  ))),
        ));
      }
    }

    return _temp;
  }

  @override
  void initState() {
    super.initState();

    getItemData().then((v) {
      loading = false;
      if (!widget.calendar) {
        setState(() {});
      }
    });
  }

  _onScroll(offset) {
    double opacity = offset / 200;
    if (opacity < 0) {
      opacity = 0;
    } else if (opacity > 1) {
      opacity = 1;
    }
    setState(() {
      appBarOpacity = opacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    var _paddingTop = MediaQueryData.fromWindow(window).padding.top;

    return Scaffold(
        body: Stack(
      children: <Widget>[
        !loading
            ? MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: NotificationListener(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification &&
                        scrollNotification.depth == 0) {
                      _onScroll(scrollNotification.metrics.pixels);
                    }
                    return;
                  },
                  child: SingleChildScrollView(
                    child: Stack(children: [
                      //顶部
                      Positioned(
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  coverColor1,
                                  coverColor2,
                                  coverColor1
                                ]),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 120),
                        height: 40,
                        decoration: BoxDecoration(
                            color: ThemeData().scaffoldBackgroundColor,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(35),
                                topRight: Radius.circular(35))),
                      ),

                      // 主要内容
                      Column(children: [
                        Container(
                          height: _paddingTop + 230,
                          padding:
                              EdgeInsets.only(top: _paddingTop + 40, left: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 27),
                                child: ExtendedImage.network(
                                  data1['images']['large'],
                                  width: 115,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  shape: BoxShape.rectangle,
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  cache: true,
                                ),
                              ),
                              Container(
                                width: width - 155,
                                margin: EdgeInsets.only(top: 63, left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      data1['name'],
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11.5),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: Text(
                                        '' != data1['name_cn']
                                            ? data1['name_cn']
                                            : data1['name'],
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Row(children: [
                                        Text(
                                            '${data1['rating']['score'].toStringAsFixed(1)}',
                                            style: TextStyle(
                                                color: Colors.pink[300],
                                                fontSize: 18)),
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3),
                                          decoration: BoxDecoration(
                                              color: Colors.pink[300],
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Text(
                                              GlobalVar().getRating(
                                                  data1['rating']['score']
                                                      .ceil()),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              )),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(),
                        FavourWidget(
                          {
                            'id': data1['id'],
                            'name': data1['name'],
                            'name_cn': data1['name_cn'],
                            'collection': data1['collection'],
                            'tags': data2['tags']
                          },
                          data3,
                        ),
                        Divider(),
                        Container(
                          constraints:
                              BoxConstraints(minHeight: 60, maxHeight: 200),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: crtList(),
                            ),
                          ),
                        ),
                        Container(
                          height: 1600,
                        ),
                      ])
                    ]),
                  ),
                ))
            : Center(
                child: CircularProgressIndicator(),
              ),

        // 两个模拟按键
        SafeArea(
            child: Container(
                margin: EdgeInsets.only(left: 3, top: 4), // 不确定在各种分辨率上是否表现一致。
                child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {}))),
        SafeArea(
            child: Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 4),
                child: IconButton(
                    icon: Icon(Icons.more_horiz),
                    color: Colors.white,
                    onPressed: () {}))),
        // 随滑动渐显的appBar
        Opacity(
          opacity: appBarOpacity,
          child: Container(
            height: _paddingTop + 56, // 56为MD appBar的高度
            child: AppBar(
              title: Text(
                  '${data1['name_cn'] == '' ? data1['name'] : data1['name_cn']}'),
              actions: <Widget>[
                IconButton(
                    key: anchorKey,
                    icon: Icon(Icons.more_horiz),
                    onPressed: () {
                      RenderBox renderBox =
                          anchorKey.currentContext.findRenderObject();
                      var offset = renderBox
                          .localToGlobal(Offset(0.0, renderBox.size.height));

                      showMenu(
                          context: context,
                          position: RelativeRect.fromLTRB(
                              offset.dx, offset.dy - 10, 0, 0),
                          items: [
                            PopupMenuItem(
                              child: Text('复制链接'),
                              value: 'copy',
                            )
                          ]).then((value) {
                        if (value == 'copy') {
                          Clipboard.setData(ClipboardData(text: data1['url']))
                              .then((_) {
                            BotToast.showText(text: '已复制');
                          });
                        }
                      });
                    })
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
