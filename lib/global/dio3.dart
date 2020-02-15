import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'string.dart';
export 'string.dart';

Dio dio = new Dio();
Response response;
String token = '', avatar = '';
var myDio = MyDio();

class MyDio {
  bool get isLogIn => token != '' && token != null;

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.get('access_token');

    dio.options.baseUrl = GlobalVar.apiUrl;
    //解决频繁请求搜索API的问题
    var cj = new CookieJar();
    cj.saveFromResponse(Uri.parse('${GlobalVar.apiUrl}/'), [
      new Cookie("chii_searchDateLine",
          (DateTime.now().millisecondsSinceEpoch / 1000).round().toString()),
    ]);
    dio.interceptors.add(CookieManager(cj));
    //更新token
    dio.interceptors.add(InterceptorsWrapper(onError: (error) {
      switch (error.response.statusCode) {
        case 401:
          // TODO: 401可能是未登录
          refreshToken().then((_) => updateTokenHeaders());
          break;
        default:
          print(error.response.data.toString());
      }
    }));
    updateTokenHeaders();
  }

  Future<void> updateTokenHeaders() async {
    String mes;
    if (MyDio().isLogIn) {
      mes = token;
      Future.delayed(Duration(days: 1), () => checkExpire());
    } else {
      mes = '';
    }

    dio.interceptors.add(InterceptorsWrapper(onRequest: (options) {
      options.headers['Authorization'] = 'Bearer $mes';
    }));
  }

  Future<bool> secondAuth(String code) async {
    var data = {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': GlobalVar.redirectUrl,
      'client_id': GlobalVar.appId,
      'client_secret': GlobalVar.appSecret,
    };
    try {
      response =
          await dio.post('https://bgm.tv/oauth/access_token', data: data);
      print(response.data);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ['access_token', 'refresh_token', 'user_id']
          .forEach((v) => prefs.setString(v, response.data[v].toString()));
      token = response.data['access_token'];
      updateTokenHeaders();
      print('Auth successful');
      return true;
    } on DioError catch (e) {
      secondAuth(code);
      print(e);
    }
    return false;
  }

  Future<void> refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.get('refresh_token');
    var data = {
      'grant_type': 'refresh_token',
      'client_id': GlobalVar.appId,
      'client_secret': GlobalVar.appSecret,
      'refresh_token': _token,
      'redirect_uri': GlobalVar.redirectUrl
    };
    try {
      response =
          await dio.post('https://bgm.tv/oauth/access_token', data: data);
      Map<String, dynamic> res = response.data;
      ['access_token', 'refresh_token']
          .forEach((v) => prefs.setString(v, res[v].toString()));
      token = res['access_token'];
      updateTokenHeaders();
    } catch (e) {
      if (e.response.statusCode == 500) {
        refreshToken();
      }
    }
  }

  Future<void> checkExpire() async {
    response = await dio.post('https://bgm.tv/oauth/token_status',
        queryParameters: {'access_token': token});
    Map<String, dynamic> res = response.data;
    if (DateTime.fromMillisecondsSinceEpoch(res['expires'] * 1000)
        .isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      refreshToken();
      print('Out of date');
    }
    Future.delayed(Duration(days: 1), () => checkExpire());
  }

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ['access_token', 'refresh_token', 'user_id']
        .forEach((v) => prefs.remove(v));
    token = '';
    print('log out');
    print('${myDio.isLogIn}  token$token');
  }
}
