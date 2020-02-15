import 'package:bgm/component/item_detail.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class SearchItem extends StatelessWidget {
  SearchItem(this.data, this.width);
  final Map<String, dynamic> data;
  final double width;

  String _type() {
    return ['三次元', '动画', '音乐', '游戏', '', '三次元'][data['type'] - 1];
  }

  String _description() {
    var _temp = '';
    if (data['air_date'] != '0000-00-00') {
      _temp +=
          '${data['air_date'].toString().substring(0, 4)}年${data['air_date'].toString().substring(5, 7)}月${data['air_date'].toString().substring(8)}日';
    }
    if (2 == data['type']) {
      _temp +=
          ' / 周' + ['一', '二', '三', '四', '五', '六', '日'][data['air_weekday'] - 1];
      _temp += ' / ${data['eps_count']}话';
    } else if (1 == data['type']) {
      if (null != data['vols_count']) {
        _temp += data['air_date'] != '0000-00-00'
            ? ' / ${data['vols_count']}卷'
            : '${data['vols_count']}卷';
      }
      if (null != data['eps_count']) {
        _temp += ' / ${data['vols_count']}话';
      }
    }
    return _temp;
  }

  String _ratingTotal() {
    return (data['rating']['total'] >= 10
            ? '(${data['rating']['total']}'
            : '(少于10') +
        '人评分)';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: width,
      child: FlatButton(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ItemDetail(data['id'], data1: data, calendar: true);
            }));
          },
          child: Row(children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              width: 92,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: ExtendedImage.network('${data['images']['large']}',
                    loadStateChanged: (ExtendedImageState state) {
                  if (state.extendedImageLoadState == LoadState.loading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return null;
                }),
              ),
            ),
            Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 4),
                  width: width - 130,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            width: width - 195,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${'' != data['name_cn'] ? data['name_cn'] : data['name']}',
                                    style: TextStyle(fontSize: 16),
                                    maxLines: 2,
                                  ),
                                  '' != data['name_cn']
                                      ? Container(
                                          width: width - 135,
                                          child: Text(
                                            '${data['name']}',
                                            style:
                                                TextStyle(color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      : Container(),
                                ])),
                        Container(
                            width: 50,
                            margin: EdgeInsets.only(top: 4, left: 10),
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.lightBlueAccent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                            child: Text(
                              _type(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.blueAccent),
                            ))
                      ]),
                ),
                Expanded(
                  child: Center(
                    child: Text(_description()),
                  ),
                ),
                Row(
                  children: <Widget>[
                    data['rating']['total'] >= 10
                        ? Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.orange,
                          )
                        : Text(''),
                    data['rating']['total'] >= 10
                        ? Text(
                            '${data['rating']['score']}' + '  ',
                            style: TextStyle(color: Colors.orange),
                          )
                        : Text(''),
                    Text(
                      _ratingTotal() + '   ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    null != data['rank'] && '' != data['rank']
                        ? Text(
                            '#${data['rank']}',
                            style: TextStyle(color: Colors.blueAccent),
                          )
                        : Text(''),
                  ],
                )
              ],
            )
          ])),
    );
  }
}
