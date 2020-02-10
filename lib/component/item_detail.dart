import 'package:bgm/global/string.dart';
import 'package:bgm/global/dio3.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:webview_flutter/webview_flutter.dart';

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
  ScrollController controller;
  bool hide = false, loading = true;
  Map<String, dynamic> data1 = {}, data2 = {}, data3 = {}, eps = {};
  double height = 1980, width = 1080;

  Future<void> getItemData() async {
    if (widget.data1 == null || widget.calendar) {
      try {
        response = await dio.get(
          '${GlobalVar.apiUrl}/subject/${data1['id']}',
          queryParameters: {'responseGroup': 'large'},
        );
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
      } catch (e) {}
    } else {
      data2 = widget.data2;
    }

    if (widget.data3 == null) {
      try {
        response = await dio.get('${GlobalVar.apiUrl}/collection/${widget.id}');
        data3 = response.data;
      } catch (e) {}
    } else {
      data3 = widget.data3;
    }

    _checkNullData();
    setState(() {});
  }

  void _checkNullData() {
    data1.forEach((key, value) {
      if (value == null && (key == 'crt' || key == 'staff' || key == 'eps')) {
        data1[key] = [];
      }
    });
    ['crt', 'staff', 'eps'].forEach((key) => data1.putIfAbsent(key, () => []));
  }

  String weekday(int i) {
    return ['一', '二', '三', '四', '五', '六', '日'][i - 1];
  }

  Widget introText(String text) {
    return Text(text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], height: 2, fontSize: 15));
  }

  List<Widget> collectionChips() {
    Map<String, String> stateTrans = {
      'wish': '想看',
      'collect': '看过',
      'doing': '在看',
      'on_hold': '搁置',
      'dropped': '抛弃'
    };
    List<Padding> _temp = [];
    stateTrans.forEach(
      (key, value) => _temp.add(
        Padding(
            padding: EdgeInsets.only(left: 10),
            child: Chip(label: Text('$value ${data1['collection'][key]}'))),
      ),
    );
    return _temp;
  }

  List<Widget> crtList() {
    WebViewController _controller;
    String _title = "详情";

    List<Widget> _temp = [];
    List _crtList = data1['crt'] == null ? [] : data1['crt'];

    if (_crtList.isEmpty) {
      return [Text('暂无角色信息', style: TextStyle(fontSize: 15))];
    }
    _crtList.forEach((item) => _temp.add(FlatButton(
          child: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                child: ExtendedImage.network(
                  item['images']['medium'],
                  cache: true,
                  loadStateChanged: (ExtendedImageState state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        return Center(
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
                flex: 1,
              ),
              Text(
                '${item['name_cn'] == '' ? item['name'] : item['name_cn']}',
                style: TextStyle(
                    color: Color.fromRGBO(0, 132, 180, 1), fontSize: 14.8),
              ),
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(
                      text: '${item['role_name']} ',
                      style: TextStyle(color: Colors.grey)),
                  TextSpan(
                      text: item['name'],
                      style: TextStyle(color: Color.fromRGBO(102, 102, 102, 1)))
                ],
              )),
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(text: 'CV: ', style: TextStyle(color: Colors.grey)),
                  TextSpan(
                      text: item['actors'][0]['name'],
                      style: TextStyle(color: Color.fromRGBO(102, 102, 102, 1)))
                ],
              )),
            ],
          ),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => new Scaffold(
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
        )));
    return _temp;
  }

  @override
  void initState() {
    super.initState();
    data1 = widget.data1;
    _checkNullData();
    getItemData().then((v) {
      loading = false;
      if (!widget.calendar) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: loading
            ? Text('加载中')
            : Text(
                '${data1['name_cn'] == '' ? data1['name'] : data1['name_cn']}'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(70, 130, 180, 0.4)),
            height: 175,
            padding: EdgeInsets.only(top: 12, bottom: 12, left: 8, right: 15),
            child: Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset.fromDirection(0.9, 3))
                  ]),
                  margin: EdgeInsets.only(right: 16),
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                        image: ExtendedNetworkImageProvider(
                      "${data1['images']['large']}",
                    )),
                  ),
                ),
                Container(
                  width: width - 216,
                  // TODO: 只用一个Text()输出，当数据不存在时就不用显示空行
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      introText('${data1['name']}'),
                      introText(
                          '${data1['air_date'].toString().substring(0, 4)}年${data1['air_date'].toString().substring(5, 7)}月${data1['air_date'].toString().substring(8)}日'),
                      data1['air_weekday'] != null
                          ? introText('每周${weekday(data1['air_weekday'])}放送')
                          : Text(''),
                      data1['eps_count'] != null || data1['eps'] != null
                          ? introText(
                              '共${data1['eps_count'] != null ? data1['eps_count'] : data1['eps'].length}话')
                          : Text(''),
                    ],
                  ),
                ),
                !loading
                    ? GestureDetector(
                        child: Container(
                          width: 60,
                          child: Column(
                            children: <Widget>[
                              data1['rating'] != null
                                  ? Text(
                                      '\n${data1['rating']['score'].toStringAsFixed(1)}',
                                      style: TextStyle(
                                          fontSize: 36,
                                          color: Colors.orange[600],
                                          height: 1))
                                  : Text('\n暂无\n评分',
                                      style: TextStyle(
                                          color: Colors.orange[600],
                                          fontSize: 22,
                                          height: 1.5)),
                              Text(
                                  data1['rating'] != null
                                      ? 'x${data1['rating']['total']}人'
                                      : '',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      height: 1.55))
                            ],
                          ),
                        ),
                        onTap: data1['rating'] != null
                            ? () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          title: Text('评分'),
                                          content: Container(
                                            height: height - 400,
                                            child: SimpleBarChart(
                                                data1['rating']['count']),
                                          ));
                                    });
                              }
                            : null,
                      )
                    : Text('')
              ],
            ),
          ),
          loading
              ? Container(
                  height: height - 300,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 8),
                      child: data1['summary'] != ''
                          ? SummaryText(
                              '${data1['summary']}',
                            )
                          : Text('暂无介绍', style: TextStyle(color: Colors.grey)),
                    ),
                    Divider(),
                    Container(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: collectionChips(),
                      ),
                    ),
                    Divider(),
                    Container(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: crtList(),
                      ),
                    ),
                    Divider(),
                  ],
                ),
        ],
      ),
    );
  }
}

