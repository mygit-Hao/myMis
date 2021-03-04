import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/model/sample_selection.dart';
import 'package:mis_app/utils/utils.dart';

class SampleDeliveryDetailModel {
  static int _maxId = 0;

  static const int sampleDeliveryDetailStatusPending = 0;
  static const int sampleDeliveryDetailStatusPendingQcReply = 12;
  static const int sampleDeliveryDetailStatusPendingConfirm = 15;
  static const int sampleDeliveryDetailStatusPendingFeedback = 18;
  static const int sampleDeliveryDetailStatusFinished = 20;

  static const int qcReplyStatusPending = 0;
  static const int qcReplyStatusRecommend = 1;
  static const int qcReplyStatusDelivery = 2;
  static const int qcReplyStatusUndelivery = 3;

  static const int handleStatusPending = 0;
  static const int handleStatusRefuse = 1;
  static const int handleStatusAccept = 2;
  static const int handleStatusCustRefuse = 3;
  static const int handleStatusCustAccept = 4;

  static const List<String> qtyList = [
    "50克",
    "300克",
    "500克",
    "1公斤",
    "3公斤",
    "6公斤",
    "15公斤"
  ];

  int sampleDeliveryDtlId;
  int sampleDeliveryId;
  String itemDesc;
  bool isNewSample;
  String item1;
  String item2;
  String ot1;
  String ot2;
  String ot3;
  String ot4;
  String ot5;
  String ot6;
  String ot7;
  String ot8;
  String ot9;
  String ot10;
  String operationTech;
  String specialReq;
  String predictDemand;
  bool custProvideSample;
  int qtyId;
  String qtyDesc;
  int status;
  int qCReplyStatus;
  String qCRecommendItemId;
  String qCRecommendItemName;
  String qCDeliveryDate;
  String qCReplyRemarks;
  int handleStatus;
  String handleRemarks;
  int versionId;
  String statusName;
  int seqNo;
  String deliveryItemDesc;
  int qCReplyStatus1;
  bool acceptQCReply;
  DateTime qCPlanDate;

  bool get canEndDelivery {
    bool result;
    if (isConfirming) {
      result = qCReplyStatus == qcReplyStatusUndelivery;
    } else {
      result = true;
    }

    return result;
  }

  bool get deliveryItemIsDifferent {
    return (!Utils.textIsEmpty(deliveryItemDesc)) &&
        (!Utils.sameText(deliveryItemDesc, itemDesc));
  }

  bool get canHandle {
    return (this.status == sampleDeliveryDetailStatusPendingConfirm) ||
        (this.status == sampleDeliveryDetailStatusPendingFeedback);
  }

  bool get isConfirming {
    return this.status == sampleDeliveryDetailStatusPendingConfirm;
  }

  String get qCReplyDetail {
    String status = "";
    if (this.status == sampleDeliveryDetailStatusPendingConfirm) {
      if (this.qCReplyStatus == qcReplyStatusRecommend) {
        status = "建议使用产品“$qCRecommendItemName”";
      } else if (this.qCReplyStatus == qcReplyStatusUndelivery) {
        status = "不送样";
      }
    } else if (this.status == sampleDeliveryDetailStatusPendingFeedback) {
      if (this.qCPlanDate != null) {
        status = "${Utils.dateTimeToStr(qCPlanDate)}已接单";
      }
    }

    if ((!Utils.textIsEmpty(status)) && (!Utils.textIsEmpty(qCReplyRemarks))) {
      return "$status, $qCReplyRemarks";
    }

    return "$status$qCReplyRemarks";
  }

