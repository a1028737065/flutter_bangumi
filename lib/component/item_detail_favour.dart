import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../global/dio3.dart';
import '../main.dart';

class FavourWidget extends StatefulWidget {
  FavourWidget(this.basicInfo, this.collectionStatus, {Key key})
      : super(key: key);

  final Map<String, dynamic> basicInfo,
      collectionStatus; //自己的收藏状态, {}表示未收藏, null表示请求失败
  @override
  _FavourWidgetState createState() => _FavourWidgetState();
}

class _FavourWidgetState extends State<FavourWidget> {
  Map<String, int> collection;
  Map<String, dynamic> collectionStatus;
  bool _loading = true, haveCollected = false;
  var typeCN = {
    'wish': '想看',
    'collect': '看过',
    'do': '在看',
    'on_hold': '搁置',
    'dropped': '抛弃'
  };

  @override
  void initState() {
    super.initState();
    collection = null != widget.basicInfo['collection']
        ? Map.from(widget.basicInfo['collection'])
        : {};
    if (widget.collectionStatus != null) {
      collectionStatus = widget.collectionStatus;
      _loading = false;
      haveCollected = true;
    } else {
      getCollectionStatus().then((_) {
        setState(() {
          _loading = false;
        });
      });
    }
  }

  Future<void> getCollectionStatus() async {
    print('start');
    try {
      response = await dio.get('/collection/${widget.basicInfo['id']}');
      //未收藏时仍会正常响应
      if (response.data['error'] == null) {
        collectionStatus = response.data;
        haveCollected = true;
      } else {
        collectionStatus = {
          "status": {"type": "", "name": ""},
          "rating": 0,
          "comment": "",
          "private": 0,
          "tag": [''],
        };
      }
    } catch (e) {}
  }

  Widget get _buttonChild => _creatButtonChild();

  Widget _creatButtonChild() {
    if (myDio.isLogIn) {
      if (_loading) {
        return Text('获取收藏状态中');
      }
      if (collectionStatus['status']['type'] == 'wish') {
        return Text('想看');
      }

      if (haveCollected) {
        int _rating = collectionStatus['rating'];
        List<Widget> _rowChildren = []
          ..add(Text('${typeCN[collectionStatus['status']['type']]}  |  '));

        for (var _i = 1; _i <= _rating / 2; _i++) {
          _rowChildren.add(Icon(Icons.star, size: 15));
        }
        if (_rating % 2 == 1) {
          _rowChildren.add(Icon(Icons.star_half, size: 15));
        }
        for (var _i = (_rating / 2).ceil(); _i < 5; _i++) {
          _rowChildren.add(Icon(Icons.star_border, size: 15));
        }
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _rowChildren);
      } else {
        return Text('未收藏');
      }
    } else {
      return Text('登录以管理收藏');
    }
  }

  String _collectionString() {
    if (collection.isEmpty) {
      return '还没有人进行过收藏哦';
    }

    int _count = 1, _max = collection.length;
    String _result = '';
    collection.forEach((k, v) {
      _result += '$v人${GlobalVar.collectionStatusType2CN[k]}';
      _result += _count != _max ? ' / ' : '';
      _count++;
    });
    return _result;
  }

  void _openAuthWebview() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Browser(
        url:
            "https://bgm.tv/oauth/authorize?client_id=${GlobalVar.appId}&response_type=code",
        title: "登录&授权",
      );
    })).then((_) {
      if (myDio.isLogIn) {
        setState(() {});
      }
    });
  }

  void _openManager() {
    showDialog(
        context: context,
        builder: (context) {
          return MyDialog(widget.basicInfo, collectionStatus);
        }).then((v) {
      if (v != null) {
        setState(() {
          collectionStatus = v;
        });
        print(collectionStatus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '收藏',
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
            Center(
              child: Container(
                width: 300,
                padding: EdgeInsets.only(top: 12, bottom: 7),
                child: RaisedButton(
                  child: _buttonChild,
                  onPressed: _loading
                      ? null
                      : (myDio.isLogIn ? _openManager : _openAuthWebview),
                  color: Colors.blue[400],
                  textColor: Colors.white,
                  disabledColor: Colors.blue[200],
                  disabledTextColor: Colors.white,
                ),
              ),
            ),
            Text(
              _collectionString(),
              style: TextStyle(color: Colors.black54, fontSize: 12.5),
            ),
          ]),
    );
  }
}

class MyDialog extends StatefulWidget {
  MyDialog(this.basicInfo, this.collectionStatus, {Key key}) : super(key: key);

