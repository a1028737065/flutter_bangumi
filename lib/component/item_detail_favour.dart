import 'package:flutter/material.dart';
import '../global/dio3.dart';
import '../main.dart';
import '../global/data.dart';

class FavourWidget extends StatefulWidget {
  FavourWidget(this.id, this.collection, {Key key}) : super(key: key);

  final int id;
  final Map<String, int> collection;
  @override
  _FavourWidgetState createState() => _FavourWidgetState();
}

class _FavourWidgetState extends State<FavourWidget> {
  Map<String, int> collection; //大家的收藏状态
  Map<String, dynamic> collectionStatus = {}; //自己的收藏状态
  bool _loading = true;
  int rating = 0;
  Map<String, String> type = {
    'wish': '想看',
    'collect': '看过',
    'doing': '在看',
    'on_hold': '搁置',
    'dropped': '抛弃'
  };

  Future<void> getCollectionStatus() async {
    // try {
    //   response = await dio.get('/collection/${widget.id}');
    //   //未收藏时仍会正常响应
    //   if (response.data['error'] == null) {
    //   rating = response.data['rating'];
    //     setState(() {
    //       collectionStatus = response.data;
    //       _loading = true;
    //     });
    //   }
    // } catch (e) {}
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        collectionStatus = Data().collectionStatus;
        _loading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    collection = null != widget.collection ? widget.collection : {};
    if (myDio.isLogIn) {
      getCollectionStatus();
    }
  }

  Widget _buttonChild() {
    if (_loading) {
      return Text('获取收藏状态中');
    }

    if (myDio.isLogIn) {
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
    }));
  }

  void _openManager() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: Container(
            width: 400,
            height: 550,
            child: Column(children: <Widget>[
              //评分
              Container(
                width: 250,
                decoration: BoxDecoration(border: Border.all()),
                child: RatingStar(rating, changeRating),
              ),
            ]),
          ));
        });
  }

  void changeRating(int i) {
    rating = i;
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

class RatingStar extends StatefulWidget {
  final int rating;
  final void changeRating;

  RatingStar(this.rating, this.changeRating, {Key key}) : super(key: key);
  @override
  _RatingStarState createState() => _RatingStarState();
}

class _RatingStarState extends State<RatingStar> {
  var rating; //max:10
  List<int> status = List(5); //0:未选中 1:半星 2:一颗星

  @override
  void initState() {
    super.initState();
    setRating(widget.rating);
  }

  void setRating(int v) {
    rating = v;
    for (var _i = 0; _i < v / 2; _i++) {
      status[_i] = 2;
    }
    if (v % 2 == 1) {
      status[(v / 2).floor()] = 1;
    }
    for (var _i = (v / 2).ceil(); _i < 5; _i++) {
      status[_i] = 0;
    }
    setState(() {});
  }

  List<Widget> starList() {
    List<Widget> _temp = [];
    for (var _i = 0; _i < status.length; _i++) {
      _temp.add(star(status[_i], _i));
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
