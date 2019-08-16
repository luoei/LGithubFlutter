import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github/common/component/ui_component_photo_view_page.dart';

class NavigatorUtils {

  ///弹出 dialog
  static Widget showDialogView<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder builder,
  }) {

    Widget widget = new SafeArea(child: builder(context));
    showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(

            ///不受系统字体缩放影响
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .copyWith(textScaleFactor: 1),
              child: widget);
        });
     return widget;
  }


  ///图片预览
  static gotoPhotoViewPage(BuildContext context, String url) {
    NavigatorRouter(context, new UIComponentPhotoViewPage(url));
  }

  ///公共打开方式
  static NavigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }

}