import 'package:charts_flutter/flutter.dart' as charts;
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../global/dio3.dart';

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
    // if (widget.data1 == null || widget.calendar) {
    //   try {
    //     response = await dio.get('/subject/${data1['id']}?responseGroup=large');
    //     data1 = response.data;
    //   } catch (e) {}
    // } else {
    //   data1 = widget.data1;
    // }

    // if (widget.data2 == null) {
    //   try {
    //     response = await dio.get(
    //         'https://cdn.jsdelivr.net/gh/czy0729/Bangumi-Subject@master/data/${(widget.id / 100).floor()}/${widget.id}.json');
    //     data2 = response.data;
    //   } catch (e) {}
    // } else {
    //   data2 = widget.data2;
    // }

    // if (widget.data3 == null) {
    //   try {
    //     response = await dio.get('/collection/${widget.id}');
    //     data3 = response.data;
    //   } catch (e) {}
    // } else {
    //   data3 = widget.data3;
    // }
    data1 = Data().data[0];
    data2 = Data().data[1];
    data3 = Data().data[2];

    _checkNullData();
    setState(() {});
  }

  void _checkNullData() {
    data1.forEach((key, value) {
      if (value == null && (key == 'crt' || key == 'staff' || key == 'eps')) {
        data1[key] = [];
      }
    });
    for (var key in ['crt', 'staff', 'eps']) {
      data1.putIfAbsent(key, () => []);
    }
  }

  List<Widget> crtList() {
    WebViewController _controller;
    String _title = "详情";

    List<Widget> _temp = [];
    List _crtList = data1['crt'] == null ? [] : data1['crt'];

    if (_crtList.isEmpty) {
      return [Text('暂无角色信息', style: TextStyle(fontSize: 15))];
    }

    for (var item in _crtList) {
      _temp.add(GestureDetector(
        child: Container(
            width: 250,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: ExtendedImage.network(
                    item['images']['grid'],
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
                ),
                Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 150,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(item['name'],
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 132, 180, 1),
                                  fontSize: 14.8)),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: '${item['role_name']} ',
                                    style: TextStyle(color: Colors.grey)),
                                TextSpan(
                                    text: item['name_cn'] == ''
                                        ? item['name']
                                        : item['name_cn'],
                                    style: TextStyle(
                                        color:
                                            Color.fromRGBO(102, 102, 102, 1)))
                              ],
                            ),
                          ),
                          RichText(
                              text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'CV: ',
                                  style: TextStyle(color: Colors.grey)),
                              TextSpan(
                                  text: item['actors'][0]['name'],
                                  style: TextStyle(
                                      color: Color.fromRGBO(102, 102, 102, 1)))
                            ],
                          ))
                        ])),
              ],
            )),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (contFext) => Scaffold(
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
      ));
    }

    return _temp;
  }

  @override
  void initState() {
    super.initState();
    data1 = Data().data[0];
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
    return Scaffold(
      appBar: AppBar(title: Text(data1['name'])),
      body: Column(children: [
        Container(
            constraints: BoxConstraints(minHeight: 60, maxHeight: 200),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: crtList(),
                )))
      ]),
    );
  }
}

