import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../global/dio3.dart';
import '../main.dart';

class FavourWidget extends StatefulWidget {
  FavourWidget(this.basicInfo, this.collectionStatus, this.loading, {Key key})
      : super(key: key);

  final Map<String, dynamic> basicInfo,
      collectionStatus; //自己的收藏状态, {}表示未收藏, null表示请求失败
  final bool loading;
  @override
  _FavourWidgetState createState() => _FavourWidgetState();
}

class _FavourWidgetState extends State<FavourWidget> {
  Map<String, int> collection;
  Map<String, dynamic> collectionStatus;
  bool _loading = true;
  Map<String, String> type = {
    'wish': '想看',
    'collect': '看过',
    'doing': '在看',
    'on_hold': '搁置',
    'dropped': '抛弃'
  };

  @override
  void initState() {
    super.initState();
    collection = null != widget.basicInfo['collection']
        ? widget.basicInfo['collection']
        : {};
    collectionStatus = widget.collectionStatus;
    _loading = widget.loading;
  }

  Widget _buttonChild() {
    if (myDio.isLogIn) {
      if (_loading) {
        return Text('获取收藏状态中');
      }

      if (collectionStatus.isNotEmpty) {
        int _rating = collectionStatus['rating'];
        List<Widget> _rowChildren = []
          ..add(Text('${collectionStatus['status']['name']}  |  '));
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
      _result += '$v人${type[k]}';
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
          return MyDialog(widget.basicInfo, widget.collectionStatus);
        });
    // TODO: 成功更新收藏的话则更新详细页的按钮
    // .then((v) {
    //   setState(() {});
    // })
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
                  child: _buttonChild(),
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

  final Map<String, dynamic> basicInfo,
      collectionStatus; //自己的收藏状态, {}表示未收藏, null表示请求失败
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  int rating = 0;

  @override
  void initState() {
    super.initState();
    rating = widget.collectionStatus['rating'];
  }

  void changeRating(int i) {
    setState(() {
      rating = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      width: 400,
      height: 550,
      child: Column(children: <Widget>[
        //标题
        Text(widget.basicInfo['name_cn'] != ''
            ? widget.basicInfo['name_cn']
            : widget.basicInfo['name']),
        Text(widget.basicInfo['name']),
        //评分
        rating != 0
            ? RichText(
                maxLines: 1,
                text: TextSpan(children: [
                  TextSpan(
                      text: GlobalVar().getRating(rating),
                      style: TextStyle(color: Colors.amber[400])),
                  TextSpan(
                      text: '清除',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => changeRating(0),
                      style: TextStyle(color: Colors.black45))
                ]),
              )
            : Text(''),
        Container(
          width: 250,
          child: RatingStar(rating, changeRating),
        ),
      ]),
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
      color: _color,
      onPressed: _onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: starList(),
    ));
  }
}
