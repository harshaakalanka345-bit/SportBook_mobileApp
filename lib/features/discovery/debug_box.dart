import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DebugBox extends SingleChildRenderObjectWidget {
  final String name;
  const DebugBox({super.key, required this.name, required Widget child}) : super(child: child);

  @override
  RenderDebugBox createRenderObject(BuildContext context) => RenderDebugBox(name);

  @override
  void updateRenderObject(BuildContext context, RenderDebugBox renderObject) {
    renderObject.name = name;
  }
}

class RenderDebugBox extends RenderProxyBox {
  String name;
  RenderDebugBox(this.name);

  @override
  void performLayout() {
    print('>>> LAYOUT START: $name');
    super.performLayout();
    print('>>> LAYOUT END: $name');
  }
}
