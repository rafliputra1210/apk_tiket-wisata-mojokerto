import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Widget loadWebImage(String url, String id) {
  final viewId = 'img-$id';
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) => html.ImageElement()
      ..src = url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover',
  );
  return HtmlElementView(viewType: viewId);
}