class Rating {
  final score;
  final int count;

  Rating(this.score, this.count);
}

class SimpleBarChart extends StatelessWidget {
  final Map count;

  SimpleBarChart(this.count);

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      _createSampleData(count),
      animate: true,
    );
  }

  static List<charts.Series<Rating, String>> _createSampleData(Map count) {
    List<Rating> data = [];
    count.forEach((key, value) => data.insert(0, Rating(key, value)));

    return [
      new charts.Series<Rating, String>(
        id: 'Rating',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Rating rating, _) => rating.score,
        measureFn: (Rating rating, _) => rating.count,
        data: data,
      )
    ];
  }
}

class SummaryText extends StatefulWidget {
  SummaryText(this.text, {Key key}) : super(key: key);
  final String text;

  @override
  _SummaryTextState createState() => _SummaryTextState();
}

class _SummaryTextState extends State<SummaryText> {
  bool _isExpansion = false;
  int _maxLine = 4;
  TapGestureRecognizer recognizer;

  Widget _richText(String text) {
    //TODO: 直接利用ExtendText实现
    return _isExpansion
        ? RichText(
            text: TextSpan(children: [
              TextSpan(text: text, style: TextStyle(color: Colors.black)),
              TextSpan(
                  text: '收起',
                  style: TextStyle(color: Colors.blue),
                  recognizer: recognizer)
            ]),
          )
        : ExtendedText(
            text,
            maxLines: _maxLine,
            overFlowTextSpan: OverFlowTextSpan(children: <TextSpan>[
              TextSpan(text: ' \u2026 '),
              TextSpan(
                  text: "展开",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                  recognizer: recognizer)
            ]),
          );
  }

  @override
  void initState() {
    super.initState();
    recognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _isExpansion = !_isExpansion;
        });
      };
  }

  @override
  Widget build(BuildContext context) {
    return _richText(widget.text);
  }
}