  String get statusDesc {
    switch (this.status) {
      case sampleDeliveryDetailStatusPending:
        return "待QC回复";
      case sampleDeliveryDetailStatusPendingQcReply:
        String status = "";

        if ((this.qCReplyStatus == qcReplyStatusRecommend) ||
            (this.qCReplyStatus == qcReplyStatusUndelivery)) {
          if (this.acceptQCReply) {
            status = "接受";
          } else {
            status = "不接受";
          }
        }

        if (Utils.textIsEmpty(status)) return "待QC回复";

        return "$status, 待QC回复";
      case sampleDeliveryDetailStatusPendingConfirm:
        return "待确认: $qCReplyDetail";
      case sampleDeliveryDetailStatusPendingFeedback:
        return "待反馈: $qCReplyDetail";
      case sampleDeliveryDetailStatusFinished:
        return "已完成";
      default:
        return "";
    }
  }

  String get preStatusDesc {
    if (this.status == sampleDeliveryDetailStatusPendingQcReply) {
      String status = "";

      if (this.qCReplyStatus == qcReplyStatusRecommend) {
        status = "建议使用产品“$qCRecommendItemName”";
      } else if (this.qCReplyStatus == qcReplyStatusUndelivery) {
        status = "不送样";
      }

      if (!Utils.textIsEmpty(status)) {
        if (!Utils.textIsEmpty(qCReplyRemarks)) {
          status = "$status, $qCReplyRemarks";
        }
        return "QC回复：$status";
      }
    }

    return "";
  }

  void setQtyDesc(desc) {
    this.qtyDesc = desc;
    this.qtyId = SampleDeliveryDetailModel.qtyList.indexOf(this.qtyDesc);
  }

  bool get needPolish {
    return Utils.strToBool(ot10);
  }

  static bool prodNeedPolish(String prodName) {
    List<SampleSelectionModel> selectionList = DataCache.sampleSelectionList;

    if (selectionList != null) {
      for (SampleSelectionModel item in selectionList) {
        if (item.selectionValue == prodName) {
          return item.extraInfo == 'shoe';
        }
      }
    }
    return false;
  }

  String get otdesc1 {
    return isNewSample ? "" : '${item1 ?? ""}/${item2 ?? ""}';
  }

  String get otdesc2 {
    if (needPolish) {
      return '面料: ${Utils.strToBool(ot2) ? "打磨" : "不用打磨"}, $ot3';
    } else {
      return "";
    }
  }

  String get otdesc3 {
    if (needPolish) {
      return '底料: ${Utils.strToBool(ot4) ? "打磨" : "不用打磨"}, $ot5';
    } else {
      return "";
    }
  }

  String get otdesc4 {
    return '$ot6, $ot7, 干燥$ot8分钟，加压$ot9分钟';
  }

  SampleDeliveryDetailModel(
      {this.sampleDeliveryDtlId = 0,
      this.sampleDeliveryId = 0,
      this.itemDesc,
      this.isNewSample = false,
      this.item1 = '',
      this.item2 = '',
      this.ot1 = '',
      this.ot2 = '',
      this.ot3 = '',
      this.ot4 = '',
      this.ot5 = '',
      this.ot6 = '',
      this.ot7 = '',
      this.ot8 = '',
      this.ot9 = '',
      this.ot10 = '',
      this.operationTech,
      this.specialReq,
      this.predictDemand,
      this.custProvideSample = false,
      this.qtyId,
      this.qtyDesc,
      this.status,
      this.qCReplyStatus,
      this.qCRecommendItemId,
      this.qCRecommendItemName,
      this.qCDeliveryDate,
      this.qCReplyRemarks,
      this.handleStatus,
      this.handleRemarks,
      this.versionId,
      this.statusName,
      this.seqNo = 0,
      this.deliveryItemDesc,
      this.qCReplyStatus1,
      this.acceptQCReply = false,
      this.qCPlanDate}) {
    _maxId--;
    this.sampleDeliveryDtlId = _maxId;
    this.seqNo = 0;
  }

