import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mis_app/utils/utils.dart';

class WebViewManager {
  static const int _capatity = 5;
  static const String _defaultHomeUrl = "about:blank";

  static int _showingIndex = 0;
  static Map<String, String> _headers = const {};
  static List<WebViewItem> _webViewItemList;
  static List<InAppWebView> _webViewList = [];

  static int get capatity {
    return _capatity;
  }

  static List<InAppWebView> get webViews {
    return _webViewList;
  }

  static InAppWebViewController getController(int index) {
    return _webViewItemList[index].controller;
  }

  static int loadUrl(String url) {
    WebViewItem item = preloadUrl(url);
    int index = _webViewItemList.indexOf(item);

    _showingIndex = index;

    return index;
  }

  static WebViewItem preloadUrl(String url) {
    bool reload = false;

    WebViewItem item = _find(url);

    // 如果对应 url 没有缓存，找空闲页面
    // 如果有缓存，检查是否过期
    if (item == null) {
      item = _findRecycled();
      reload = true;
    } else {
      reload = item.isExpired;
    }

    // 如果没找到合适的，就使用第1个或最后1个页面
    if (item == null) {
      if (_showingIndex == 0) {
        item = _webViewItemList[_capatity - 1];
      } else {
        item = _webViewItemList[0];
      }
      reload = true;
    }

    if (reload) {
      item.url = url;
      item.controller.loadUrl(url: url, headers: _headers);
    }
    _updateToMaxWeight(item);
    item.idled = false;
    item.updateExpiryDate();

    return item;
  }

  static void disposeUrl(String url) {
    WebViewItem item = _find(url);
    if (item != null) {
      item.idled = true;
    }
  }

  static void init(
      {Map<String, String> headers = const {},
      InAppWebViewGroupOptions initialOptions,
      List<String> urls}) {
    _headers = headers;
    if (_webViewItemList == null) {
      _webViewItemList = List();
    } else {
      dispose();
    }
    _webViewList = [];

    int currentWeight = 0;

    for (var i = 0; i < _capatity; i++) {
      WebViewItem item = WebViewItem(weight: currentWeight, idled: true);
      currentWeight--;

      String url = _defaultHomeUrl;

      if ((urls != null) && (i < urls.length)) {
        url = urls[i];
      }
      item.url = url;

      InAppWebView webView = InAppWebView(
        initialHeaders: _headers,
        initialUrl: url,
        initialOptions: initialOptions,
        onWebViewCreated: (InAppWebViewController inAppWebViewController) {
          item.controller = inAppWebViewController;
        },
      );
      item.webView = webView;

      _webViewItemList.add(item);
      _webViewList.add(webView);
    }
  }

  static _updateToMaxWeight(WebViewItem item) {
    item.weight = (_maxWeight ?? 0) + 1;
  }

  static int get _maxWeight {
    int maxWeight;
    if (_webViewItemList != null) {
      _webViewItemList.forEach((element) {
        if ((maxWeight == null) || (element.weight > maxWeight)) {
          maxWeight = element.weight;
        }
      });
    }

    return maxWeight;
  }

  static int get _minWeight {
    int minWeight;
    if (_webViewItemList != null) {
      _webViewItemList.forEach((element) {
        if ((minWeight == null) || (element.weight < minWeight)) {
          minWeight = element.weight;
        }
      });
    }

    return minWeight;
  }

  static WebViewItem _find(String url) {
    return _webViewItemList.firstWhere(
        (element) => Utils.sameText(element.url, url),
        orElse: () => null);
  }

  /// 查找空闲页面，或权限最低的
  static WebViewItem _findRecycled() {
    WebViewItem item = _webViewItemList.firstWhere(
        (element) => element.idled || element.isExpired,
        orElse: () => null);

    if (item == null) {
      int minWeight = _minWeight;
      if (minWeight != null) {
        item = _findByWeight(minWeight);
      }
    }

    return item;
  }

  static WebViewItem _findByWeight(int weight) {
    return _webViewItemList.firstWhere((element) => element.weight == weight,
        orElse: () => null);
  }

  static void dispose() {
    if (_webViewItemList != null) {
      while (_webViewItemList.length > 0) {
        int index = _webViewItemList.length - 1;
        var item = _webViewItemList[index];
        _webViewItemList.removeAt(index);
        item.webView = null;
        item = null;
      }
    }
  }
}

class WebViewItem {
  static const int _expirySeconds = 60 * 5;

  String url;
  InAppWebView webView;
  InAppWebViewController controller;
  DateTime expiryDate;
  int weight;
  bool idled;

  bool get isExpired {
    return DateTime.now().isAfter(this.expiryDate);
  }

  WebViewItem(
      {this.url, this.webView, this.expiryDate, this.weight, this.idled}) {
    if (this.expiryDate == null) {
      updateExpiryDate();
    }

    if (this.webView == null) {
      this.webView = InAppWebView();
    }
  }

  void updateExpiryDate() {
    this.expiryDate = DateTime.now().add(Duration(seconds: _expirySeconds));
  }
}
