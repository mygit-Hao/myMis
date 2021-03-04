import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/approval.dart';
import 'package:mis_app/model/approval_audit_remarks.dart';
import 'package:mis_app/model/approval_head.dart';
import 'package:mis_app/model/approval_invite_result.dart';
import 'package:mis_app/model/approval_message.dart';
import 'package:mis_app/model/approval_message_result.dart';
import 'package:mis_app/model/approval_next.dart';
import 'package:mis_app/model/approval_result.dart';
import 'package:mis_app/model/attachment.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/service/service_method.dart';

class ApprovalService {
  /// 审批通过
  static const int approvalHandleSign = 1;

  /// 否决
  static const int approvalHandleDeny = 2;

  /// 审核
  static const int approvalHandleAccounting = 3;

  /// 否决确认
  static const int approvalHandleSignCancel = 4;

  /// 反审
  static const int approvalHandleSignUndo = 5;

  static List<int> _approvaledDayValues = [3, 7, 10, 30];
  // static List<String> approvaledDaysItems = [];
  static List<String> approvaledDaysItems =
      _approvaledDayValues.map((v) => '$v天').toList();

  static int currentApprovaledDaysIndex = -1;

  static Future<List<ApprovalHeadModel>> getHeads(
      List<ApprovalHeadModel> approvalList) async {
    List<ApprovalHeadModel> list = List();

    Map<String, dynamic> map = {
      'action': 'heads',
      'list': json.encode(approvalList),
    };

    FormData formData = FormData.fromMap(map);

    await request(serviceUrl[approvalUrl], data: formData).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        if (responseData['ErrCode'] == 0) {
          // DateTime cacheTime = DateTime.now();
          DateTime expiryTime = ApprovalHeadModel.getNextExpiryTime();
          responseData['Data'].forEach((v) {
            ApprovalHeadModel item = new ApprovalHeadModel.fromJson(v);
            // item.cacheTime = cacheTime;
            item.expiryTime = expiryTime;
            list.add(item);
          });
        }
      },
    );

    return list;
  }

  static Future<List<AttachmentModel>> getAttachments(
      String docType, String docId) async {
    List<AttachmentModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'attachment',
      'doctype': docType,
      'hid': docId,
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new AttachmentModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<ApprovalMessageResultModel> addMessage(
      int msgType, String msg) async {
    ApprovalMessageResultModel result;

    Map<String, dynamic> queryParameters = {
      'action': 'add-message',
      'type': msgType,
      'message': msg,
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ApprovalMessageResultModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<ApprovalMessageResultModel> updateMessage(
      ApprovalMessageModel item, String newMessage) async {
    ApprovalMessageResultModel result;

    Map<String, dynamic> queryParameters = {
      'action': 'update-message',
      'id': item.messageId,
      'message': newMessage,
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ApprovalMessageResultModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<Map<String, dynamic>> removeMessage(int messageId) async {
    Map<String, dynamic> result;

    Map<String, dynamic> queryParameters = {
      'action': 'remove-message',
      'id': messageId,
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        result = json.decode(value.data.toString());
      },
    );

    return result;
  }

  static Future<Map<String, dynamic>> useMessages(List<int> list) async {
    Map<String, dynamic> result;

    Map<String, dynamic> queryParameters = {
      'action': 'use-message',
      'ids': json.encode(list),
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        result = json.decode(value.data.toString());
      },
    );

    return result;
  }

  static Future<List<ApprovalMessageModel>> getMessageList() async {
    List<ApprovalMessageModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'get-message',
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new ApprovalMessageModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<List<ApprovalAuditRemarksModel>> getAuditRemarks(
      String docType, String docId) async {
    List<ApprovalAuditRemarksModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'auditremarks',
      'doctype': docType,
      'hid': docId,
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new ApprovalAuditRemarksModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static int getApprovaledDaysIndex() {
    // currentApprovaledDaysIndex 为 -1 时，表示未读取配置信息
    if (currentApprovaledDaysIndex == -1) {
      String s = Prefs.getApprovaledDaysIndex();
      int index;

      if (s != null) {
        index = int.tryParse(s);
      }
      if (index == null) {
        index = 0;
      }

      currentApprovaledDaysIndex = index;
    }

    return currentApprovaledDaysIndex;
  }

  static String getApprovaledDays() {
    int index = getApprovaledDaysIndex();

    return approvaledDaysItems[index];
  }

  static int getApprovaledDaysValue() {
    int index = getApprovaledDaysIndex();

    return _approvaledDayValues[index];
  }

  static void setApprovaledDaysIndex(int index) {
    if (index != currentApprovaledDaysIndex) {
      currentApprovaledDaysIndex = index;
      Prefs.setApprovaledDaysIndex(currentApprovaledDaysIndex);
    }
  }

  /*
  static void initApprovaledDaysItems() {
    if (approvaledDaysItems.isEmpty) {
      approvaledDaysItems = List();
      _approvaledDayValues.forEach((v) {
        approvaledDaysItems.add('$v天');
      });
    }
  }
  */

  static Future<ApprovalInviteResultModel> invite(
      String docType, String docId, String userId) async {
    ApprovalInviteResultModel result;

    Map<String, dynamic> queryParameters = {
      'action': 'addauditstatus',
      'doctype': docType,
      'hid': docId,
      'userid2': userId,
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ApprovalInviteResultModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<ApprovalNextModel> getNext(
      String nextDocType, String nextDocId) async {
    ApprovalNextModel result;

    Map<String, dynamic> queryParameters = {
      'action': 'getnext',
      'next_doctype': nextDocType,
      'next_hid': nextDocId,
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ApprovalNextModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<ApprovalResultModel> approval(
      int approvalHandle, String docType, String docId, String remarks,
      {String nextDocType = '', String nextDocId = ''}) async {
    ApprovalResultModel result;

    Map<String, dynamic> queryParameters = {
      'action': 'approval',
      'handle': approvalHandle,
      'doctype': docType,
      'hid': docId,
      'remarks': remarks,
      'next_doctype': nextDocType,
      'next_hid': nextDocId
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ApprovalResultModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<ApprovalHeadModel> getHead(String docType, String docId) async {
    // 先检查是否有未过期的缓存
    ApprovalHeadModel head = DataCache.findApprovalHeadCache(docType, docId);

    if ((head == null) || (head.isExpired)) {
      Map<String, dynamic> queryParameters = {
        'action': 'head',
        'doctype': docType,
        'hid': docId,
      };

      await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
          .then(
        (RequestResult value) {
          var responseData = json.decode(value.data.toString());

          if (responseData == null) return;

          head = ApprovalHeadModel.fromJson(responseData);
          head.updateExpiryTime();
          if (head.isValid) {
            DataCache.updateApprovalHeadCache(head);

            // 如果有过期的或不存在的，批量刷新缓存
            DataCache.prepareApprovalHeadCache();
          }
        },
      );
    }

    return head;
  }

  static Future<List<ApprovalModel>> getPending() async {
    List<ApprovalModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'pending',
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        // print(responseData.runtimeType);

        if (responseData == null) return;

        responseData.forEach((v) {
          // print(v.runtimeType);
          list.add(new ApprovalModel.fromJson(v));
        });

        // print(list);
      },
    );

    return list;
  }

  static Future<List<ApprovalModel>> getApprovaled(int days) async {
    List<ApprovalModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'approvaled',
      'days': days,
    };

    await request(serviceUrl[approvalUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        // print(responseData.runtimeType);

        if (responseData == null) return;

        responseData.forEach((v) {
          // print(v.runtimeType);
          list.add(new ApprovalModel.fromJson(v));
        });

        // print(list);
      },
    );

    return list;
  }

  static String getApprovalDataUrl(String docType, String docId) {
    return '${serviceUrl[approvalHandleUrl]}?doctype=${docType.trim()}&hid=${docId.trim()}';
  }
}
