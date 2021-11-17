class AWResponseModel<T>{
  T? data;
  late bool result;
  String? msg;

  AWResponseModel.sendSuccess(T t):result = true,data = t;
  AWResponseModel.sendFailed(String? errorMsg):result = false,msg = errorMsg;

}