  SampleDeliveryDetailModel.fromJson(Map<String, dynamic> json) {
    sampleDeliveryDtlId = json['SampleDeliveryDtlId'];
    sampleDeliveryId = json['SampleDeliveryId'];
    itemDesc = json['ItemDesc'];
    isNewSample = json['IsNewSample'];
    item1 = json['Item1'];
    item2 = json['Item2'];
    ot1 = json['Ot1'];
    ot2 = json['Ot2'];
    ot3 = json['Ot3'];
    ot4 = json['Ot4'];
    ot5 = json['Ot5'];
    ot6 = json['Ot6'];
    ot7 = json['Ot7'];
    ot8 = json['Ot8'];
    ot9 = json['Ot9'];
    ot10 = json['Ot10'];
    operationTech = json['OperationTech'];
    specialReq = json['SpecialReq'];
    predictDemand = json['PredictDemand'];
    custProvideSample = json['CustProvideSample'];
    qtyId = json['QtyId'];
    qtyDesc = json['QtyDesc'];
    status = json['Status'];
    qCReplyStatus = json['QCReplyStatus'];
    qCRecommendItemId = json['QCRecommendItemId'];
    qCRecommendItemName = json['QCRecommendItemName'];
    qCDeliveryDate = json['QCDeliveryDate'];
    qCReplyRemarks = json['QCReplyRemarks'];
    handleStatus = json['HandleStatus'];
    handleRemarks = json['HandleRemarks'];
    versionId = json['VersionId'];
    statusName = json['StatusName'];
    seqNo = json['SeqNo'];
    deliveryItemDesc = json['DeliveryItemDesc'];
    qCReplyStatus1 = json['QCReplyStatus1'];
    acceptQCReply = json['AcceptQCReply'] ?? false;
    if (json['QCPlanDate'] != null)
      qCPlanDate = DateTime.parse(json['QCPlanDate']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SampleDeliveryDtlId'] = this.sampleDeliveryDtlId;
    data['SampleDeliveryId'] = this.sampleDeliveryId;
    data['ItemDesc'] = this.itemDesc;
    data['IsNewSample'] = this.isNewSample;
    // 由于服务端是按Java序列化的数据处理，Java把“IsNewSample”字段变成“newSample”
    // 如果直接把序列化后的数据传递给服务端，会导致丢失“IsNewSample”的数据
    // 因此在Dart中补上字段“NewSample”，用来保存“IsNewSample”数据
    data['NewSample'] = this.isNewSample;
    data['Item1'] = this.item1;
    data['Item2'] = this.item2;
    data['Ot1'] = this.ot1;
    data['Ot2'] = this.ot2;
    data['Ot3'] = this.ot3;
    data['Ot4'] = this.ot4;
    data['Ot5'] = this.ot5;
    data['Ot6'] = this.ot6;
    data['Ot7'] = this.ot7;
    data['Ot8'] = this.ot8;
    data['Ot9'] = this.ot9;
    data['Ot10'] = this.ot10;
    data['OperationTech'] = this.operationTech;
    data['SpecialReq'] = this.specialReq;
    data['PredictDemand'] = this.predictDemand;
    data['CustProvideSample'] = this.custProvideSample;
    data['QtyId'] = this.qtyId;
    data['QtyDesc'] = this.qtyDesc;
    data['Status'] = this.status;
    data['QCReplyStatus'] = this.qCReplyStatus;
    data['QCRecommendItemId'] = this.qCRecommendItemId;
    data['QCRecommendItemName'] = this.qCRecommendItemName;
    data['QCDeliveryDate'] = this.qCDeliveryDate;
    data['QCReplyRemarks'] = this.qCReplyRemarks;
    data['HandleStatus'] = this.handleStatus;
    data['HandleRemarks'] = this.handleRemarks;
    data['VersionId'] = this.versionId;
    data['StatusName'] = this.statusName;
    data['SeqNo'] = this.seqNo;
    data['DeliveryItemDesc'] = this.deliveryItemDesc;
    data['QCReplyStatus1'] = this.qCReplyStatus1;
    data['AcceptQCReply'] = this.acceptQCReply;
    data['QCPlanDate'] =
        this.qCPlanDate == null ? null : this.qCPlanDate.toIso8601String();
    return data;
  }
}
