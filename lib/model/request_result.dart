class RequestResult {
  bool success;
  dynamic data;
  String msg;

  RequestResult({this.success = false, this.data, this.msg = ""});
}