  final Map<String, dynamic> basicInfo, collectionStatus;
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  Map<String, dynamic> collectionStatus;
  TextEditingController tagController,
      commetController = TextEditingController();
  String get tagString => tagController.text; // 有很多空格也可以正常提交
  List<String> get tags => tagString.split(' '); //用来检查输入框中是否有相应的tag
  bool updating = false;

  var typeCN = {
    '想看': 'wish',
    '看过': 'collect',
    '在看': 'do',
    '搁置': 'on_hold',
    '抛弃': 'dropped'
  };

  @override
  void initState() {
    super.initState();
    collectionStatus = widget.collectionStatus;
    tagController = TextEditingController()
      ..text = initTagString()
      ..addListener(() {
        setState(() {});
      });
    commetController.text = widget.collectionStatus['comment'];
  }

  String initTagString() {
    String _result = '';
    for (var tag in widget.collectionStatus['tag']) {
      _result += '$tag ';
    }
    return _result;
  }

  void changeRating(int i) {
    setState(() {
      collectionStatus['rating'] = i;
    });
  }

  void tapTag(String name, bool chosen) {
    setState(() {
      if (chosen) {
        tagController.text =
            tagController.text.replaceAll(RegExp(r'\s*' + name), '');
      } else {
        if (tagString != '') {
          tagController.text += ' ';
        }
        tagController.text += '$name';
      }
    });
  }

  void tapStatus(String type) {
    setState(() {
      collectionStatus['status']['type'] = typeCN[type];
    });
  }

  Future<Map<String, dynamic>> update() async {
    try {
      Map<String, dynamic> data = {
        'status': collectionStatus['status']['type'],
        'comment': commetController.text,
        'tags': tagString,
        'rating': collectionStatus['rating'],
        'privacy': collectionStatus['private'],
      };
      setState(() {
        updating = true;
      });

      response = await dio
          .post(
              '${GlobalVar.apiUrl}/collection/${widget.basicInfo['id']}/update',
              data: data,
              options: Options(contentType: Headers.formUrlEncodedContentType))
          .then((v) {
        setState(() {
          updating = false;
        });
        return v;
      });
      if (response.data['error'] == null) {
        return response.data;
      } else {
        BotToast.showText(text: '登录信息可能过期了，请重新登录后再试');
        return null;
      }
    } catch (e) {}
    return null;
  }

  List<Widget> statusList() {
    List<Widget> _temp = [];
    typeCN.forEach((key, value) {
      _temp.add(
          Status(key, tapStatus, collectionStatus['status']['type'] == value));
    });
    return _temp;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Color.fromRGBO(243, 243, 243, 1),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // 标题
                    Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text(
                          widget.basicInfo['name_cn'] != ''
                              ? widget.basicInfo['name_cn']
                              : widget.basicInfo['name'],
                          softWrap: false,
                          style: TextStyle(fontSize: 17.5),
                        )),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(widget.basicInfo['name'],
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          )),
                    ),
                    // 评分
                    collectionStatus['rating'] != 0
                        ? RichText(
                            maxLines: 1,
                            text: TextSpan(
                                style: TextStyle(fontSize: 15.2),
                                children: [
                                  TextSpan(
                                      text: GlobalVar().getRating(
                                          collectionStatus['rating']),
                                      style:
                                          TextStyle(color: Colors.amber[400])),
                                  TextSpan(
                                      text: ' / ',
                                      style: TextStyle(color: Colors.black45)),
                                  TextSpan(
                                      text: '清除',
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => changeRating(0),
                                      style: TextStyle(color: Colors.black45))
                                ]),
                          )
                        : Text(
                            '',
                          ),
                    RatingStar(collectionStatus['rating'], changeRating),
                    // TAG
                    Container(
                      height: 40,
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 8, bottom: 10),
                      child: TextField(
                          controller: tagController,
                          maxLines: 1,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                              border: InputBorder.none,
                              hintText: '标签（用空格分隔）')),
                    ),
                    Container(
                      height: 30,
                      margin: EdgeInsets.only(bottom: 20),
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.basicInfo['tags'].length,
                          itemBuilder: (context, index) {
                            var tag = widget.basicInfo['tags'][index];
                            if (index != widget.basicInfo['tags'].length - 1) {
                              return Padding(
                                padding: EdgeInsets.only(right: 7),
                                child: Tag(
                                    tag, tags.contains(tag['name']), tapTag),
                              );
                            } else {
                              return Tag(
                                  tag, tags.contains(tag['name']), tapTag);
                            }
                          }),
                    ),
                    // 点评
                    Container(
                      height: 115,
                      margin: EdgeInsets.only(bottom: 15),
                      color: Colors.white,
                      child: TextField(
                          controller: commetController,
                          maxLines: 99,
                          style: TextStyle(height: 1.5),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(8),
                              border: InputBorder.none,
                              hintText: '评论一下这部作品吧')),
                    ),
                    // 收藏状态
                    Container(
                      margin: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(220, 220, 220, 0.5))),
                      child: Row(children: statusList()),
                    ),
                    // 提交按钮和公开状态
                    Container(
                      child: Row(children: [
                        Container(
                          height: 45,
                          width: 200,
                          margin: EdgeInsets.only(right: 15),
                          child: RaisedButton(
                            child: updating
                                ? SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      strokeWidth: 3,
                                    ))
                                : Text(
                                    '更新收藏状态',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                            color: Colors.blue,
                            disabledColor: Colors.blue[300],
                            onPressed: !updating
                                ? () async {
                                    var result = await update();
                                    if (result != null) {
                                      Navigator.pop(context, result);
                                    }
                                  }
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 45,
                            child: OutlineButton(
                              child: Text(
                                collectionStatus['private'] == 0 ? '公开' : '私密',
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.65),
                                    fontSize: 15),
                              ),
                              borderSide: BorderSide(color: Colors.blue[400]),
                              onPressed: () {
                                setState(() {
                                  collectionStatus['private'] =
                                      collectionStatus['private'] == 0 ? 1 : 0;
                                });
                              },
                            ),
                          ),
                        ),
                      ]),
                    )
                  ]),
            ),
            onTap: () {
              // 触摸收起键盘
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ));
  }
}

