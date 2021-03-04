import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/arrearage.dart';
import 'package:mis_app/model/arrearage_detail.dart';
import 'package:mis_app/model/bill.dart';
import 'package:mis_app/model/bill_detail.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/cust_unlock_request.dart';
import 'package:mis_app/model/inventory.dart';
import 'package:mis_app/model/item_category.dart';
import 'package:mis_app/model/receipt_detail.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/sales_cart.dart';
import 'package:mis_app/model/sales_invoice.dart';
import 'package:mis_app/model/sales_price.dart';
import 'package:mis_app/model/sales_receipt_bonus.dart';
import 'package:mis_app/model/sales_summary.dart';
import 'package:mis_app/model/sales_summary_detail.dart';
import 'package:mis_app/model/salesman.dart';
import 'package:mis_app/model/sales_bonus.dart';
import 'package:mis_app/model/sample_delivery.dart';
import 'package:mis_app/model/sample_delivery_detail.dart';
import 'package:mis_app/model/sample_delivery_log.dart';
import 'package:mis_app/model/sample_item.dart';
import 'package:mis_app/model/sample_selection.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class SalesService {
  static const int dateOptionWithOneWeek = 1;
  static const int dateOptionWithOneMonth = 2;
  static const int dateOptionAll = -1;

  static String _custStatementFilePath;
  static String _custStatementPdfFilePath;

  static String get custStatementFilePath {
    if (_custStatementFilePath == null) {
      _custStatementFilePath = '${Global.documentsDir}/statement.png';
    }

    return _custStatementFilePath;
  }

  static String get custStatementPdfFilePath {
    if (_custStatementPdfFilePath == null) {
      _custStatementPdfFilePath = '${Global.documentsDir}/对账单.pdf';
    }

    return _custStatementPdfFilePath;
  }

  static Future<bool> downloadCustStatement(int custId, DateTime startDate,
      DateTime endDate, bool showPreviousData, bool toPdf) async {
    bool success = false;

    String url = serviceUrl[salesUrl];

    Map<String, dynamic> queryParameters = {
      'action': 'cust-samt-report',
      'cust-id': custId,
      'date-from': startDate,
      'date-to': endDate,
      'show-previous-data': showPreviousData,
      'file-type': toPdf ? 'pdf' : ''
    };

    String path = toPdf ? custStatementPdfFilePath : custStatementFilePath;

    await downloadFile(url, path, queryParameters: queryParameters).then(
      (RequestResult value) {
        success = true;
      },
    );

    return success;
  }

  static Future<List<SampleDeliveryLogModel>> getSampleDeliveryLog(
      int sampleDeliveryDetailId) async {
    List<SampleDeliveryLogModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'get_sample_log',
      'sampledeliverydtlid': sampleDeliveryDetailId,
    };

    await request(serviceUrl[sampleDeliveryUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(SampleDeliveryLogModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<RequestResult> updateSampleDeliveryDetailReply(
      int sampleDeliveryDetailId,
      int handleStatus,
      String custFeedback,
      bool endDelivery,
      String remarks) async {
    RequestResult result = RequestResult(success: false);

    Map<String, dynamic> queryParameters = {
      'action': 'update_sample_deliverydtl_reply',
      'sampleDeliverydtlid': sampleDeliveryDetailId,
      'custfeedback': custFeedback,
      'enddelivery': Utils.boolToString(endDelivery),
      'remarks': remarks
    };

    await request(serviceUrl[sampleDeliveryUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        String responseData = value.data.toString();

        if (responseData == requestSuccess) {
          result.success = true;
        } else {
          result.msg = responseData;
        }
      },
    );

    return result;
  }

  static Future<List<SalesReceiptBonusModel>> getSalesReceiptBonus(
      int custId, double amount) async {
    List<SalesReceiptBonusModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'get-sales-receipt-bonus',
      'custid': custId,
      'amount': amount,
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(SalesReceiptBonusModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<List<ReceiptDetailModel>> getSalesInvoiceReceiptDetail(
      DateTime startDate, DateTime endDate, int salesInvoiceId) async {
    List<ReceiptDetailModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'get-sales-invoice-receipt-dtl',
      'date-from': startDate,
      'date-to': endDate,
      'sales-invoiceid': salesInvoiceId,
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(ReceiptDetailModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<SalesBonusListWrapper> getSalesBonusList(
      int month, int salesmanId) async {
    SalesBonusListWrapper result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'get-salesman-bonus-list',
      'month': month,
      'salesmanid': salesmanId
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = SalesBonusListWrapper.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<RequestResult> cancelSampleDelivery(
      int sampleDeliveryId) async {
    RequestResult result = RequestResult(success: false);

    Map<String, dynamic> queryParameters = {
      'action': 'cancelsampledelivery',
      'sampleDeliveryId': sampleDeliveryId
    };

    await request(serviceUrl[sampleDeliveryUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        String responseData = value.data.toString();

        if (responseData == requestSuccess) {
          result.success = true;
        } else {
          result.msg = responseData;
        }
      },
    );

    return result;
  }

  static Future<SampleDeliveryWrapper> toDraftSampleDelivery(
      int sampleDeliveryId) async {
    SampleDeliveryWrapper result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'todraftsampledelivery-v2',
      'sampleDeliveryId': sampleDeliveryId
    };

    await request(serviceUrl[sampleDeliveryUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = SampleDeliveryWrapper.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<List<SampleItemModel>> getSampleItem(String keyword) async {
    List<SampleItemModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'getsampleitem',
      'keyword': keyword,
    };

    await request(serviceUrl[sampleDeliveryUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(SampleItemModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<List<SampleSelectionModel>> getSampleSelectionList() async {
    List<SampleSelectionModel> list = List();

    Map<String, dynamic> queryParameters = {'action': 'getselection'};

    await request(serviceUrl[sampleDeliveryUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new SampleSelectionModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static void buildSampleSelectionList(
      List<String> list, String selectionKind, bool includeOther) {
    List<SampleSelectionModel> selectionList = DataCache.sampleSelectionList;

    selectionList.forEach((SampleSelectionModel element) {
      if (element.selectionKind == selectionKind) {
        list.add(element.selectionValue);
      }
    });
    if (includeOther) {
      list.add('其他');
    }
  }

  static Future<SampleDeliveryWrapper> updateSampleDelivery(
      SampleDeliveryModel sampleDelivery,
      List<SampleDeliveryDetailModel> detailList,
      List<int> deletedList,
      bool toSubmit) async {
    SampleDeliveryWrapper result;
    String deliveryJson = json.encode(sampleDelivery.toJson());
    String deliveryDtlJson = json.encode(detailList);
    String deletedDtlJson = json.encode(deletedList);

    Map<String, dynamic> map;
    map = {
      'action': 'updatesampledelivery',
      'delivery': deliveryJson,
      'deliverydtl': deliveryDtlJson,
      'deleteddtl': deletedDtlJson,
      'option': toSubmit ? 'submit' : '',
    };

    FormData formData = FormData.fromMap(map);

    await request(serviceUrl[sampleDeliveryUrl], data: formData).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = SampleDeliveryWrapper.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<SampleDeliveryWrapper> addSampleDelivery(
      SampleDeliveryModel sampleDelivery,
      List<SampleDeliveryDetailModel> detailList,
      bool toSubmit) async {
    SampleDeliveryWrapper result;
    String deliveryJson = json.encode(sampleDelivery.toJson());
    String deliveryDtlJson = json.encode(detailList);

    Map<String, dynamic> map;
    map = {
      'action': 'addsampledelivery',
      'delivery': deliveryJson,
      'deliverydtl': deliveryDtlJson,
      'option': toSubmit ? 'submit' : '',
    };
    FormData formData = FormData.fromMap(map);

    await request(serviceUrl[sampleDeliveryUrl], data: formData).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = SampleDeliveryWrapper.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<SampleDeliveryWrapper> getSampleDelivery(
      int sampleDeliveryId) async {
    SampleDeliveryWrapper result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'getsampledelivery',
      'sampledeliveryid': sampleDeliveryId
    };

    await request(serviceUrl[sampleDeliveryUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = SampleDeliveryWrapper.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<SampleDeliveryListWrapper> getSampleDeliveryList(
      int custId, String keyword) async {
    SampleDeliveryListWrapper result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'getsampledeliverylist',
      'custid': custId,
      'keyword': keyword,
    };

    await request(serviceUrl[sampleDeliveryUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = SampleDeliveryListWrapper.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<List<SalesInvoiceModel>> getSalesInvoiceForDi(
      int custId, String month) async {
    List<SalesInvoiceModel> salesInvoiceList = List();

    Map<String, dynamic> queryParameters = {
      'action': 'get-si-for-di',
      'custid': custId,
      'month': month,
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          List list = responseData['List'];
          if (list != null) {
            list.forEach((v) {
              salesInvoiceList.add(new SalesInvoiceModel.fromJson(v));
            });
          }
        }
      },
    );

    return salesInvoiceList;
  }

  static Future<ArrearageDetailModel> invoiceByDate(
      int custId, DateTime date, String remarks) async {
    ArrearageDetailModel result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'request-di-by-date',
      'custid': custId,
      'date': date,
      'remarks': remarks,
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ArrearageDetailModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<ArrearageDetailModel> invoiceByMonth(
      int custId, String month, String remarks) async {
    ArrearageDetailModel result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'request-di-by-month',
      'custid': custId,
      'month': month,
      'remarks': remarks,
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ArrearageDetailModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<ArrearageDetailModel> cancelDeliveryInvoice(
      int custId, String month) async {
    ArrearageDetailModel result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'cancel-delivery-invoice',
      'custid': custId,
      'month': month
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ArrearageDetailModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<ArrearageDetailModel> getArrearageDetail(int custId) async {
    ArrearageDetailModel result;

    Map<String, dynamic> queryParameters;
    if ((custId != null) && (custId > 0)) {
      queryParameters = {
        'action': 'arrearagedetail',
        'custid': custId,
      };
    }

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = ArrearageDetailModel.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<List<ArrearageModel>> getArrearageBySalesman(
      int salesmanId, int startIndex) async {
    List<ArrearageModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'arrearagebypage',
      'salesmanid': salesmanId,
      'startindex': startIndex,
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new ArrearageModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<int> getArreageCountBySalesman(int salesmanId) async {
    int count;

    Map<String, dynamic> queryParameters = {
      'action': 'arrearagecount',
      'salesmanid': salesmanId,
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          count = responseData['Count'];
        }
      },
    );

    return count;
  }

  static Future<List<SalesSummaryDetailModel>> getSalesSummaryDetail(
      int custId, DateTime startDate, DateTime endDate, int startIndex) async {
    List<SalesSummaryDetailModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'salessearchdetail',
      'custid': custId,
      'datefrom': startDate,
      'dateto': endDate,
      'startindex': startIndex,
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new SalesSummaryDetailModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<Map<String, dynamic>> getSalesSummaryDetailTotal(
      int custId, DateTime startDate, DateTime endDate) async {
    Map<String, dynamic> result;

    Map<String, dynamic> queryParameters = {
      'action': 'salessearchdetailcount',
      'custid': custId,
      'datefrom': startDate,
      'dateto': endDate,
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        result = json.decode(value.data.toString());
      },
    );

    return result;
  }

  static Future<List<SalesSummaryModel>> getSalesSummary(
      int custId,
      DateTime startDate,
      DateTime endDate,
      int salesmanId,
      int startIndex) async {
    List<SalesSummaryModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'salessearchlist',
      'custid': custId,
      'datefrom': startDate,
      'dateto': endDate,
      'salesmanid': salesmanId,
      'startindex': startIndex,
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new SalesSummaryModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<Map<String, dynamic>> getSalesSummaryTotal(
      int custId, DateTime startDate, DateTime endDate, int salesmanId) async {
    Map<String, dynamic> result;

    Map<String, dynamic> queryParameters = {
      'action': 'salessearchcount',
      'custid': custId,
      'datefrom': startDate,
      'dateto': endDate,
      'salesmanid': salesmanId
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        result = json.decode(value.data.toString());
      },
    );

    return result;
  }

  static Future<RequestResult> reorder(int billType, String billId) async {
    RequestResult result = RequestResult(success: false);

    Map<String, dynamic> queryParameters = {
      'action': 'reorder',
      'billtype': billType,
      'billid': billId
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        String responseData = value.data.toString();

        if (responseData == requestSuccess) {
          result.success = true;
        } else {
          result.msg = responseData;
        }
      },
    );

    return result;
  }

  static Future<Map<String, dynamic>> getBillDetail(
      int billType, String billId) async {
    Map<String, dynamic> result = Map();

    Map<String, dynamic> queryParameters = {
      'action': 'getdetail',
      'billtype': billType,
      'billid': billId,
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        // result = json.decode(value.data.toString());
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          var bill = responseData['Bill'];
          var billDtl = responseData['BillDtl'];

          if (bill.length > 0) {
            result['bill'] = BillModel.fromJson(bill[0]);
          }
          List<BillDetailModel> list = List();

          billDtl.forEach((v) {
            list.add(new BillDetailModel.fromJson(v));
          });
          result['billDetail'] = list;
        }
      },
    );

    return result;
  }

  static Future<RequestResult> cancelSalesOrder(String salesOrderId) async {
    RequestResult result = RequestResult(success: false);

    Map<String, dynamic> queryParameters = {
      'action': 'cancelorder',
      'orderId': salesOrderId
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        String responseData = value.data.toString();

        if (responseData == requestSuccess) {
          result.success = true;
        } else {
          result.msg = responseData;
        }
      },
    );

    return result;
  }

  static Future<List<BillModel>> getDeliveredSalesOrder(
      int custId, String keyword, int dateOption, int startIndex) async {
    List<BillModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'orderlistb',
      'custid': custId,
      'keyword': keyword,
      'dateoption': dateOption,
      'startindex': startIndex,
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new BillModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<List<BillModel>> getNonDeliveredSalesOrder(
      int custId,
      String keyword,
      int dateOption,
      bool selectedUnconfirmed,
      bool selectedUndelivered) async {
    List<BillModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'orderlista',
      'custid': custId,
      'keyword': keyword,
      'dateoption': dateOption,
      'selunconfirmed': Utils.boolToString(selectedUnconfirmed),
      'selundelivered': Utils.boolToString(selectedUndelivered),
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new BillModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<Map<String, dynamic>> getSalesOrderCount(
      String keyword,
      int custId,
      int dateOption,
      bool selectedUnconfirmed,
      bool selectedUndelivered,
      bool selectedDelivered) async {
    Map<String, dynamic> result;

    Map<String, dynamic> queryParameters = {
      'action': 'ordercount',
      'custid': custId,
      'keyword': keyword,
      'dateoption': dateOption,
      'selunconfirmed': Utils.boolToString(selectedUnconfirmed),
      'selundelivered': Utils.boolToString(selectedUndelivered),
      'seldelivered': Utils.boolToString(selectedDelivered),
    };

    await request(serviceUrl[salesOrderUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        result = json.decode(value.data.toString());
      },
    );

    return result;
  }

  static Future<List<InventoryModel>> getInventory(
      String keyword, String category, bool recentUsed) async {
    List<InventoryModel> list = List();

    Map<String, dynamic> queryParameters = {
      'keyword': keyword,
      'category': category,
      'recentuse': Utils.boolToInt(recentUsed),
    };

    await request(serviceUrl[inventoryUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new InventoryModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<List<ItemCategoryModel>> getItemCategory() async {
    List<ItemCategoryModel> list = List();

    await request(serviceUrl[itemCategoryUrl]).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new ItemCategoryModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<RequestResult> cancelUnlock(int custId) async {
    RequestResult result = RequestResult(success: false);

    Map<String, dynamic> queryParameters = {
      'action': 'requestundo',
      'custid': custId
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        String responseData = value.data.toString();

        if (responseData == requestSuccess) {
          result.success = true;
        } else {
          result.msg = responseData;
        }
      },
    );

    return result;
  }

  static Future<RequestResult> requestUnlock(
      int custId, String reason, DateTime expectedPayDate) async {
    RequestResult result = RequestResult(success: false);

    Map<String, dynamic> queryParameters = {
      'action': 'requestunlock',
      'custid': custId,
      'reason': reason,
      'expectedpaydate': expectedPayDate
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        String responseData = value.data.toString();

        if (responseData == requestSuccess) {
          result.success = true;
        } else {
          result.msg = responseData;
        }
      },
    );

    return result;
  }

  static Future<CustUnlockRequestModel> getCustUnlockRequest(int custId) async {
    CustUnlockRequestModel result;

    Map<String, dynamic> queryParameters = {
      'action': 'getlastunlock',
      'custid': custId,
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if ((responseData != null) && (responseData.length > 0)) {
          result = CustUnlockRequestModel.fromJson(responseData[0]);
        }
      },
    );

    return result;
  }

  static Future<Map<String, dynamic>> cartToOrder(SalesCartWrapper cart) async {
    Map<String, dynamic> result;

    Map<String, dynamic> queryParameters = {
      'action': 'carttoorder',
      'cartid': cart.cart.salesCartId,
      'versionid': cart.cart.versionId,
    };

    await request(serviceUrl[updateSalesCartUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if ((responseData != null) && (responseData.length > 0)) {
          result = responseData[0];
        }
      },
    );

    return result;
  }

  static Future<List<SalesPriceModel>> getSalesPrice(
      int custId, String keyword) async {
    List<SalesPriceModel> list = List();

    Map<String, dynamic> queryParameters = {
      'custid': custId,
      'keyword': keyword,
      'option': 'all',
    };

    await request(serviceUrl[salesPriceUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new SalesPriceModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<SalesCartWrapper> updateCart(SalesCartWrapper cart) async {
    SalesCartWrapper result;
    String data = json.encode(cart.cart.toJson());
    String detail = json.encode(cart.cartDtl.map((v) => v.toJson()).toList());

    Map<String, dynamic> map = {
      'action': 'update_new',
      'data': data,
      'detail': detail,
    };
    FormData formData = FormData.fromMap(map);

    await request(serviceUrl[updateSalesCartUrl], data: formData).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = SalesCartWrapper.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<SalesCartWrapper> getCart(int custId) async {
    SalesCartWrapper result;

    Map<String, dynamic> queryParameters;
    if ((custId != null) && (custId > 0)) {
      queryParameters = {
        'custid': custId,
      };
    }

    await request(serviceUrl[salesCartUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        result = SalesCartWrapper.fromJson(responseData);
      },
    );

    return result;
  }

  static Future<CustModel> getCustDetail(int custId) async {
    CustModel result;

    Map<String, dynamic> queryParameters = {
      'custid': custId,
    };

    await request(serviceUrl[custDetailUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if ((responseData != null) && (responseData.length > 0)) {
          result = CustModel.fromJson(responseData[0]);
        }
      },
    );

    return result;
  }

  static Future<List<CustModel>> getCustListByPage(
      String keyword, int salesmanId, int startIndex) async {
    List<CustModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'getbypage',
      'keyword': keyword,
      'salesmanid': salesmanId,
      'startindex': startIndex,
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new CustModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<Map<String, dynamic>> getCustCount(
      String keyword, int salesmanId) async {
    Map<String, dynamic> result;

    Map<String, dynamic> queryParameters = {
      'action': 'getcount',
      'keyword': keyword,
      'salesmanid': salesmanId
    };

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        result = json.decode(value.data.toString());
      },
    );

    return result;
  }

  static Future<List<SalesmanModel>> getSalesmanList() async {
    List<SalesmanModel> list = List();

    Map<String, dynamic> queryParameters = {'action': 'getsalesman'};

    await request(serviceUrl[custUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new SalesmanModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static void unlockCust(
      BuildContext context, int custId, Function afterUnlock) {
    Navigator.pushNamed(context, custUnlockPath, arguments: {'custId': custId})
        .then((value) async {
      if (value != null) {
        Map<String, dynamic> map = value;
        String reason = map["reason"];
        DateTime expectedPayDate = map["expectedPayDate"];

        RequestResult result =
            await SalesService.requestUnlock(custId, reason, expectedPayDate);
        if (result.success) {
          afterUnlock();
        } else {
          DialogUtils.showToast(result.msg);
          return;
        }
      }
    });
  }
}
