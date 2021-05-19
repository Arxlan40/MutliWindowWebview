import 'dart:async';
import 'dart:io';
import 'package:eplaza/Notification.dart';
import 'package:eplaza/conectivity.dart';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  @override
  _WebViewWebPageState createState() => _WebViewWebPageState();
}

class _WebViewWebPageState extends State<HomePage> {
  bool sidebar = false;
  Map _source = {ConnectivityResult.none: false};
  MyConnectivity _connectivity = MyConnectivity.instance;
  bool _saving = false;
  bool _saving1 = false;

  Future<bool> _onBack() async {
    bool goBack;
    var value = await webView.canGoBack();
    if (value) {
      webView.goBack();
      return false;
    } else {
      await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('Confirmation ',
              style: TextStyle(color: Colors.orangeAccent)),
          // Are you sure?
          content: new Text('Do you want exit app ? '),
          // Do you want to go back?
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                setState(() {
                  goBack = false;
                });
              },
              child: new Text('No'),
            ),
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  goBack = true;
                });
              },
              child: new Text('Yes'), // Yes
            ),
          ],
        ),
      );
      if (goBack) Navigator.pop(context); // If user press Yes pop the page
      return goBack;
    }
  }

  Future<void> _refresh() async {
    webView.reload();
  }

  var URL = "https://farnek.org";
  double progress = 0;
  double progress1 = 0;

  InAppWebViewController webView;
  InAppWebViewController _webViewPopupController;

  Future<bool> _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.microphone,
      Permission.phone,
    ].request();
  }

  @override
  void initState() {
    PushNotificationService().initialise(context);

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });
    _requestPermission();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  internetdialog() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: Get.height / 2,
          width: Get.width,
          color: Colors.white,
          child: Image.asset(
            'asset/internet.png',
          ),
        ),
        Flexible(
          child: Text(
            "Sorry, there is no internet connection.",
            style: TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FlatButton(
              onPressed: () {
                webView.reload();
              },
              child: Text("Try again"),
              color: Colors.blue[100],
            ),
            FlatButton(
                onPressed: () {
                  AppSettings.openWIFISettings();
                },
                child: Text("Internet settings"),
                color: Colors.blue[100])
          ],
        )
      ],
    );
  }

  final GlobalKey webViewKey = GlobalKey();
  String url = "";
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String string;

    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.none:
        string = "Offline";
        break;
      case ConnectivityResult.mobile:
        string = "Online";
        break;
      case ConnectivityResult.wifi:
        string = "Online";
    }
    return WillPopScope(
      onWillPop: _onBack,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: scaffoldState,
          body: string == 'Offline'
              ? internetdialog()
              : ModalProgressHUD(
                  color: Colors.white,
                  inAsyncCall: _saving,
                  child: Container(
                      child: Column(
                          children: <Widget>[
                    Expanded(
                      child: Container(
                        child: InAppWebView(
                          key: webViewKey,
                          initialUrlRequest: URLRequest(url: Uri.parse(URL)),
                          initialOptions: InAppWebViewGroupOptions(
                            android: AndroidInAppWebViewOptions(
                                useHybridComposition: true,
                                supportMultipleWindows: true),
                            ios: IOSInAppWebViewOptions(
                              allowsInlineMediaPlayback: true,
                            ),
                            crossPlatform: InAppWebViewOptions(
                              mediaPlaybackRequiresUserGesture: false,
                              javaScriptCanOpenWindowsAutomatically: true,
                              useShouldOverrideUrlLoading: true,
                            ),
                          ),
                          onWebViewCreated:
                              (InAppWebViewController controller) {
                            webView = controller;


                          },
                          onCreateWindow:
                              (controller, createWindowRequest) async {
                            print("onCreateWindow");

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: <Widget>[
                                    new FlatButton(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                  insetPadding: EdgeInsets.zero,
                                  contentPadding: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  content: Container(
                                    width: Get.width / 1.1,
                                    height: 600,
                                    child: InAppWebView(
                                      // Setting the windowId property is important here!
                                      windowId: createWindowRequest.windowId,
                                      initialOptions: InAppWebViewGroupOptions(
                                        android: AndroidInAppWebViewOptions(
                                          useHybridComposition: true,
                                        ),
                                        ios: IOSInAppWebViewOptions(
                                          allowsInlineMediaPlayback: true,
                                        ),
                                        crossPlatform: InAppWebViewOptions(
                                          mediaPlaybackRequiresUserGesture:
                                              false,
                                          useShouldOverrideUrlLoading: true,
                                        ),
                                      ),
                                      onWebViewCreated:
                                          (InAppWebViewController controller) {
                                        _webViewPopupController = controller;
                                        webView.addJavaScriptHandler(
                                            handlerName: "test",
                                            callback: (arguments) async {
                                              print('hello from test');
                                              print(arguments.length);
                                              print(arguments);
                                            });
                                          },
                                      onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
                                        print("console message: ${consoleMessage.message}");
                                      },
                                      // onProgressChanged: (InAppWebViewController controller,
                                      //     int progress) {
                                      //   setState(() {
                                      //     (progress == 100)
                                      //         ? _saving1 = false
                                      //         : _saving1 = true;
                                      //     this.progress1 = progress / 100;
                                      //     print(progress);
                                      //   });
                                      // },
                                      androidOnPermissionRequest:
                                          (InAppWebViewController controller,
                                              String origin,
                                              List<String> resources) async {
                                        return PermissionRequestResponse(
                                            resources: resources,
                                            action:
                                                PermissionRequestResponseAction
                                                    .GRANT);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );

                            return true;
                          },
                          onLoadStart: (controller, url) {
                            setState(() {
                              this.url = url.toString();
                            });
                          },
                          shouldOverrideUrlLoading:
                              (controller, request) async {
                            var uri = request.request.url;

                            if (![
                              "http",
                              "https",
                              "file",
                              "chrome",
                              "data",
                              "javascript",
                              "about"
                            ].contains(uri.scheme)) {
                              if (await canLaunch(url)) {
                                // Launch the App
                                await launch(
                                  url,
                                );
                                // and cancel the request
                                return NavigationActionPolicy.CANCEL;
                              }
                            }

                            return NavigationActionPolicy.ALLOW;
                          },
                          onLoadStop: (controller, url) async {
                            setState(() {
                              this.url = url.toString();
                            });
                          },
                          androidOnPermissionRequest:
                              (InAppWebViewController controller, String origin,
                                  List<String> resources) async {
                            return PermissionRequestResponse(
                                resources: resources,
                                action: PermissionRequestResponseAction.GRANT);
                          },
                          onProgressChanged: (InAppWebViewController controller,
                              int progress) {
                            setState(() {
                              (progress == 100)
                                  ? _saving = false
                                  : _saving = true;
                              this.progress = progress / 100;
                              print(progress);
                            });
                          },
                        ),
                      ),
                    ),
                  ].where((Object o) => o != null).toList())),
                ),
        ),
      ),
    ); //Remove null widgets
  }
}
