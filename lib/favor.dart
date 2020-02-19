import 'package:bgm/component/favor_item.dart';
import 'package:bgm/global/dio3.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool _isCheckingLogIn = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 400),
        () => setState(() => _isCheckingLogIn = false));
  }

  @override
  Widget build(BuildContext context) {
    return _isCheckingLogIn
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            //TODO: 登出按钮
            child: myDio.isLogIn ? FavourManage() : Text('您还没有登录哦'));
  }
}

class FavourManage extends StatefulWidget {
  @override
  _FavourManageState createState() => _FavourManageState();
}

class _FavourManageState extends State<FavourManage>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  List<Widget> tabs = [], tabBarViews = [];
  List<PopupMenuItem> popupMenuItems = [];
  Map<String, String> typeToCN = {
    'anime': '动画',
    'book': '书籍',
    'music': '音乐',
    'game': '游戏',
    'real': '三次元',
  };
  double height = 1920, width = 1080;
  String type = 'anime';
  bool _isLoading = true;

  Future<void> getTabBarView() async {
    setState(() {
      _isLoading = true;
    });
    List<Widget> _result = List(5);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.get('user_id');
    try {
      response = await dio.get("/user/$userId/collections/$type",
          queryParameters: {'app_id': GlobalVar.appId});
      for (var list in response.data[0]['collects']) {
        _result[list['status']['id'] - 1] = ListView.separated(
          itemCount: list['count'],
          itemBuilder: (context, index) =>
              FavorItem(list['list'][index]['subject_id']),
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey[400],
          ),
        );
      }
    } catch (e) {}
    for (int i = 0; i < _result.length; i++) {
      _result[i] =
          _result[i] == null ? Center(child: Text('该列表没有数据哦')) : _result[i];
    }
    setState(() {
      // 由于会在initState里调用此方法，重复setState会导致性能下降以及dispose后仍会setState问题
      tabBarViews = _result;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    tabs = ['想看', '看过', '在看', '搁置', '抛弃']
        .map((v) => Tab(
              text: v,
            ))
        .toList();
    typeToCN.forEach((key, value) => popupMenuItems.add(PopupMenuItem(
          child: Text(value),
          value: key,
        )));

    getTabBarView();
    tabController =
        TabController(initialIndex: 0, length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              height: 25,
              width: 80,
              margin: EdgeInsets.only(left: 5),
              padding: EdgeInsets.only(left: 2, right: 2),
              child: FlatButton(
                child: Text(typeToCN[type]),
                color: Colors.blue[400],
                disabledColor: Colors.blue[200],
                textColor: Colors.white,
                onPressed: !_isLoading
                    ? () {
                        showMenu(
                                context: context,
                                items: popupMenuItems,
                                position:
                                    RelativeRect.fromLTRB(0, 122, 100, 100))
                            .then((v) {
                          if (null != v && type != v) {
                            type = v;
                            getTabBarView();
                          }
                        });
                      }
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              ),
            ),
            Container(
              width: width - 85,
              child: TabBar(
                labelColor: Colors.blue,
                tabs: tabs,
                controller: tabController,
              ),
            ),
          ],
        ),
        !_isLoading
            ? Container(
                height: height - 202,
                width: width,
                child: TabBarView(
                  controller: tabController,
                  children: tabBarViews,
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }
}
