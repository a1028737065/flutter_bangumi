import 'package:bgm/global/dio3.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'component/calendar_item.dart';
import 'global/string.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController tabController;
  List<List> data = [];
  List<Widget> _tabViewList = [];
  double width, height;

  Future<void> _getData() async {
    response = await dio.get('${GlobalVar.apiUrl}/calendar',
        options: buildCacheOptions(Duration(days: 7)));
    List<dynamic> res = response.data;
    for (int _i = 0; _i < 7; _i++) {
      data.add(res[_i]['items']);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
    });
    for (int _i = 0; _i < 7; _i++) {
      _tabViewList.add(Center(
        child: CircularProgressIndicator(),
      ));
    }

    dio.interceptors.add(
        DioCacheManager(CacheConfig(baseUrl: '${GlobalVar.apiUrl}/calendar'))
            .interceptor);
    _getData().then((v) {
      setState(() {
        _tabViewList = _getTabViewList();
      });
    });
    tabController = TabController(initialIndex: 0, length: 7, vsync: this);
  }

  Widget _getOneDayList(int weekday) {
    var _data = data[weekday - 1];
    return new StaggeredGridView.countBuilder(
      crossAxisCount: 24,
      itemCount: _data.length,
      itemBuilder: (BuildContext context, int index) =>
          CalendarItem(_data[index]),
      //staggeredTileBuilder设置各个子项的大小，根据crossAxisCount和StaggeredTile.count规定的数值而定
      staggeredTileBuilder: (int index) => width - height <= 0
          ? StaggeredTile.count(12, 15)
          : StaggeredTile.count(6, 8),
      mainAxisSpacing: 6.0,
      crossAxisSpacing: width - height <= 0 ? 4.0 : 0,
    );
  }

  List<Widget> _getTabViewList() {
    List<Widget> _temp = [];
    for (int _i = 1; _i <= 7; _i++) {
      _temp.add(_getOneDayList(_i));
    }
    return _temp;
  }

  List<Widget> _tabList() {
    List<String> _weekday = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    List<Widget> _temp = [];
    for (int _i = 0; _i < 7; _i++) {
      _temp.add(Tab(text: _weekday[_i]));
    }
    return _temp;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Column(
      children: <Widget>[
        TabBar(
          labelColor: Colors.blue,
          isScrollable: true,
          controller: tabController,
          tabs: _tabList(),
        ),
        Container(
          height: height - 202,
          width: width,
          child: TabBarView(controller: tabController, children: _tabViewList),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
