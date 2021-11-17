
/// 解析sdk给的数据
class AWParseNativeModel {
  final bool result;
  final dynamic data;
  final String msg;

  AWParseNativeModel(this.result, this.data, this.msg);

  AWParseNativeModel.fromJson(Map<String, dynamic> json)
      : result = json["result"],
        data = json["data"],
        msg = json["msg"];
}
