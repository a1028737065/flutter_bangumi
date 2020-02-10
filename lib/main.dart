import 'package:bgm/component/favor_item.dart';
import 'package:bgm/global/string.dart';
import 'package:bgm/search.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'favor.dart';
import 'calendar.dart';
import 'package:bgm/global/dio3.dart';
import 'package:bot_toast/bot_toast.dart';

void main() {
  runApp(MyApp());
  myDio.init();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
        child: MaterialApp(
      color: Colors.blue,
      home: MainPage(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [BotToastNavigatorObserver()],
    ));
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  List<Tab> tabs;
  TabController controller;

  @override
  void initState() {
    super.initState();
    tabs = [
      Tab(
        text: '收藏',
        icon: Icon(Icons.favorite),
      ),
      Tab(
        text: '每日放送',
        icon: Icon(Icons.today),
      ),
    ];
    controller =
        TabController(initialIndex: 0, length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey anchorKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: Text('bangumi'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                return new SearchPage();
              }));
            },
            tooltip: '搜索',
          ),
          IconButton(
            key: anchorKey,
            icon: Icon(Icons.person),
            tooltip: '登录状态管理',
            onPressed: () {
              RenderBox renderBox = anchorKey.currentContext.findRenderObject();
              var offset =
                  renderBox.localToGlobal(Offset(0.0, renderBox.size.height));

              showMenu(
                      context: context,
                      position:
                          RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
                      items: MyDio().isLogIn
                          ? [
                              PopupMenuItem(
                                child: Text('注销'),
                                value: 'logOut',
                              )
                            ]
                          : [
                              PopupMenuItem(
                                child: Text('登录&授权'),
                                value: 'logIn',
                              ),
                              PopupMenuItem(
                                child: Text('注册'),
                                value: 'signUp',
                              )
                            ])
                  .then((v) {
                if ('logOut' == v) {
                  myDio.logOut();
                  setState(() {});
                } else if ('logIn' == v) {
                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (_) {
                    return new Browser(
                      url:
                          "https://bgm.tv/oauth/authorize?client_id=${GlobalVar.appId}&response_type=code",
                      title: "登录&授权",
                    );
                  })).then((_) {
                    Future.delayed(Duration(seconds: 5),
                        () => print('${myDio.isLogIn}  token$token'));
                  });
                } else if ('signUp' == v) {
                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (_) {
                    return new Browser(
                      url: "https://bgm.tv/signup",
                      title: "注册",
                      signUp: true,
                    );
                  }));
                }
              });
            },
          )
        ],
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [FavoritePage(), CalendarPage()],
      ),
      bottomNavigationBar: TabBar(
        unselectedLabelColor: Colors.grey,
        labelColor: Colors.blue,
        controller: controller,
        tabs: tabs,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

class Browser extends StatelessWidget {
  const Browser({Key key, this.url, this.title, this.signUp = false})
      : super(key: key);

  final String url;
  final String title;
  final bool signUp;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (_) {
          if (signUp) {
            BotToast.showText(
                text: "如果你已成功注册或已登录，\n请手动返回并点击'登录&授权'",
                crossPage: false,
                duration: Duration(seconds: 5),
                clickClose: true,
                textStyle: TextStyle(
                    fontSize: 15, color: Colors.white, letterSpacing: 1.2));
          }
        },
        navigationDelegate: (NavigationRequest request) async {
          if (request.url.startsWith(GlobalVar.redirectUrl)) {
            var _ok = await myDio.secondAuth(
                request.url.substring(GlobalVar.redirectUrl.length + 7));
            // 返回会使FavourManage重新initState，故无需setState
            Navigator.pop(context, _ok);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
