
class AWCouponModel {

  ///实验任务 ID
  late int taskId;
  ///实验组或测试组 ID
  String? ABTestCode;
  ///券下发时间(unix 时间戳)
  late int distributeTime;
  ///券有效期， e.g:   3：表示有效期为3天
  late int validTerm;
  ///用户弹窗记录状态：unknown: 0, notMatch: 1, matched: 2 popupSuccess: 3
  late int userPopupStatus;

  static AWCouponModel fromJson(Map<String, dynamic> json) {
    final model = AWCouponModel();
    model.taskId = json["taskID"];
    model.ABTestCode = json["ABTestCode"];
    model.distributeTime = json["distributeTime"];
    model.validTerm = json["validTerm"];
    model.userPopupStatus = json["userPopupStatus"];
    return model;
  }

  @override
  String toString() {
    return 'AwCouponModel{taskId: $taskId, ABTestCode: ${ABTestCode??""}, distributeTime: $distributeTime, validTerm: $validTerm, userPopupStatus: $userPopupStatus}';
  }
}