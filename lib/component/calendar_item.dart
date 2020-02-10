import 'package:bgm/component/item_detail.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class CalendarItem extends StatefulWidget {
  CalendarItem(this.data, {Key key}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  _CalendarItemState createState() => _CalendarItemState();
}

class _CalendarItemState extends State<CalendarItem> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            child: widget.data['images'] != null
                ? ExtendedImage.network(
                    "${widget.data['images']['large']}",
                    timeRetry: Duration(milliseconds: 200),
                    cache: true,
                    retries: 6,
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
                  )
                : Container(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    child: Center(child: Text('暂无\n图片')),
                  ),
            flex: 1,
          ),
          Column(
            children: <Widget>[
              Text(
                widget.data['name_cn'] == ''
                    ? widget.data['name']
                    : widget.data['name_cn'],
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.8), fontSize: 16),
              ),
              Text(
                widget.data['name_cn'] == '' ? '' : widget.data['name'],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          )
        ],
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ItemDetail(
                      widget.data['id'],
                      data1: widget.data,
                      calendar: true,
                    )));
      },
      padding: EdgeInsets.only(left: 0, right: 0, bottom: 8, top: 8),
    );
  }
}
