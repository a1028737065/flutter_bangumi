class GlobalVar {
  static final String appId = '';
  static final String appSecret = '';
  static final String apiUrl = 'https://api.bgm.tv';
  static final String redirectUrl = 'https://book.yuan2323.xyz';
  
  static final Map<String, String> collectionStatusType2CN = {
    'wish': '想看',
    'collect': '看过',
    'doing': '在看',
    'on_hold': '搁置',
    'dropped': '抛弃'
  };

  String getRating(int score) {
    if (score >= 9.5) return '超神作';
    if (score >= 8.5) return '神作';
    if (score >= 7.5) return '力荐';
    if (score >= 6.5) return '推荐';
    if (score >= 5.5) return '还行';
    if (score >= 4.5) return '不过不失';
    if (score >= 3.5) return '较差';
    if (score >= 2.5) return '差';
    if (score >= 1.5) return '很差';
    return '不忍直视';
  }
}
