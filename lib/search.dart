import 'package:bgm/component/search_item.dart';
import 'package:bgm/global/dio3.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  List<String> keywords = [];
  bool _haveSearched = false;
  TextEditingController controller = TextEditingController();
  String type = 'all';
  double height = 1920, width = 1080;
  GlobalKey anchorKey = GlobalKey();
  Map<String, dynamic> data = {};

  List<String> get showKeywords => keywords
      .where(
          (item) => item.toLowerCase().contains(controller.text.toLowerCase()))
      .toList();
  String get typeCN => {
        'all': '全部',
        'anime': '动画',
        'book': '书籍',
        'music': '音乐',
        'game': '游戏',
        'real': '三次元',
      }[type];

  Future<void> search(String keyword) async {
    controller.removeListener(_listener);
    setState(() {
      _haveSearched = true;
      data = {};
    });

    // 储存搜索记录
    var prefs = await SharedPreferences.getInstance();
    List<String> _temp = prefs.getStringList('search_history');
    _temp = null != _temp ? _temp : [];
    if (!_temp.contains(keyword)) {
      _temp.insertAll(0, [keyword]);
      if (_temp.length > 10) {
        _temp = _temp.sublist(0, 10);
      }
      prefs.setStringList('search_history', _temp);
    }

    List<String> _typeList = [
      '',
      'book',
      'anime',
      'music',
      'game',
      ' ',
      'real'
    ];

    try {
      Map<String, dynamic> _queryParameters = {
        'max_results': 25,
        'start': 0,
      };
      if ('all' != type) {
        _queryParameters.putIfAbsent('type', () => _typeList.indexOf(type));
      }

      response = await dio.get(
          '/search/subject/${Uri.encodeComponent(keyword)}?responseGroup=large',
          queryParameters: _queryParameters,
          options: Options(contentType: Headers.formUrlEncodedContentType));
      setState(() {
        data = response.data;
      });
    } on DioError catch (e) {
      print(e.request);
      print(e.response);
    }
  }

  Future<void> getLocalKeywords() async {
    var prefs = await SharedPreferences.getInstance();
    List<String> _temp = prefs.getStringList('search_history');
    setState(() {
      keywords = null != _temp ? _temp : [];
    });
  }

  void _listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getLocalKeywords();
    controller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('搜索'),
        ),
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // 触摸收起键盘
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Container(
                  height: 36,
                  margin: EdgeInsets.only(top: 13, bottom: 17),
                  padding: EdgeInsets.only(left: (width - 370) / 2),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 36,
                        width: 70,
                        child: FlatButton(
                          key: anchorKey,
                          padding: EdgeInsets.only(left: 8),
                          child: Text(typeCN),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () {
                            RenderBox renderBox =
                                anchorKey.currentContext.findRenderObject();
                            var offset = renderBox.localToGlobal(
                                Offset(0.0, renderBox.size.height));
                            showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                    offset.dx, offset.dy, 1000, 1000),
                                items: [
                                  PopupMenuItem(
                                    child: Text('全部'),
                                    value: 'all',
                                  ),
                                  PopupMenuItem(
                                    child: Text('动画'),
                                    value: 'anime',
                                  ),
                                  PopupMenuItem(
                                    child: Text('书籍'),
                                    value: 'book',
                                  ),
                                  PopupMenuItem(
                                    child: Text('游戏'),
                                    value: 'game',
                                  ),
                                  PopupMenuItem(
                                    child: Text('音乐'),
                                    value: 'music',
                                  ),
                                  PopupMenuItem(
                                    child: Text('三次元'),
                                    value: 'real',
                                  )
                                ]).then((v) {
                              if (null != v) {
                                setState(() {
                                  type = v;
                                });
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(36),
                                  bottomLeft: Radius.circular(36))),
                        ),
                      ),
                      Container(
                          width: width - 190,
                          child: TextField(
                            controller: controller,
                            style: TextStyle(height: 1.2),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(36),
                                      bottomRight: Radius.circular(36))),
                              contentPadding:
                                  EdgeInsets.only(left: 8, right: 12), //保持垂直居中
                              hintText: 'Text to search',
                            ),
                            maxLines: 1,
                          )),
                      Container(
                        height: 36,
                        width: 70,
                        margin: EdgeInsets.only(left: 10),
                        child: RaisedButton(
                          child: Text('搜索'),
                          color: Colors.blue[400],
                          textColor: Colors.white,
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            search(controller.text);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(36))),
                        ),
                      ),
                    ],
                  )),
              Flex(direction: Axis.horizontal, children: <Widget>[
                Expanded(
                  child: Text(
                    '      ' + (!_haveSearched ? '历史记录' : '搜索结果'),
                  ),
                  flex: 1,
                ),
                !_haveSearched
                    ? GestureDetector(
                        child: Container(
                            margin: EdgeInsets.only(right: 25),
                            child: Text('清空')),
                        onTap: () async {
                          setState(() {
                            keywords = [];
                          });
                          var prefs = await SharedPreferences.getInstance();
                          prefs.remove('search_history');
                        })
                    : Container()
              ]),
              Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Divider(
                    color: Colors.grey[700],
                  )),
              !_haveSearched
                  ? Container(
                      height: height - 188,
                      child: keywords.isEmpty
                          ? Center(
                              child: Text('你好像还没有搜索过'),
                            )
                          : (showKeywords.length != 0
                              ? ListView.builder(
                                  itemCount: showKeywords.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.only(left: 15, right: 15),
                                      child: ListTile(
                                        title: Text(
                                            showKeywords[index].toString()),
                                        onTap: () {
                                          controller.text =
                                              showKeywords[index].toString();
                                          search(controller.text);
                                        },
                                        dense: true,
                                      ),
                                    );
                                  })
                              : Center(
                                  child: Text('没有相关的记录哦'),
                                )),
                    )
                  : Container(
                      height: height - 183,
                      child: data.isNotEmpty
                          ? ListView.separated(
                              itemCount: data['list'].length,
                              itemBuilder: (context, index) {
                                data['list'][index].putIfAbsent(
                                    'rating', () => {'total': 0, 'score': 0});
                                return SearchItem(data['list'][index], width);
                              },
                              separatorBuilder: (context, index) {
                                return Container(
                                  width: width - 40,
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child: Divider(),
                                );
                              },
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                            ))
            ])));
  }

  @override
  bool get wantKeepAlive => true;
}
