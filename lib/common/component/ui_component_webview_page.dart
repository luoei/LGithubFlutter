import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';

class UIComponentWebViewPage extends StatefulWidget {

  final String uri;

  UIComponentWebViewPage({Key key, this.uri}) : super (key : key);

  @override
  State<StatefulWidget> createState() => UIComponentWebViewPageState(uri: uri);

}

class UIComponentWebViewPageState extends State<UIComponentWebViewPage> {

  String uri;

  String title;

  UIComponentWebViewPageState({this.uri, this.title = ' '});

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: new Container(
        child: WebView(
          initialUrl: uri,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated:(WebViewController webViewController){
            _controller.complete(webViewController);
          },
//          javascriptChannels:<JavascriptChannel>[
//            _toasterJavascriptChannel(context),
//          ].toSet(),
          navigationDelegate: (NavigationRequest request) {
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            print('page finished loading: $url');
            _controller.future.then((webViewController){
              webViewController.evaluateJavascript('window.document.title').then((contentTitle) {
                if (contentTitle != null) {
                  if (contentTitle.startsWith("\"")){
                    contentTitle = contentTitle.substring(1);
                  }
                  if (contentTitle.endsWith("\"")){
                    contentTitle = contentTitle.substring(0,contentTitle.length-1);
                  }
                  setState(() {
                    title = contentTitle;
                  });
                }
              });

            });
          },
        ),
      ),
    );
  }


//  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
//    return JavascriptChannel(
//        name: 'Toaster',
//        onMessageReceived: (JavascriptMessage message) {
//          Scaffold.of(context).showSnackBar(
//            SnackBar(content: Text(message.message)),
//          );
//        });
//  }
}