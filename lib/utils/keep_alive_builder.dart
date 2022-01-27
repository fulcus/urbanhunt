import 'package:flutter/material.dart';

class KeepAliveBuilder extends StatefulWidget {

  final Widget child;

  KeepAliveBuilder({
    required this.child
  });

  @override
  _KeepAliveBuilderState createState() => _KeepAliveBuilderState();
}

class _KeepAliveBuilderState extends State<KeepAliveBuilder> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}