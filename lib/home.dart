import 'dart:async';
import 'dart:io';
import 'package:eplaza/Notification.dart';
import 'package:eplaza/conectivity.dart';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
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


  var URL = "https://www.mindyknows.com/";
  double progress = 0;
  InAppWebViewController webView;

  @override
  void initState() {
    PushNotificationService().initialise(context);

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() => _source = source);
    });

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
                  // (progress != 1.0)
                  //     ? Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: [
                  //           CircularProgressIndicator()
                  //           // Container(
                  //           //        height: _height / 1.1365,
                  //           //        width: _width,
                  //           //        child:
                  //           //            Center(child: Image.asset('assets/splash.png')))
                  //         ],
                  //       )
                  //     : null, //
                  // Should be removed while showing
                  Expanded(
                    child: Container(
                      child: InAppWebView(
                        initialUrl: URL,
                        initialHeaders: {},
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            mediaPlaybackRequiresUserGesture: false,
                            debuggingEnabled: true,
                          ),
                        ),
                        onWebViewCreated:
                            (InAppWebViewController controller) {
                          webView = controller;
                        },
                        shouldOverrideUrlLoading:
                            (controller, request) async {
                          var url = request.url;
                          var uri = Uri.parse(url);

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
                              return ShouldOverrideUrlLoadingAction.CANCEL;
                            }
                          }

                          return ShouldOverrideUrlLoadingAction.ALLOW;
                        },
                        onLoadStart: (InAppWebViewController controller,
                            String url) {},
                        onLoadStop: (InAppWebViewController controller,
                            String url) async {
                          setState(() {
                            sidebar = true;
                          });
                        },
                        onReceivedServerTrustAuthRequest:
                            (InAppWebViewController controller,
                                ServerTrustChallenge challenge) async {
                          return ServerTrustAuthResponse(
                              action: ServerTrustAuthResponseAction.PROCEED);
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
                            (progress == 100) ? _saving = false :_saving = true;
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
    ); //Remove null widgets
  }


}
