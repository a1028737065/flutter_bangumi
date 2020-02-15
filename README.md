# bangumi客户端

使用Flutter制作的第三方bangumi客户端。

## 功能
- 查看收藏
- 查看每日放送
- 搜索
- 查看条目详情

### 未实现
- 更新收藏状态（评分、标签、吐槽）

## 测试
1. 安装Flutter。
2. clone最新分支到本地。
3. 在lib/glbal/string.dart中填入自己申请的 `App Id` 和 `App Secret`，以及 `回调地址`。
4. 在根目录执行 `flutter run` 或 执行 `flutter build apk` 打包为apk文件。

## 使用到的其他开发者的项目
1. bangumi[官方Api](https://github.com/bangumi/api)
2. [Bangumi-Subject](https://github.com/czy0729/Bangumi-Subject) By [czy0729](https://github.com/czy0729)，提供了热门条目静态数据。