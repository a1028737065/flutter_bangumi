import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'string.dart';
export 'package:dio/dio.dart';
export 'string.dart';

Dio dio = Dio();
Response response;
String token = '';
var myDio = MyDio();

class MyDio {
  bool get isLogIn => token != '' && token != null;

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.get('access_token');
    print('get local token $token');

    dio.options.baseUrl = GlobalVar.apiUrl;

    //解决频繁请求搜索API的问题
    var cj = CookieJar();
    cj.saveFromResponse(Uri.parse('${GlobalVar.apiUrl}/'), [
      Cookie("chii_searchDateLine",
          (DateTime.now().millisecondsSinceEpoch / 1000).round().toString()),
    ]);
    dio.interceptors.add(CookieManager(cj));

    //更新token
    dio.interceptors.add(InterceptorsWrapper(onError: (error) {
      switch (error.response.statusCode) {
        case 401:
          if (error.response.statusMessage == "Unauthorized" && '' != token) {
            token = '';
            BotToast.showText(text: '登录信息已过期');
          } else if (error.response.statusMessage == "Unauthorized" &&
              '' == token) {
            BotToast.showText(text: '尚未登录');
          } else {
            refreshToken().then((_) => updateTokenHeaders());
          }
          break;
        default:
          print(error.response.data.toString());
      }
    }));

    //检查token是否过期
    if ('' != token) {
      checkExpire().then((_) => updateTokenHeaders());
    }
  }

  Future<void> updateTokenHeaders() async {
    String mes;
    if (myDio.isLogIn) {
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

      for (var v in ['access_token', 'refresh_token', 'user_id']) {
        prefs.setString(v, response.data[v].toString());
      }
      token = response.data['access_token'];
      prefs.setString(
          'expire', DateTime.now().add(Duration(days: 7)).toString());
      updateTokenHeaders();
      print('Auth successful');
      return true;
    } catch (e) {
      if (e.response.statusCode == 500) {
        secondAuth(code);
      }
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
      dio.lock();
      response =
          await dio.post('https://bgm.tv/oauth/access_token', data: data);
      Map<String, dynamic> res = response.data;
      for (var v in ['access_token', 'refresh_token']) {
        prefs.setString(v, res[v].toString());
      }
      token = res['access_token'];
      prefs.setString(
          'expire', DateTime.now().add(Duration(days: 7)).toString());
      updateTokenHeaders();
      dio.unlock();
    } catch (e) {
      print(e.response.statusCode.toString());
      if (e.response.statusCode == 500) {
        refreshToken();
      }
    }
  }

  Future<void> checkExpire() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _expireString = prefs.get('expire');
    DateTime _expire = DateTime.parse(
        null == _expireString ? '1970-01-01 00:00:01' : _expireString);
    if (_expire.isBefore(DateTime.now())) {
      token = '';
      print('Out of date');
    } else if (_expire.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      refreshToken();
    }
  }

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var v in ['access_token', 'refresh_token', 'user_id', 'expire']) {
      prefs.remove(v);
    }
    token = '';
    print('log out');
    print('${myDio.isLogIn}  token$token');
  }
}