class RatingStar extends StatefulWidget {
  final int rating;
  final changeRating;

  RatingStar(this.rating, this.changeRating, {Key key}) : super(key: key);
  @override
  _RatingStarState createState() => _RatingStarState();
}

class _RatingStarState extends State<RatingStar> {
  var rating; //max:10
  ///0:未选中 1:半星 2:一颗星
  List<int> status = List(5);

  @override
  void initState() {
    super.initState();
    rating = widget.rating;
  }

  void setRating(int v) {
    rating = v;
    widget.changeRating(v);
  }

  List<Widget> starList() {
    List<Widget> _temp = [];
    var r = widget.rating;
    for (var _i = 0; _i <= (r / 2) - 1; _i++) {
      _temp.add(star(2, _i));
    }
    if (r % 2 == 1) {
      _temp.add(star(1, (r / 2).floor()));
    }
    for (var _i = (r / 2).ceil(); _i < 5; _i++) {
      _temp.add(star(0, _i));
    }
    return _temp;
  }

  Widget star(int state, int order) {
    Icon icon = Icon(Icons.star_border);
    Color _color = Colors.grey[400];
    //TODO: 优化
    switch (state) {
      case 1:
        icon = Icon(Icons.star_half);
        _color = Colors.amber[400];
        break;
      case 2:
        icon = Icon(Icons.star);
        _color = Colors.amber;
        break;
      default:
    }
    void _onPressed() {
      switch (state) {
        case 1:
          setRating((order + 1) * 2);
          break;
        case 2:
          if (rating != (order + 1) * 2) {
            setRating((order + 1) * 2);
          } else {
            setRating(order * 2 + 1);
          }
          break;
        default:
          setRating((order + 1) * 2);
      }
    }

    return IconButton(
      icon: icon,
      iconSize: 30,
      color: _color,
      onPressed: _onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: starList(),
    );
  }
}

class Tag extends StatelessWidget {
  /// para: String name; int count.
  final Map<String, dynamic> tag;
  final bool chosen;
  final changeState;

  Tag(this.tag, this.chosen, this.changeState, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 1.2,
                  color: chosen
                      ? Color.fromRGBO(195, 228, 245, 1)
                      : Color.fromRGBO(225, 225, 225, 1)),
              color: chosen ? Color.fromRGBO(249, 253, 255, 1) : null,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Center(
                child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: '${tag['name']} ',
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: '${tag['count']}',
                    style: TextStyle(color: Colors.black38))
              ]),
            ))),
        onTap: () => changeState(tag['name'], chosen));
  }
}

class Status extends StatelessWidget {
  final String type;
  final bool chosen, last;
  final changeStatus;

  const Status(this.type, this.changeStatus, this.chosen,
      {Key key, this.last = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: chosen ? Colors.blue[400] : null,
                border: Border(
                    right: !last
                        ? BorderSide(color: Color.fromRGBO(220, 220, 220, 0.7))
                        : BorderSide.none)),
            child: Text(
              type,
              style: TextStyle(color: chosen ? Colors.white : Colors.black),
            )),
        onTap: () => changeStatus(type),
      ),
    );
  }
}