class Data {
  final List<Map<String, dynamic>> data = [
    {
      "id": 279457,
      "url": "http://bgm.tv/subject/279457",
      "type": 2,
      "name": "ソードアート・オンライン アリシゼーション War of Underworld",
      "name_cn": "刀剑神域 Alicization篇 War of Underworld",
      "summary":
          "桐人、尤吉欧、爱丽丝。\r\n距离两名修剑士和一名整合骑士打败了最高祭司阿多米尼斯多雷特已过去了半年。\r\n结束了战斗，爱丽丝在故乡卢利特村生活。\r\n在她的身旁，是失去了挚友，自己也失去了手臂和心的桐人。\r\n献身般支撑着他的爱丽丝，丝毫没有保留像以前一样作为骑士的心。 \r\n“告诉我，桐人……我究竟该怎么办？”\r\n然而，通往将 Underworld 全境引向悲剧的“最终压力测试”的倒计时，却毫不留情地推进着。\r\n仿佛与之相呼应一般，在“黑暗领域”的深处，暗黑神贝库达复活了。他率领暗黑帝国的军队，为了得到“光之巫女”，开始向“人界”进攻。\r\n指挥“人界”军队的贝尔库利等人，决心与“黑暗领域”的军队展开前所未有的大战。\r\n但在他们身旁，并没有发现爱丽丝，以及拯救了“人界”的两位英雄的身影。 \r\n《刀剑神域》系列最长、拥有最华丽战斗的“Alicization”篇，其最终章终于揭幕！",
      "eps": [
        {
          "id": 906496,
          "url": "http://bgm.tv/ep/906496",
          "type": 1,
          "sort": 0,
          "name": "リフレクション",
          "name_cn": "Reflection（总集篇）",
          "duration": "00:23:40",
          "airdate": "2019-10-05",
          "comment": 5,
          "desc": "",
          "status": "Air"
        },
        {
          "id": 905519,
          "url": "http://bgm.tv/ep/905519",
          "type": 0,
          "sort": 1,
          "name": "北の地にて",
          "name_cn": "在北方的土地上",
          "duration": "00:23:40",
          "airdate": "2019-10-12",
          "comment": 63,
          "desc":
              "アドミニストレータとの激闘から半年が過ぎた。右腕を失い、廃人のようになってしまったキリトを連れたアリスは、故郷であるルーリッド村のはずれで静かに暮らしていた。彼と共に守った世界を眺め、これまでを思い返すアリス。そんな彼女の前に、整合騎士の同僚であり、弟子でもあるエルドリエ・シンセシス・サーティワンが姿を見せる。\r\n\r\n脚本：中本宗応\r\n絵コンテ：小野 学\r\n演出：佐久間貴史(st.シルバー)\r\n総作画監督：山本由美子\r\n作画監督：前田達之、大高美奈、秋月 彩",
          "status": "Air"
        },
        {
          "id": 905520,
          "url": "http://bgm.tv/ep/905520",
          "type": 0,
          "sort": 2,
          "name": "襲撃",
          "name_cn": "袭击",
          "duration": "00:23:40",
          "airdate": "2019-10-19",
          "comment": 54,
          "desc":
              "ダークテリトリーの軍勢がルーリッド村を襲撃した。飛竜《雨縁》に乗り、村に駆け付けるアリス。そこには、《禁忌目録》によって衛士長の命令に逆らえず、ゴブリンたちから逃げることができない村人たちがいた。戦う目的を見失っていたアリスは、自らの家族のため、キリトとユージオが守ろうとした人々のために、再び整合騎士の鎧を身にまとい、《金木犀の剣》を振るう！\r\n\r\n脚本：中本宗応\r\n絵コンテ：みうらたけひろ\r\n演出：みうらたけひろ\r\n総作画監督：鈴木 豪\r\n作画監督：世良コータ、チョン・ヨンフン、古住千秋、今岡 大、みうらたけひろ",
          "status": "Air"
        },
        {
          "id": 905521,
          "url": "http://bgm.tv/ep/905521",
          "type": 0,
          "sort": 3,
          "name": "最終負荷実験",
          "name_cn": "最终负荷实验",
          "duration": "00:23:40",
          "airdate": "2019-10-26",
          "comment": 66,
          "desc":
              "《オーシャン・タートル》を襲撃した謎の組織――それはアメリカ国家安全保障局の極秘任務を受けた特殊工作部隊だった。\r\n部隊を率いるリーダーのガブリエルは、過去にキリトやシノンと交戦したことがあり…。\r\n《ソウル・トランスレーション・テクノロジー》で造られた人工の魂《A.L.I.C.E》＝アリス強奪を狙うガブリエルは、《アンダーワールド》内にいるアリスを探し出すため、ある秘策を試みる。\r\n\r\n脚本：中本宗応\r\n絵コンテ：木村 寛、菅野芳弘\r\n演出：木村 寛\r\n総作画監督：戸谷賢都\r\n作画監督：水野辰哉、小松沙奈、鈴木理彩、戸谷賢都",
          "status": "Air"
        },
        {
          "id": 905522,
          "url": "http://bgm.tv/ep/905522",
          "type": 0,
          "sort": 4,
          "name": "ダークテリトリー",
          "name_cn": "暗黑帝国",
          "duration": "00:23:40",
          "airdate": "2019-11-02",
          "comment": 78,
          "desc":
              "ダークテリトリーの暗黒騎士団を率いる騎士団長シャスターは、アドミニストレータが死んだことを機に、人界へ和平を持ち掛けようとしていた。しかしその試みは皇帝ベクタの暗黒界帰還によって打ち砕かれる。ベクタのアカウントを使って《アンダーワールド》にログインしたガブリエル。彼は《A.L.I.C.E》を見つけ出すため、闇の軍勢たちに向かって人界との全面戦争を指示する。\r\n\r\n脚本：木澤行人\r\n絵コンテ：古田丈司、菅野芳弘\r\n演出：中山奈緒美、佐久間貴史(st.シルバー)\r\n総作画監督：山本由美子\r\n作画監督：大高美奈、丸山大勝、古住千秋、今岡 大、宮本武史、チョン・ヨンフン、世良コータ、鈴木理彩、水野辰哉、山本由美子",
          "status": "Air"
        },
        {
          "id": 905523,
          "url": "http://bgm.tv/ep/905523",
          "type": 0,
          "sort": 5,
          "name": "開戦前夜",
          "name_cn": "开战前夜",
          "duration": "00:23:40",
          "airdate": "2019-11-09",
          "comment": 53,
          "desc":
              "人界とダークテリトリーを隔てる《東の大門》。そのすぐそばまで、闇の軍勢が迫ってきた。\r\n人々のために戦うことを決意したアリスは、キリトを連れて人界軍に合流する。\r\nしかし圧倒的なダークテリトリー軍の兵力に比べ、人界軍で戦闘可能な整合騎士は、わずか十三人しかいなかった。\r\n絶対的劣勢の中、前線でも廃人同様のキリトを帯同するかどうか迷うアリスだったが……。\r\n\r\n脚本：木澤行人\r\n絵コンテ：佐久間貴史\r\n演出：尾ノ上知久\r\n総作画監督：鈴木 豪\r\n作画監督：Won Chang hee、Kwon Oh sik、Ahn Hyo jeong、Jeong Yeon soon、Jang Hee kyu、Joung Eun joung、Lim Keun soo、徳岡紘平、山本由美子、竹内由香里、吉岡 勝",
          "status": "Air"
        },
        {
          "id": 905524,
          "url": "http://bgm.tv/ep/905524",
          "type": 0,
          "sort": 6,
          "name": "騎士たちの戦い",
          "name_cn": "骑士们的战斗",
          "duration": "00:23:40",
          "airdate": "2019-11-16",
          "comment": 72,
          "desc":
              "《最終負荷実験》が始まり、《東の大門》がついに崩壊した。皇帝ベクタとなったガブリエルにたきつけられ、大規模な軍隊を形成した闇の軍勢は、人界へと進軍する。迎え撃つ少数精鋭の人界軍は、部隊を分けて迎え撃つ。絶望的な戦力差にもかかわらず、人界軍の整合騎士たちは一騎当千の凄まじい力で敵を打ち倒していく。だが闇の軍勢はその圧倒的な兵数で徐々に人界軍を蹴散らしていくのだった。\r\n\r\n脚本：木澤行人\r\n絵コンテ：大塚 健\r\n演出：鈴木拓磨\r\n総作画監督：戸谷賢都\r\n作画監督：大高美奈、前田達之、秋月 彩、山本亮友",
          "status": "Air"
        },
        {
          "id": 905525,
          "url": "http://bgm.tv/ep/905525",
          "type": 0,
          "sort": 7,
          "name": "失格者の烙印",
          "name_cn": "失格者的烙印",
          "duration": "00:23:40",
          "airdate": "2019-11-23",
          "comment": 44,
          "desc":
              "整合騎士レンリ・シンセシス・トゥエニセブンは補給部隊の守備を任されるが、初めての戦いに怖気づき、逃げ出してしまった。その結果、キリトがいる補給部隊のテントにまで、闇の軍勢であるゴブリンたちの侵入を許してしまう。\r\n\r\n脚本：漆原虹平\r\n絵コンテ：石井俊匡\r\n演出：伊藤秀弥\r\n総作画監督：山本由美子\r\n作画監督：大高雄太、河野直人、今岡 大、臼井里江、松井瑠生、水野辰哉、徳岡絋平、山本由美子",
          "status": "Air"
        },
        {
          "id": 905526,
          "url": "http://bgm.tv/ep/905526",
          "type": 0,
          "sort": 8,
          "name": "血と命",
          "name_cn": "血和命",
          "duration": "00:23:40",
          "airdate": "2019-11-30",
          "comment": 52,
          "desc":
              "整合騎士アリスの放った強大な術式によって闇の軍勢は大損害を受け、起死回生の策は成功した。\r\n人界軍が勝利に沸く中、アリスは敵の敗残兵に遭遇、皇帝ベクタの目的が《光の巫女》を探し出すことであると知る。\r\n一方、《光の巫女》の存在を察知した皇帝ベクタことガブリエルは、自軍の犠牲を顧みない非情な作戦を展開する。\r\n\r\n脚本：中本 宗応\r\n絵コンテ：中重俊祐\r\n演出：中重俊祐\r\n総作画監督：鈴木 豪\r\n作画監督：古住千秋、熊川ありさ、世良コータ、みうらたけひろ、チョン・ヨンフン、鈴木 豪",
          "status": "Air"
        },
        {
          "id": 905527,
          "url": "http://bgm.tv/ep/905527",
          "type": 0,
          "sort": 9,
          "name": "剣と拳",
          "name_cn": "剑与拳",
          "duration": "00:23:40",
          "airdate": "2019-12-07",
          "comment": 59,
          "desc":
              "《光の巫女》アリスの姿を捉えたガブリエルは彼女を捕らえるため、全軍突撃の命を下す。闇の軍勢の一角を担う精鋭・拳闘士軍は本隊に先行して、アリスたち遊撃隊を追う。心意による強固な肉体をもつ拳闘士軍を迎え撃つための作戦を考えるアリスとベルクーリ。そこに名乗りをあげたのは、これまで無言を貫いていた整合騎士シェータ・シンセシス・トゥエルブだった。\r\n\r\n脚本：漆原虹平\r\n絵コンテ：大塚 健\r\n演出：木村 寛\r\n総作画監督：戸谷賢都\r\n作画監督：鈴木理彩、水野辰哉、竹内由香里、丸山大勝、TOMATO、前田達之、今岡 大、武佐友妃子、戸谷賢都",
          "status": "Air"
        },
        {
          "id": 905528,
          "url": "http://bgm.tv/ep/905528",
          "type": 0,
          "sort": 10,
          "name": "創世神ステイシア",
          "name_cn": "创世神史提西亚",
          "duration": "00:23:40",
          "airdate": "2019-12-14",
          "comment": 86,
          "desc":
              "《創世神ステイシア》のスーパーアカウントを使い、《アンダーワールド》へとログインしたアスナ。彼女が放つ神聖術は、七色のオーロラを帯びる。《地形操作》の効果を持つその術を使う姿は、さながら女神の顕現のようだった。降臨後、ロニエとティーゼの案内でキリトと再会を果たしたアスナ。しかし、その場にアリスもやってきて、二人はキリトをめぐって一触即発状態となり……！\r\n\r\n脚本：漆原虹平\r\n絵コンテ：中山奈緒美\r\n演出：佐久間貴史(st.シルバー)\r\n総作画監督：山本由美子\r\n作画監督：秋月 彩、臼井里江、水野辰哉、前田達之、中田知里、山本由美子",
          "status": "Air"
        },
        {
          "id": 905529,
          "url": "http://bgm.tv/ep/905529",
          "type": 0,
          "sort": 11,
          "name": "非情の選択",
          "name_cn": "无情的选择",
          "duration": "00:23:40",
          "airdate": "2019-12-21",
          "comment": 74,
          "desc":
              "アスナが《地形操作》で作り出した底なしの峡谷。\r\n人界軍が待つ向こう岸にわたるべく、荒縄を橋代わりにして向かおうとする暗黒騎士と拳闘士たち。\r\nこれを好機と見たベルクーリは遊撃隊を率いて出撃する。\r\n一方、現実世界のラース内部では、ガブリエル率いる米工作隊の一人・クリッターによって、奇妙な新規VRMMOの時限βテストが告知され……。\r\n\r\n脚本：中本 宗応\r\n絵コンテ：川村賢一\r\n演出：山田 晃\r\n総作画監督：鈴木 豪\r\n作画監督：世良コータ、古住千秋、チョン・ヨンフン、徳岡紘平、宗圓祐輔、河野直人、鈴木 豪",
          "status": "Air"
        },
        {
          "id": 905530,
          "url": "http://bgm.tv/ep/905530",
          "type": 0,
          "sort": 12,
          "name": "一筋の光",
          "name_cn": "一束光",
          "duration": "00:23:40",
          "airdate": "2019-12-28",
          "comment": 62,
          "desc":
              "ガブリエルの策略によって、暗黒騎士のアカウントを与えられた、現実世界の米国プレイヤーたち。\r\n彼らは、次々と《アンダーワールド》にログイン、人界軍と闇の軍勢の見境なく《人工フラクトライト》たちを殺害していく。\r\n殺戮集団の彼らが現実世界からログインしてきたプレイヤーだと気づいたアスナは、必死に止めようとする。\r\nそして、それを対岸から見ていたイスカーンは、仲間の死に無関心な皇帝に怒りを覚え……。\r\n\r\n脚本：中本 宗応\r\n絵コンテ：藤澤俊幸\r\n演出：セトウケンジ、中重俊祐\r\n総作画監督：戸谷賢都\r\n作画監督：今岡 大、水野辰哉、武佐友紀子、丸山大勝、臼井里江、正木優太、鈴木理彩、秋月 彩",
          "status": "Air"
        }
      ],
      "eps_count": 12,
      "air_date": "2019-10-12",
      "air_weekday": 6,
      "rating": {
        "total": 1364,
        "count": {
          "1": 9,
          "2": 7,
          "3": 7,
          "4": 49,
          "5": 118,
          "6": 321,
          "7": 528,
          "8": 243,
          "9": 37,
          "10": 45
        },
        "score": 6.7
      },
      "rank": 3054,
      "images": {
        "large": "http://lain.bgm.tv/pic/cover/l/dd/a6/279457_2p2B9.jpg",
        "common": "http://lain.bgm.tv/pic/cover/c/dd/a6/279457_2p2B9.jpg",
        "medium": "http://lain.bgm.tv/pic/cover/m/dd/a6/279457_2p2B9.jpg",
        "small": "http://lain.bgm.tv/pic/cover/s/dd/a6/279457_2p2B9.jpg",
        "grid": "http://lain.bgm.tv/pic/cover/g/dd/a6/279457_2p2B9.jpg"
      },
      "collection": {
        "wish": 292,
        "collect": 1620,
        "doing": 537,
        "on_hold": 58,
        "dropped": 46
      },
      "crt": [
        {
          "id": 16489,
          "url": "http://bgm.tv/character/16489",
          "name": "キリト / 桐ヶ谷和人",
          "name_cn": "桐人／桐谷和人",
          "role_name": "主角",
          "images": {
            "large":
                "http://lain.bgm.tv/pic/crt/l/82/4e/16489_crt_mHSx3.jpg?r=1505068032",
            "medium":
                "http://lain.bgm.tv/pic/crt/m/82/4e/16489_crt_mHSx3.jpg?r=1505068032",
            "small":
                "http://lain.bgm.tv/pic/crt/s/82/4e/16489_crt_mHSx3.jpg?r=1505068032",
            "grid":
                "http://lain.bgm.tv/pic/crt/g/82/4e/16489_crt_mHSx3.jpg?r=1505068032"
          },
          "comment": 37,
          "collects": 189,
          "info": {
            "name_cn": "桐人／桐谷和人",
            "alias": {
              "0": "Kirigaya Kazuto",
              "en": "Kirito",
              "jp": "キリト/桐ヶ谷和人"
            },
            "gender": "男",
            "birth": "2008年10月7日",
            "height": "web時代SAO假想體:172cm;GGO假想體:165cm",
            "weight": "web時代SAO假想體:59kg:GGO假想體:51kg",
            "bwh": "GGO假想體:B78-W65-H83"
          },
          "actors": [
            {
              "id": 5764,
              "url": "http://bgm.tv/person/5764",
              "name": "松岡禎丞",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/91/77/5764_prsn_njsm3.jpg?r=1447773082",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/91/77/5764_prsn_njsm3.jpg?r=1447773082",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/91/77/5764_prsn_njsm3.jpg?r=1447773082",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/91/77/5764_prsn_njsm3.jpg?r=1447773082"
              }
            }
          ]
        },
        {
          "id": 16490,
          "url": "http://bgm.tv/character/16490",
          "name": "アスナ / 結城明日奈",
          "name_cn": "亚丝娜／结城明日奈",
          "role_name": "主角",
          "images": {
            "large": "http://lain.bgm.tv/pic/crt/l/58/bd/16490_crt_s5s5C.jpg",
            "medium": "http://lain.bgm.tv/pic/crt/m/58/bd/16490_crt_s5s5C.jpg",
            "small": "http://lain.bgm.tv/pic/crt/s/58/bd/16490_crt_s5s5C.jpg",
            "grid": "http://lain.bgm.tv/pic/crt/g/58/bd/16490_crt_s5s5C.jpg"
          },
          "comment": 41,
          "collects": 407,
          "info": {
            "name_cn": "亚丝娜／结城明日奈",
            "alias": {"en": "Asuna", "jp": "アスナ/結城明日奈"},
            "gender": "女",
            "birth": "2007-9-30"
          },
          "actors": [
            {
              "id": 4856,
              "url": "http://bgm.tv/person/4856",
              "name": "戸松遥",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/7e/b2/4856_prsn_jRCX7.jpg?r=1563346444",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/7e/b2/4856_prsn_jRCX7.jpg?r=1563346444",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/7e/b2/4856_prsn_jRCX7.jpg?r=1563346444",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/7e/b2/4856_prsn_jRCX7.jpg?r=1563346444"
              }
            }
          ]
        },
        {
          "id": 29735,
          "url": "http://bgm.tv/character/29735",
          "name": "アリス・ツーベルク／アリス・シンセシス・サーティ",
          "name_cn": "爱丽丝·滋贝鲁库／爱丽丝·辛赛西斯·萨提",
          "role_name": "主角",
          "images": {
            "large": "http://lain.bgm.tv/pic/crt/l/00/ca/29735_crt_DOnZI.jpg",
            "medium": "http://lain.bgm.tv/pic/crt/m/00/ca/29735_crt_DOnZI.jpg",
            "small": "http://lain.bgm.tv/pic/crt/s/00/ca/29735_crt_DOnZI.jpg",
            "grid": "http://lain.bgm.tv/pic/crt/g/00/ca/29735_crt_DOnZI.jpg"
          },
          "comment": 25,
          "collects": 76,
          "info": {"name_cn": "爱丽丝·滋贝鲁库／爱丽丝·辛赛西斯·萨提", "gender": "女"},
          "actors": [
            {
              "id": 5847,
              "url": "http://bgm.tv/person/5847",
              "name": "茅野愛衣",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/8d/62/5847_prsn_r1tch.jpg?r=1513767674",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/8d/62/5847_prsn_r1tch.jpg?r=1513767674",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/8d/62/5847_prsn_r1tch.jpg?r=1513767674",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/8d/62/5847_prsn_r1tch.jpg?r=1513767674"
              }
            }
          ]
        },
        {
          "id": 16491,
          "url": "http://bgm.tv/character/16491",
          "name": "クライン / 壷井遼太郎",
          "name_cn": "克莱因／壶井辽太郎",
          "role_name": "配角",
          "images": {
            "large":
                "http://lain.bgm.tv/pic/crt/l/2f/80/16491_crt_Dzdbd.jpg?r=1461952832",
            "medium":
                "http://lain.bgm.tv/pic/crt/m/2f/80/16491_crt_Dzdbd.jpg?r=1461952832",
            "small":
                "http://lain.bgm.tv/pic/crt/s/2f/80/16491_crt_Dzdbd.jpg?r=1461952832",
            "grid":
                "http://lain.bgm.tv/pic/crt/g/2f/80/16491_crt_Dzdbd.jpg?r=1461952832"
          },
          "comment": 4,
          "collects": 17,
          "info": {
            "name_cn": "克莱因／壶井辽太郎",
            "alias": {
              "en": "Klein",
              "jp": "壷井 遼太郎",
              "kana": "つぼい りょうたろう",
              "romaji": "Tsuboi Ryoutarou"
            },
            "gender": "男",
            "source": "Wikipedia"
          },
          "actors": [
            {
              "id": 4184,
              "url": "http://bgm.tv/person/4184",
              "name": "平田広明",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/3c/4c/4184_prsn_trDqk.jpg?r=1492863980",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/3c/4c/4184_prsn_trDqk.jpg?r=1492863980",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/3c/4c/4184_prsn_trDqk.jpg?r=1492863980",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/3c/4c/4184_prsn_trDqk.jpg?r=1492863980"
              }
            }
          ]
        },
        {
          "id": 16493,
          "url": "http://bgm.tv/character/16493",
          "name": "エギル / アンドリュー・ギルバート・ミルズ",
          "name_cn": "艾基尔／安德鲁·基尔博德·密鲁茲",
          "role_name": "配角",
          "images": {
            "large":
                "http://lain.bgm.tv/pic/crt/l/79/2a/16493_crt_0dtIk.jpg?r=1461952592",
            "medium":
                "http://lain.bgm.tv/pic/crt/m/79/2a/16493_crt_0dtIk.jpg?r=1461952592",
            "small":
                "http://lain.bgm.tv/pic/crt/s/79/2a/16493_crt_0dtIk.jpg?r=1461952592",
            "grid":
                "http://lain.bgm.tv/pic/crt/g/79/2a/16493_crt_0dtIk.jpg?r=1461952592"
          },
          "comment": 1,
          "collects": 5,
          "info": {
            "name_cn": "艾基尔／安德鲁·基尔博德·密鲁茲",
            "alias": {"en": "Agil／Andrew Gilbert Mills"},
            "gender": "男",
            "source": "Wikipedia"
          },
          "actors": [
            {
              "id": 4483,
              "url": "http://bgm.tv/person/4483",
              "name": "安元洋貴",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/e3/8f/4483_prsn_1GPaF.jpg?r=1510051257",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/e3/8f/4483_prsn_1GPaF.jpg?r=1510051257",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/e3/8f/4483_prsn_1GPaF.jpg?r=1510051257",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/e3/8f/4483_prsn_1GPaF.jpg?r=1510051257"
              }
            }
          ]
        },
        {
          "id": 16494,
          "url": "http://bgm.tv/character/16494",
          "name": "リズベット / 篠崎里香",
          "name_cn": "莉兹贝特／篠崎里香",
          "role_name": "配角",
          "images": {
            "large": "http://lain.bgm.tv/pic/crt/l/2e/a7/16494_crt_9m1Nq.jpg",
            "medium": "http://lain.bgm.tv/pic/crt/m/2e/a7/16494_crt_9m1Nq.jpg",
            "small": "http://lain.bgm.tv/pic/crt/s/2e/a7/16494_crt_9m1Nq.jpg",
            "grid": "http://lain.bgm.tv/pic/crt/g/2e/a7/16494_crt_9m1Nq.jpg"
          },
          "comment": 3,
          "collects": 40,
          "info": {
            "name_cn": "莉兹贝特／篠崎里香",
            "alias": {
              "en": "Lisbeth",
              "jp": "篠崎 里香",
              "kana": "しのざき りか",
              "romaji": "Shinozaki Rika"
            },
            "gender": "女",
            "birth": "2007年5月18日"
          },
          "actors": [
            {
              "id": 4757,
              "url": "http://bgm.tv/person/4757",
              "name": "高垣彩陽",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/bd/da/4757_prsn_ZrIYG.jpg?r=1446370729",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/bd/da/4757_prsn_ZrIYG.jpg?r=1446370729",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/bd/da/4757_prsn_ZrIYG.jpg?r=1446370729",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/bd/da/4757_prsn_ZrIYG.jpg?r=1446370729"
              }
            }
          ]
        },
        {
          "id": 16496,
          "url": "http://bgm.tv/character/16496",
          "name": "シリカ / 綾野珪子",
          "name_cn": "西莉卡／绫野圭子",
          "role_name": "配角",
          "images": {
            "large":
                "http://lain.bgm.tv/pic/crt/l/40/9b/16496_crt_un27Q.jpg?r=1505069662",
            "medium":
                "http://lain.bgm.tv/pic/crt/m/40/9b/16496_crt_un27Q.jpg?r=1505069662",
            "small":
                "http://lain.bgm.tv/pic/crt/s/40/9b/16496_crt_un27Q.jpg?r=1505069662",
            "grid":
                "http://lain.bgm.tv/pic/crt/g/40/9b/16496_crt_un27Q.jpg?r=1505069662"
          },
          "comment": 5,
          "collects": 63,
          "info": {
            "name_cn": "西莉卡／绫野圭子",
            "alias": {
              "en": "Silica",
              "jp": "綾野 珪子",
              "kana": "あやの けいこ",
              "romaji": "Ayano Keiko"
            },
            "gender": "女",
            "birth": "2010年10月4日"
          },
          "actors": [
            {
              "id": 4962,
              "url": "http://bgm.tv/person/4962",
              "name": "日高里菜",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/9f/87/4962_prsn_W8IIV.jpg?r=1506734880",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/9f/87/4962_prsn_W8IIV.jpg?r=1506734880",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/9f/87/4962_prsn_W8IIV.jpg?r=1506734880",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/9f/87/4962_prsn_W8IIV.jpg?r=1506734880"
              }
            }
          ]
        },
        {
          "id": 17646,
          "url": "http://bgm.tv/character/17646",
          "name": "リーファ / 桐ヶ谷直葉",
          "name_cn": "莉法／桐谷直叶",
          "role_name": "配角",
          "images": {
            "large": "http://lain.bgm.tv/pic/crt/l/24/86/17646_crt_353qM.jpg",
            "medium": "http://lain.bgm.tv/pic/crt/m/24/86/17646_crt_353qM.jpg",
            "small": "http://lain.bgm.tv/pic/crt/s/24/86/17646_crt_353qM.jpg",
            "grid": "http://lain.bgm.tv/pic/crt/g/24/86/17646_crt_353qM.jpg"
          },
          "comment": 18,
          "collects": 116,
          "info": {
            "name_cn": "莉法／桐谷直叶",
            "alias": {
              "en": "Leafa",
              "jp": "桐ヶ谷 直葉",
              "kana": "きりがや すぐは",
              "romaji": "Kirigaya Suguha"
            },
            "gender": "女",
            "birth": "2009年4月19日",
            "source": "中文维基:刀剑神域角色列表"
          },
          "actors": [
            {
              "id": 5228,
              "url": "http://bgm.tv/person/5228",
              "name": "竹達彩奈",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/2b/7b/5228_prsn_91ppC.jpg?r=1515402263",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/2b/7b/5228_prsn_91ppC.jpg?r=1515402263",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/2b/7b/5228_prsn_91ppC.jpg?r=1515402263",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/2b/7b/5228_prsn_91ppC.jpg?r=1515402263"
              }
            }
          ]
        },
        {
          "id": 17647,
          "url": "http://bgm.tv/character/17647",
          "name": "ユイ",
          "name_cn": "结衣",
          "role_name": "配角",
          "images": {
            "large": "http://lain.bgm.tv/pic/crt/l/a6/19/17647_crt_x346a.jpg",
            "medium": "http://lain.bgm.tv/pic/crt/m/a6/19/17647_crt_x346a.jpg",
            "small": "http://lain.bgm.tv/pic/crt/s/a6/19/17647_crt_x346a.jpg",
            "grid": "http://lain.bgm.tv/pic/crt/g/a6/19/17647_crt_x346a.jpg"
          },
          "comment": 5,
          "collects": 72,
          "info": {
            "name_cn": "结衣",
            "alias": {"zh": "唯", "romaji": "Yui"},
            "gender": "女"
          },
          "actors": [
            {
              "id": 4949,
              "url": "http://bgm.tv/person/4949",
              "name": "伊藤かな恵",
              "images": {
                "large":
                    "http://lain.bgm.tv/pic/crt/l/0c/13/4949_prsn_SI9qW.jpg?r=1501339699",
                "medium":
                    "http://lain.bgm.tv/pic/crt/m/0c/13/4949_prsn_SI9qW.jpg?r=1501339699",
                "small":
                    "http://lain.bgm.tv/pic/crt/s/0c/13/4949_prsn_SI9qW.jpg?r=1501339699",
                "grid":
                    "http://lain.bgm.tv/pic/crt/g/0c/13/4949_prsn_SI9qW.jpg?r=1501339699"
              }
            }
          ]
        }
      ],
      "staff": [
        {
          "id": 7173,
          "url": "http://bgm.tv/person/7173",
          "name": "川原礫",
          "name_cn": "川原砾",
          "role_name": "",
          "images": {
            "large": "http://lain.bgm.tv/pic/crt/l/49/26/7173_prsn_EH4fx.jpg",
            "medium": "http://lain.bgm.tv/pic/crt/m/49/26/7173_prsn_EH4fx.jpg",
            "small": "http://lain.bgm.tv/pic/crt/s/49/26/7173_prsn_EH4fx.jpg",
            "grid": "http://lain.bgm.tv/pic/crt/g/49/26/7173_prsn_EH4fx.jpg"
          },
          "comment": 22,
          "collects": 0,
          "info": {
            "name_cn": "川原砾",
            "alias": {
              "0": "攻打引（せめだいん）",
              "1": "九里史生（くのり ふみお）",
              "kana": "かわはら れき"
            },
            "gender": "男",
            "birth": "1974-08-17"
          },
          "jobs": ["原作"]
        },
        {
          "id": 2718,
          "url": "http://bgm.tv/person/2718",
          "name": "小野学",
          "name_cn": "小野学",
          "role_name": "",
          "images": {
            "large":
                "http://lain.bgm.tv/pic/crt/l/77/87/2718_prsn_PW2wW.jpg?r=1489768180",
            "medium":
                "http://lain.bgm.tv/pic/crt/m/77/87/2718_prsn_PW2wW.jpg?r=1489768180",
            "small":
                "http://lain.bgm.tv/pic/crt/s/77/87/2718_prsn_PW2wW.jpg?r=1489768180",
            "grid":
                "http://lain.bgm.tv/pic/crt/g/77/87/2718_prsn_PW2wW.jpg?r=1489768180"
          },
          "comment": 31,
          "collects": 0,
          "info": {
            "name_cn": "小野学",
            "alias": {"jp": "小野学", "kana": "おの まなぶ", "romaji": "Ono Manabu"},
            "gender": "男"
          },
          "jobs": ["导演", "分镜"]
        },
        {
          "id": 1183,
          "url": "http://bgm.tv/person/1183",
          "name": "大塚健",
          "name_cn": "大冢健",
          "role_name": "",
          "images": null,
          "comment": 0,
          "collects": 0,
          "info": {
            "name_cn": "大冢健",
            "alias": {
              "0": "ケンオー",
              "1": "ケンオーさん",
              "kana": "おおつか けん",
              "romaji": "Otsuka Ken"
            },
            "gender": "男",
            "birth": "1970年5月22日"
          },
          "jobs": ["分镜"]
        },
        {
          "id": 21139,
          "url": "http://bgm.tv/person/21139",
          "name": "石井俊匡",
          "name_cn": "石井俊匡",
          "role_name": "",
          "images": {
            "large": "http://lain.bgm.tv/pic/crt/l/21/a4/21139_prsn_6c8Vp.jpg",
            "medium": "http://lain.bgm.tv/pic/crt/m/21/a4/21139_prsn_6c8Vp.jpg",
            "small": "http://lain.bgm.tv/pic/crt/s/21/a4/21139_prsn_6c8Vp.jpg",
            "grid": "http://lain.bgm.tv/pic/crt/g/21/a4/21139_prsn_6c8Vp.jpg"
          },
          "comment": 13,
          "collects": 0,
          "info": {"name_cn": "石井俊匡"},
          "jobs": ["分镜"]
        },
        {
          "id": 12609,
          "url": "http://bgm.tv/person/12609",
          "name": "川村賢一",
          "name_cn": "川村贤一",
          "role_name": "",
          "images": null,
          "comment": 9,
          "collects": 0,
          "info": {
            "name_cn": "川村贤一",
            "alias": {
              "jp": "川村 賢一",
              "kana": "かわむら けんいち",
              "romaji": "Kawamura Kenichi"
            },
            "gender": "男"
          },
          "jobs": ["分镜"]
        },
        {
          "id": 26587,
          "url": "http://bgm.tv/person/26587",
          "name": "佐久間貴史",
          "name_cn": "佐久间贵史",
          "role_name": "",
          "images": null,
          "comment": 1,
          "collects": 0,
          "info": {
            "name_cn": "佐久间贵史",
            "alias": {"kana": "さくま　たかし", "romaji": "Sakuma Takashi"},
            "gender": "男"
          },
          "jobs": ["分镜"]
        },
        {
          "id": 12509,
          "url": "http://bgm.tv/person/12509",
          "name": "菅野芳弘",
          "name_cn": "",
          "role_name": "",
          "images": null,
          "comment": 1,
          "collects": 0,
          "info": {
            "alias": {"kana": "かんの よしひろ", "romaji": "kanno yoshihiro"}
          },
          "jobs": ["分镜"]
        },
        {
          "id": 13630,
          "url": "http://bgm.tv/person/13630",
          "name": "みうらたけひろ",
          "name_cn": "三浦武弘",
          "role_name": "",
          "images": {
            "large": "http://lain.bgm.tv/pic/crt/l/db/3e/13630_prsn_KBUvm.jpg",
            "medium": "http://lain.bgm.tv/pic/crt/m/db/3e/13630_prsn_KBUvm.jpg",
            "small": "http://lain.bgm.tv/pic/crt/s/db/3e/13630_prsn_KBUvm.jpg",
            "grid": "http://lain.bgm.tv/pic/crt/g/db/3e/13630_prsn_KBUvm.jpg"
          },
          "comment": 3,
          "collects": 0,
          "info": {
            "name_cn": "三浦武弘",
            "主页（已失效）": "http://miutake.x0.com",
            "pixiv_id": "176282",
            "twitter": "@miuratakehiro"
          },
          "jobs": ["分镜"]
        }
      ],
      "topic": null,
      "blog": [
        {
          "id": 294347,
          "url": "http://bgm.tv/blog/294347",
          "title": "当爽番看，全程遭罪",
          "summary":
              "某种程度我还是挺佩服桐姥爷的，换做是我，\r\n要是知道在这个没WiFi没电脑的鬼地方被困上两年只因为某人的误操作，准气得吐血，\r\n好不容易练个级结果还要遭受真实皮肉甚至断臂之苦，\r\n好不容易培养起感情结果告诉我所有人都要被删除，\r\n好不容易到了控制台结果得知脑子要被烧坏 ...",
          "image": "",
          "replies": 2,
          "timestamp": 1577896411,
          "dateline": "2020-1-1 16:33",
          "user": {
            "id": 515405,
            "url": "http://bgm.tv/user/515405",
            "username": "515405",
            "nickname": "wlm3201",
            "avatar": {
              "large": "http://lain.bgm.tv/pic/user/l/icon.jpg",
              "medium": "http://lain.bgm.tv/pic/user/m/icon.jpg",
              "small": "http://lain.bgm.tv/pic/user/s/icon.jpg"
            },
            "sign": null
          }
        },
        {
          "id": 294245,
          "url": "http://bgm.tv/blog/294245",
          "title": "我知道刀剑很屑，但同时，我还是刀剑粉丝",
          "summary":
              "不得不说，这是个颇具争议的作品。\r\n当有人说它设定牛逼的时候，就会有人指出它的一堆bug；当有人说它人物牛逼的时候，就连老粉恐怕也会表示亚丝娜真就是个游离在剧情之外的工具女主角；当有人说它帅的时候，自然也会有人跳出来表示第一季加起来也只有三场能看的打戏；当有人 ...",
          "image": "",
          "replies": 5,
          "timestamp": 1577376863,
          "dateline": "2019-12-26 16:14",
          "user": {
            "id": 516526,
            "url": "http://bgm.tv/user/heilou",
            "username": "heilou",
            "nickname": "纤墨",
            "avatar": {
              "large":
                  "http://lain.bgm.tv/pic/user/l/000/51/65/516526.jpg?r=1577376959",
              "medium":
                  "http://lain.bgm.tv/pic/user/m/000/51/65/516526.jpg?r=1577376959",
              "small":
                  "http://lain.bgm.tv/pic/user/s/000/51/65/516526.jpg?r=1577376959"
            },
            "sign": null
          }
        },
        {
          "id": 294238,
          "url": "http://bgm.tv/blog/294238",
          "title": "好消息 好消息！！！",
          "summary":
              "三A大作 性感亚斯娜上线开挂 一刀爆满级 神级角色随便选 点开异界战争 这里有你想不到的刺激历险 后宫团全聚集 保护断臂桐人通关打BOSS 快来体验吧",
          "image": "",
          "replies": 0,
          "timestamp": 1577326304,
          "dateline": "2019-12-26 02:11",
          "user": {
            "id": 407378,
            "url": "http://bgm.tv/user/harukizzp",
            "username": "harukizzp",
            "nickname": "加藤全栈",
            "avatar": {
              "large":
                  "http://lain.bgm.tv/pic/user/l/000/40/73/407378.jpg?r=1552457935",
              "medium":
                  "http://lain.bgm.tv/pic/user/m/000/40/73/407378.jpg?r=1552457935",
              "small":
                  "http://lain.bgm.tv/pic/user/s/000/40/73/407378.jpg?r=1552457935"
            },
            "sign": null
          }
        },
        {
          "id": 293254,
          "url": "http://bgm.tv/blog/293254",
          "title": "一部明明知道会失望又忍不住去看的动画",
          "summary":
              "在异世界轻改爽文和欢乐向作品横行的年代还有几部试图认真讲一个故事的作品看实属不易，故事讲的怎么样暂且不谈，光是作品性质还是让人很想看一看的。\r\n\r\n可惜事与愿违，前三季就那样说明这部作品的问题根本就不在于动画制作，而在于原作本身，而如此一部原作销量极高的作 ...",
          "image": "",
          "replies": 26,
          "timestamp": 1571035878,
          "dateline": "2019-10-14 06:51",
          "user": {
            "id": 444004,
            "url": "http://bgm.tv/user/444004",
            "username": "444004",
            "nickname": "GlitterSora",
            "avatar": {
              "large":
                  "http://lain.bgm.tv/pic/user/l/000/44/40/444004.jpg?r=1554890622",
              "medium":
                  "http://lain.bgm.tv/pic/user/m/000/44/40/444004.jpg?r=1554890622",
              "small":
                  "http://lain.bgm.tv/pic/user/s/000/44/40/444004.jpg?r=1554890622"
            },
            "sign": null
          }
        }
      ]
    },
    {
      "id": 279457,
      "type": 2,
      "name": "ソードアート・オンライン アリシゼーション War of Underworld",
      "image": "//lain.bgm.tv/pic/cover/m/dd/a6/279457_2p2B9.jpg",
      "rating": {
        "total": 1163,
        "count": {
          "1": 8,
          "2": 7,
          "3": 5,
          "4": 42,
          "5": 98,
          "6": 257,
          "7": 454,
          "8": 218,
          "9": 34,
          "10": 40
        },
        "score": 6.8
      },
      "summary":
          "桐人、尤吉欧、爱丽丝。\r\n距离两名修剑士和一名整合骑士打败了最高祭司阿多米尼斯多雷特已过去了半年。\r\n结束了战斗，爱丽丝在故乡卢利特村生活。\r\n在她的身旁，是失去了挚友，自己也失去了手臂和心的桐人。\r\n献身般支撑着他的爱丽丝，丝毫没有保留像以前一样作为骑士的心。 \r\n“告诉我，桐人……我究竟该怎么办？”\r\n然而，通往将 Underworld 全境引向悲剧的“最终压力测试”的倒计时，却毫不留情地推进着。\r\n仿佛与之相呼应一般，在“黑暗领域”的深处，暗黑神贝库达复活了。他率领暗黑帝国的军队，为了得到“光之巫女”，开始向“人界”进攻。\r\n指挥“人界”军队的贝尔库利等人，决心与“黑暗领域”的军队展开前所未有的大战。\r\n但在他们身旁，并没有发现爱丽丝，以及拯救了“人界”的两位英雄的身影。 \r\n《刀剑神域》系列最长、拥有最华丽战斗的“Alicization”篇，其最终章终于揭幕！",
      "info":
          "<li><span>中文名: </span>刀剑神域 Alicization篇 War of Underworld</li><li><span>话数: </span>12</li><li><span>放送开始: </span>2019年10月12日</li><li><span>放送星期: </span>星期六</li><li><span>原作: </span><a href=\"/person/7173\">川原礫</a>（「電撃文庫」刊）</li><li><span>导演: </span><a href=\"/person/2718\" rel=\"v:directedBy\">小野学</a></li><li><span>分镜: </span><a href=\"/person/13630\">みうらたけひろ</a>、<a href=\"/person/21139\">石井俊匡</a>、<a href=\"/person/12609\">川村賢一</a>、<a href=\"/person/12509\">菅野芳弘</a>、<a href=\"/person/1183\">大塚健</a>、<a href=\"/person/26587\">佐久間貴史</a>、<a href=\"/person/12050\">中山奈緒美</a>、<a href=\"/person/12039\">藤澤俊幸</a>、<a href=\"/person/2718\">小野学</a>、<a href=\"/person/26981\">中重俊祐</a>、<a href=\"/person/13038\">木村寛</a></li><li><span>演出: </span><a href=\"/person/26981\">中重俊祐</a>、<a href=\"/person/13630\">みうらたけひろ</a>、<a href=\"/person/13038\">木村寛</a>、<a href=\"/person/18097\">瀬藤健嗣</a>、<a href=\"/person/26587\">佐久間貴史</a>、<a href=\"/person/12050\">中山奈緒美</a></li><li><span>音乐: </span><a href=\"/person/1595\">梶浦由記</a></li><li><span>人物原案: </span>abec(<a href=\"/person/7516\">BUNBUN</a>)</li><li><span>人物设定: </span><a href=\"/person/14213\">鈴木豪</a>、<a href=\"/person/3183\">足立慎吾</a>、<a href=\"/person/30719\">西口智也</a>、<a href=\"/person/35620\">山本由美子</a>、<a href=\"/person/25300\">戸谷賢都</a></li><li><span>美术监督: </span><a href=\"/person/561\">小川友佳子</a>、<a href=\"/person/14547\">渡辺佳人</a></li><li><span>色彩设计: </span><a href=\"/person/12760\">中野尚美</a></li><li><span>总作画监督: </span><a href=\"/person/14213\">鈴木豪</a>、<a href=\"/person/25300\">戸谷賢都</a>、<a href=\"/person/35620\">山本由美子</a></li><li><span>作画监督: </span><a href=\"/person/12509\">菅野芳弘</a>、<a href=\"/person/34917\">世良コータ</a>、<a href=\"/person/13630\">みうらたけひろ</a>、<a href=\"/person/31749\">徳岡紘平</a></li><li><span>摄影监督: </span><a href=\"/person/22902\">脇顯太朗</a>、<a href=\"/person/32933\">林賢太</a></li><li><span>道具设计: </span><a href=\"/person/32931\">早川麻美</a>、<a href=\"/person/21510\">伊藤公規</a></li><li><span>原画: </span><a href=\"/person/13630\">みうらたけひろ</a>、<a href=\"/person/11315\">吉原達矢</a>、<a href=\"/person/15115\">鳥居貴史</a>、<a href=\"/person/27043\">板垣彰子</a>、<a href=\"/person/35947\">岩澤亨</a>、<a href=\"/person/35375\">森公太</a>、<a href=\"/person/35590\">羅燦然</a>、<a href=\"/person/35703\">佐藤颯</a>、<a href=\"/person/12509\">菅野芳弘</a>、<a href=\"/person/3047\">竹内哲也</a>、<a href=\"/person/35639\">清水和也</a></li><li><span>第二原画: </span><a href=\"/person/35794\">World Anime Networks</a>、<a href=\"/person/35639\">清水和也</a></li><li><span>剪辑: </span><a href=\"/person/22673\">近藤勇二</a></li><li><span>主题歌编曲: </span><a href=\"/person/9254\">堀江晶太</a></li><li><span>主题歌作曲: </span><a href=\"/person/16251\">草野華余子</a></li><li><span>主题歌演出: </span><a href=\"/person/5921\">LiSA</a></li><li><span>製作: </span>SAO-A Project（<a href=\"/person/645\">Aniplex</a>、<a href=\"/person/19306\">KADOKAWA</a><a href=\"/person/6140\">アスキー・メディアワークス</a>、<a href=\"/person/3502\">バンダイナムコエンターテインメント</a>、<a href=\"/person/220\">ジェンコ</a>、<a href=\"/person/33716\">ストレートエッジ</a>、<a href=\"/person/24551\">EGG FIRM</a>）</li><li><span>音响监督: </span><a href=\"/person/231\">岩浪美和</a></li><li><span>音响: </span><a href=\"/person/35621\">ソニルード</a></li><li><span>音效: </span><a href=\"/person/19185\">小山恭正</a></li><li><span>制片人: </span><a href=\"/person/35919\">金子敦史</a></li><li><span>制作: </span><a href=\"/person/24551\">EGG FIRM</a>、<a href=\"/person/33716\">ストレートエッジ</a></li><li><span>动画制作: </span><a href=\"/person/3525\">A-1 Pictures</a></li><li><span>CG 导演: </span><a href=\"/person/19613\">雲藤隆太</a></li><li><span>美术设计: </span><a href=\"/person/28626\">森岡賢一</a>、<a href=\"/person/2581\">谷内優穂</a></li><li><span>副导演: </span><a href=\"/person/26587\">佐久間貴史</a></li><li><span>OP・ED 分镜: </span><a href=\"/person/26981\">中重俊祐</a></li><li><span>别名: </span>刀剑神域 爱丽丝篇 异界战争</li><li><span style=\"visibility:hidden;\">别名: </span>Sword Art Online -Alicization- War of Underworld</li><li><span>官方网站: </span>https://sao-alicization.net/</li><li><span>播放电视台: </span>TOKYO MX</li><li><span>其他电视台: </span>BS11 / 群馬テレビ / とちぎテレビ / MBS / テレビ愛知 / AT-X / AbemaTV</li><li><span>播放结束: </span>2019年12月28日</li><li><span>Copyright: </span>© 2017 川原 礫／KADOKAWA アスキー・メディアワークス／SAO-A Project</li>",
      "collection": {
        "wish": 288,
        "collect": 1265,
        "doing": 704,
        "on_hold": 47,
        "dropped": 34
      },
      "tags": [
        {"name": "A-1Pictures", "count": 303},
        {"name": "2019年10月", "count": 302},
        {"name": "刀剑神域", "count": 242},
        {"name": "轻小说改", "count": 199},
        {"name": "TV", "count": 160},
        {"name": "轻改", "count": 97},
        {"name": "战斗", "count": 91},
        {"name": "后宫", "count": 90},
        {"name": "2019", "count": 77},
        {"name": "小野学", "count": 72},
        {"name": "科幻", "count": 55},
        {"name": "A-1_Pictures", "count": 18},
        {"name": "日本动画", "count": 11},
        {"name": "小说改", "count": 11},
        {"name": "奇幻", "count": 7},
        {"name": "2019年", "count": 7},
        {"name": "续作", "count": 6},
        {"name": "热血", "count": 5},
        {"name": "冒险", "count": 5},
        {"name": "动画", "count": 4},
        {"name": "日本", "count": 4},
        {"name": "网游", "count": 4},
        {"name": "松岡禎丞", "count": 4},
        {"name": "恋爱", "count": 4},
        {"name": "装逼", "count": 3},
        {"name": "诹访部顺一", "count": 3},
        {"name": "茅野愛衣", "count": 3},
        {"name": "松冈祯丞", "count": 3},
        {"name": "梶浦由記", "count": 3},
        {"name": "茅野爱衣", "count": 3}
      ],
      "eps": [
        {
          "id": 906496,
          "url": "http://bgm.tv/ep/906496",
          "type": 1,
          "sort": 0,
          "name": "リフレクション",
          "name_cn": "Reflection（总集篇）",
          "duration": "00:23:40",
          "airdate": "2019-10-05",
          "comment": 5,
          "desc": "",
          "status": "Air"
        },
        {
          "id": 905519,
          "url": "http://bgm.tv/ep/905519",
          "type": 0,
          "sort": 1,
          "name": "北の地にて",
          "name_cn": "在北方的土地上",
          "duration": "00:23:40",
          "airdate": "2019-10-12",
          "comment": 63,
          "desc":
              "アドミニストレータとの激闘から半年が過ぎた。右腕を失い、廃人のようになってしまったキリトを連れたアリスは、故郷であるルーリッド村のはずれで静かに暮らしていた。彼と共に守った世界を眺め、これまでを思い返すアリス。そんな彼女の前に、整合騎士の同僚であり、弟子でもあるエルドリエ・シンセシス・サーティワンが姿を見せる。\r\n\r\n脚本：中本宗応\r\n絵コンテ：小野 学\r\n演出：佐久間貴史(st.シルバー)\r\n総作画監督：山本由美子\r\n作画監督：前田達之、大高美奈、秋月 彩",
          "status": "Air"
        },
        {
          "id": 905520,
          "url": "http://bgm.tv/ep/905520",
          "type": 0,
          "sort": 2,
          "name": "襲撃",
          "name_cn": "袭击",
          "duration": "00:23:40",
          "airdate": "2019-10-19",
          "comment": 53,
          "desc":
              "ダークテリトリーの軍勢がルーリッド村を襲撃した。飛竜《雨縁》に乗り、村に駆け付けるアリス。そこには、《禁忌目録》によって衛士長の命令に逆らえず、ゴブリンたちから逃げることができない村人たちがいた。戦う目的を見失っていたアリスは、自らの家族のため、キリトとユージオが守ろうとした人々のために、再び整合騎士の鎧を身にまとい、《金木犀の剣》を振るう！\r\n\r\n脚本：中本宗応\r\n絵コンテ：みうらたけひろ\r\n演出：みうらたけひろ\r\n総作画監督：鈴木 豪\r\n作画監督：世良コータ、チョン・ヨンフン、古住千秋、今岡 大、みうらたけひろ",
          "status": "Air"
        },
        {
          "id": 905521,
          "url": "http://bgm.tv/ep/905521",
          "type": 0,
          "sort": 3,
          "name": "最終負荷実験",
          "name_cn": "最终负荷实验",
          "duration": "00:23:40",
          "airdate": "2019-10-26",
          "comment": 66,
          "desc":
              "《オーシャン・タートル》を襲撃した謎の組織――それはアメリカ国家安全保障局の極秘任務を受けた特殊工作部隊だった。\r\n部隊を率いるリーダーのガブリエルは、過去にキリトやシノンと交戦したことがあり…。\r\n《ソウル・トランスレーション・テクノロジー》で造られた人工の魂《A.L.I.C.E》＝アリス強奪を狙うガブリエルは、《アンダーワールド》内にいるアリスを探し出すため、ある秘策を試みる。\r\n\r\n脚本：中本宗応\r\n絵コンテ：木村 寛、菅野芳弘\r\n演出：木村 寛\r\n総作画監督：戸谷賢都\r\n作画監督：水野辰哉、小松沙奈、鈴木理彩、戸谷賢都",
          "status": "Air"
        },
        {
          "id": 905522,
          "url": "http://bgm.tv/ep/905522",
          "type": 0,
          "sort": 4,
          "name": "ダークテリトリー",
          "name_cn": "暗黑帝国",
          "duration": "00:23:40",
          "airdate": "2019-11-02",
          "comment": 78,
          "desc":
              "ダークテリトリーの暗黒騎士団を率いる騎士団長シャスターは、アドミニストレータが死んだことを機に、人界へ和平を持ち掛けようとしていた。しかしその試みは皇帝ベクタの暗黒界帰還によって打ち砕かれる。ベクタのアカウントを使って《アンダーワールド》にログインしたガブリエル。彼は《A.L.I.C.E》を見つけ出すため、闇の軍勢たちに向かって人界との全面戦争を指示する。\r\n\r\n脚本：木澤行人\r\n絵コンテ：古田丈司、菅野芳弘\r\n演出：中山奈緒美、佐久間貴史(st.シルバー)\r\n総作画監督：山本由美子\r\n作画監督：大高美奈、丸山大勝、古住千秋、今岡 大、宮本武史、チョン・ヨンフン、世良コータ、鈴木理彩、水野辰哉、山本由美子",
          "status": "Air"
        },
        {
          "id": 905523,
          "url": "http://bgm.tv/ep/905523",
          "type": 0,
          "sort": 5,
          "name": "開戦前夜",
          "name_cn": "开战前夜",
          "duration": "00:23:40",
          "airdate": "2019-11-09",
          "comment": 52,
          "desc":
              "人界とダークテリトリーを隔てる《東の大門》。そのすぐそばまで、闇の軍勢が迫ってきた。\r\n人々のために戦うことを決意したアリスは、キリトを連れて人界軍に合流する。\r\nしかし圧倒的なダークテリトリー軍の兵力に比べ、人界軍で戦闘可能な整合騎士は、わずか十三人しかいなかった。\r\n絶対的劣勢の中、前線でも廃人同様のキリトを帯同するかどうか迷うアリスだったが……。\r\n\r\n脚本：木澤行人\r\n絵コンテ：佐久間貴史\r\n演出：尾ノ上知久\r\n総作画監督：鈴木 豪\r\n作画監督：Won Chang hee、Kwon Oh sik、Ahn Hyo jeong、Jeong Yeon soon、Jang Hee kyu、Joung Eun joung、Lim Keun soo、徳岡紘平、山本由美子、竹内由香里、吉岡 勝",
          "status": "Air"
        },
        {
          "id": 905524,
          "url": "http://bgm.tv/ep/905524",
          "type": 0,
          "sort": 6,
          "name": "騎士たちの戦い",
          "name_cn": "骑士们的战斗",
          "duration": "00:23:40",
          "airdate": "2019-11-16",
          "comment": 71,
          "desc":
              "《最終負荷実験》が始まり、《東の大門》がついに崩壊した。皇帝ベクタとなったガブリエルにたきつけられ、大規模な軍隊を形成した闇の軍勢は、人界へと進軍する。迎え撃つ少数精鋭の人界軍は、部隊を分けて迎え撃つ。絶望的な戦力差にもかかわらず、人界軍の整合騎士たちは一騎当千の凄まじい力で敵を打ち倒していく。だが闇の軍勢はその圧倒的な兵数で徐々に人界軍を蹴散らしていくのだった。\r\n\r\n脚本：木澤行人\r\n絵コンテ：大塚 健\r\n演出：鈴木拓磨\r\n総作画監督：戸谷賢都\r\n作画監督：大高美奈、前田達之、秋月 彩、山本亮友",
          "status": "Air"
        },
        {
          "id": 905525,
          "url": "http://bgm.tv/ep/905525",
          "type": 0,
          "sort": 7,
          "name": "失格者の烙印",
          "name_cn": "失格者的烙印",
          "duration": "00:23:40",
          "airdate": "2019-11-23",
          "comment": 43,
          "desc":
              "整合騎士レンリ・シンセシス・トゥエニセブンは補給部隊の守備を任されるが、初めての戦いに怖気づき、逃げ出してしまった。その結果、キリトがいる補給部隊のテントにまで、闇の軍勢であるゴブリンたちの侵入を許してしまう。\r\n\r\n脚本：漆原虹平\r\n絵コンテ：石井俊匡\r\n演出：伊藤秀弥\r\n総作画監督：山本由美子\r\n作画監督：大高雄太、河野直人、今岡 大、臼井里江、松井瑠生、水野辰哉、徳岡絋平、山本由美子",
          "status": "Air"
        },
        {
          "id": 905526,
          "url": "http://bgm.tv/ep/905526",
          "type": 0,
          "sort": 8,
          "name": "血と命",
          "name_cn": "血和命",
          "duration": "00:23:40",
          "airdate": "2019-11-30",
          "comment": 51,
          "desc":
              "整合騎士アリスの放った強大な術式によって闇の軍勢は大損害を受け、起死回生の策は成功した。\r\n人界軍が勝利に沸く中、アリスは敵の敗残兵に遭遇、皇帝ベクタの目的が《光の巫女》を探し出すことであると知る。\r\n一方、《光の巫女》の存在を察知した皇帝ベクタことガブリエルは、自軍の犠牲を顧みない非情な作戦を展開する。\r\n\r\n脚本：中本 宗応\r\n絵コンテ：中重俊祐\r\n演出：中重俊祐\r\n総作画監督：鈴木 豪\r\n作画監督：古住千秋、熊川ありさ、世良コータ、みうらたけひろ、チョン・ヨンフン、鈴木 豪",
          "status": "Air"
        },
        {
          "id": 905527,
          "url": "http://bgm.tv/ep/905527",
          "type": 0,
          "sort": 9,
          "name": "剣と拳",
          "name_cn": "剑与拳",
          "duration": "00:23:40",
          "airdate": "2019-12-07",
          "comment": 58,
          "desc":
              "《光の巫女》アリスの姿を捉えたガブリエルは彼女を捕らえるため、全軍突撃の命を下す。闇の軍勢の一角を担う精鋭・拳闘士軍は本隊に先行して、アリスたち遊撃隊を追う。心意による強固な肉体をもつ拳闘士軍を迎え撃つための作戦を考えるアリスとベルクーリ。そこに名乗りをあげたのは、これまで無言を貫いていた整合騎士シェータ・シンセシス・トゥエルブだった。\r\n\r\n脚本：漆原虹平\r\n絵コンテ：大塚 健\r\n演出：木村 寛\r\n総作画監督：戸谷賢都\r\n作画監督：鈴木理彩、水野辰哉、竹内由香里、丸山大勝、TOMATO、前田達之、今岡 大、武佐友妃子、戸谷賢都",
          "status": "Air"
        },
        {
          "id": 905528,
          "url": "http://bgm.tv/ep/905528",
          "type": 0,
          "sort": 10,
          "name": "創世神ステイシア",
          "name_cn": "创世神史提西亚",
          "duration": "00:23:40",
          "airdate": "2019-12-14",
          "comment": 83,
          "desc":
              "《創世神ステイシア》のスーパーアカウントを使い、《アンダーワールド》へとログインしたアスナ。彼女が放つ神聖術は、七色のオーロラを帯びる。《地形操作》の効果を持つその術を使う姿は、さながら女神の顕現のようだった。降臨後、ロニエとティーゼの案内でキリトと再会を果たしたアスナ。しかし、その場にアリスもやってきて、二人はキリトをめぐって一触即発状態となり……！\r\n\r\n脚本：漆原虹平\r\n絵コンテ：中山奈緒美\r\n演出：佐久間貴史(st.シルバー)\r\n総作画監督：山本由美子\r\n作画監督：秋月 彩、臼井里江、水野辰哉、前田達之、中田知里、山本由美子",
          "status": "Air"
        },
        {
          "id": 905529,
          "url": "http://bgm.tv/ep/905529",
          "type": 0,
          "sort": 11,
          "name": "非情の選択",
          "name_cn": "无情的选择",
          "duration": "00:23:40",
          "airdate": "2019-12-21",
          "comment": 72,
          "desc":
              "アスナが《地形操作》で作り出した底なしの峡谷。\r\n人界軍が待つ向こう岸にわたるべく、荒縄を橋代わりにして向かおうとする暗黒騎士と拳闘士たち。\r\nこれを好機と見たベルクーリは遊撃隊を率いて出撃する。\r\n一方、現実世界のラース内部では、ガブリエル率いる米工作隊の一人・クリッターによって、奇妙な新規VRMMOの時限βテストが告知され……。\r\n\r\n脚本：中本 宗応\r\n絵コンテ：川村賢一\r\n演出：山田 晃\r\n総作画監督：鈴木 豪\r\n作画監督：世良コータ、古住千秋、チョン・ヨンフン、徳岡紘平、宗圓祐輔、河野直人、鈴木 豪",
          "status": "Air"
        },
        {
          "id": 905530,
          "url": "http://bgm.tv/ep/905530",
          "type": 0,
          "sort": 12,
          "name": "一筋の光",
          "name_cn": "一束光",
          "duration": "00:23:40",
          "airdate": "2019-12-28",
          "comment": 59,
          "desc":
              "ガブリエルの策略によって、暗黒騎士のアカウントを与えられた、現実世界の米国プレイヤーたち。\r\n彼らは、次々と《アンダーワールド》にログイン、人界軍と闇の軍勢の見境なく《人工フラクトライト》たちを殺害していく。\r\n殺戮集団の彼らが現実世界からログインしてきたプレイヤーだと気づいたアスナは、必死に止めようとする。\r\nそして、それを対岸から見ていたイスカーンは、仲間の死に無関心な皇帝に怒りを覚え……。\r\n\r\n脚本：中本 宗応\r\n絵コンテ：藤澤俊幸\r\n演出：セトウケンジ、中重俊祐\r\n総作画監督：戸谷賢都\r\n作画監督：今岡 大、水野辰哉、武佐友紀子、丸山大勝、臼井里江、正木優太、鈴木理彩、秋月 彩",
          "status": "Air"
        }
      ],
      "crt": [
        {
          "id": 16489,
          "image": "//lain.bgm.tv/pic/crt/g/82/4e/16489_crt_mHSx3.jpg",
          "name": "桐人／桐谷和人",
          "desc": "松岡禎丞"
        },
        {
          "id": 16490,
          "image": "//lain.bgm.tv/pic/crt/g/58/bd/16490_crt_s5s5C.jpg",
          "name": "亚丝娜／结城明日奈",
          "desc": "戸松遥"
        },
        {
          "id": 29735,
          "image": "//lain.bgm.tv/pic/crt/g/00/ca/29735_crt_DOnZI.jpg",
          "name": "爱丽丝·滋贝鲁库／爱丽丝·辛赛西斯·萨提",
          "desc": "茅野愛衣"
        },
        {
          "id": 16491,
          "image": "//lain.bgm.tv/pic/crt/g/2f/80/16491_crt_Dzdbd.jpg",
          "name": "克莱因／壶井辽太郎",
          "desc": "平田広明"
        },
        {
          "id": 16493,
          "image": "//lain.bgm.tv/pic/crt/g/79/2a/16493_crt_0dtIk.jpg",
          "name": "艾基尔／安德鲁·基尔博德·密鲁茲",
          "desc": "安元洋貴"
        },
        {
          "id": 16494,
          "image": "//lain.bgm.tv/pic/crt/g/2e/a7/16494_crt_9m1Nq.jpg",
          "name": "莉兹贝特／篠崎里香",
          "desc": "高垣彩陽"
        },
        {
          "id": 16496,
          "image": "//lain.bgm.tv/pic/crt/g/40/9b/16496_crt_un27Q.jpg",
          "name": "西莉卡／绫野圭子",
          "desc": "日高里菜"
        },
        {
          "id": 17646,
          "image": "//lain.bgm.tv/pic/crt/g/24/86/17646_crt_353qM.jpg",
          "name": "莉法／桐谷直叶",
          "desc": "竹達彩奈"
        },
        {
          "id": 17647,
          "image": "//lain.bgm.tv/pic/crt/g/a6/19/17647_crt_x346a.jpg",
          "name": "结衣",
          "desc": "伊藤かな恵"
        }
      ],
      "staff": [
        {
          "id": 7173,
          "image": "//lain.bgm.tv/pic/crt/g/49/26/7173_prsn_EH4fx.jpg",
          "name": "川原砾",
          "desc": "原作"
        },
        {
          "id": 2718,
          "image": "//lain.bgm.tv/pic/crt/g/77/87/2718_prsn_PW2wW.jpg",
          "name": "小野学",
          "desc": "导演"
        },
        {"id": 1183, "image": "", "name": "大冢健", "desc": "分镜"},
        {
          "id": 21139,
          "image": "//lain.bgm.tv/pic/crt/g/21/a4/21139_prsn_6c8Vp.jpg",
          "name": "石井俊匡",
          "desc": "分镜"
        },
        {"id": 12609, "image": "", "name": "川村贤一", "desc": "分镜"},
        {"id": 26587, "image": "", "name": "佐久间贵史", "desc": "分镜"},
        {"id": 12509, "image": "", "name": "菅野芳弘", "desc": "分镜"},
        {
          "id": 13630,
          "image": "//lain.bgm.tv/pic/crt/g/db/3e/13630_prsn_KBUvm.jpg",
          "name": "三浦武弘",
          "desc": "分镜"
        }
      ],
      "relations": [
        {
          "id": 290105,
          "image": "//lain.bgm.tv/pic/cover/m/4a/78/290105_T1NfQ.jpg",
          "title": "ソードアート・オンライン アリシゼーション・ブレイディング",
          "type": "游戏",
          "url": "https://bgm.tv/subject/290105"
        },
        {
          "id": 226432,
          "image": "//lain.bgm.tv/pic/cover/m/e1/91/226432_O89Fp.jpg",
          "title": "ソードアート・オンライン インテグラル・ファクター",
          "type": "游戏",
          "url": "https://bgm.tv/subject/226432"
        },
        {
          "id": 5397,
          "image": "//lain.bgm.tv/pic/cover/m/01/da/5397_S6jRK.jpg",
          "title": "ソードアート・オンライン",
          "type": "书籍",
          "url": "https://bgm.tv/subject/5397"
        },
        {
          "id": 225604,
          "image": "//lain.bgm.tv/pic/cover/m/4a/5d/225604_97yaR.jpg",
          "title": "ソードアート・オンライン アリシゼーション",
          "type": "前传",
          "url": "https://bgm.tv/subject/225604"
        },
        {
          "id": 292238,
          "image": "//lain.bgm.tv/pic/cover/m/21/a1/292238_u43yn.jpg",
          "title": "ソードアート・オンライン アリシゼーション War of Underworld 第2クール",
          "type": "续集",
          "url": "https://bgm.tv/subject/292238"
        },
        {
          "id": 296940,
          "image": "//lain.bgm.tv/pic/cover/m/f3/2e/296940_paqvp.jpg",
          "title": "Meaning the start",
          "type": "角色歌",
          "url": "https://bgm.tv/subject/296940"
        },
        {
          "id": 297450,
          "image": "//lain.bgm.tv/pic/cover/m/82/cb/297450_hY7ir.jpg",
          "title": "Deepening the dark",
          "type": "角色歌",
          "url": "https://bgm.tv/subject/297450"
        },
        {
          "id": 292308,
          "image": "//lain.bgm.tv/pic/cover/m/5e/c8/292308_MdgzV.jpg",
          "title": "Resolution",
          "type": "片头曲",
          "url": "https://bgm.tv/subject/292308"
        },
        {
          "id": 292309,
          "image": "//lain.bgm.tv/pic/cover/m/c7/d0/292309_q11Tz.jpg",
          "title": "unlasting",
          "type": "片尾曲",
          "url": "https://bgm.tv/subject/292309"
        }
      ],
      "_loaded": 1579070435
    },
    {
      "status": {"id": 2, "type": "collect", "name": "看过"},
      "rating": 0,
      "comment": "",
      "private": 0,
      "tag": [""],
      "ep_status": 1,
      "vol_status": 0,
      "lasttouch": 1578716414,
      "user": {
        "id": 487153,
        "url": "http://bgm.tv/user/487153",
        "username": "487153",
        "nickname": "Yuan2323",
        "avatar": {
          "large": "http://lain.bgm.tv/pic/user/l/icon.jpg",
          "medium": "http://lain.bgm.tv/pic/user/m/icon.jpg",
          "small": "http://lain.bgm.tv/pic/user/s/icon.jpg"
        },
        "sign": "",
        "usergroup": 10
      }
    }
  ];
}
