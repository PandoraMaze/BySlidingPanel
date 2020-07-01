library by_sliding_panel;

import 'package:flutter/material.dart';

const double _swingSpeed = 200;
const List<Widget> _defButtons = <Widget>[];
const Duration _animDuration = Duration(milliseconds: 200);

enum SlideState {
  /// Slide to Left
  LEFT,

  /// Slide to Right
  RIGHT,

  /// Normal State
  CLOSE,
}

class BySlidingPanel extends StatefulWidget {
  /// Main
  final Widget child;

  /// State
  final SlideState state;

  /// Right Behind View Width
  final double rightButtonWidth;

  /// Left Behind View Width
  final double leftButtonWidth;

  /// Left Button Group View
  final List<Widget> leftButtons;

  /// Right Button Group View
  final List<Widget> rightButtons;

  /// Item Click (Whole View)
  final VoidCallback onItemTap;

  final VoidCallback onSlideStart;
  final VoidCallback onSlideEnd;
  final VoidCallback onSlideCancel;

  /// Auto Finish the Action if Over the Speed unless release the Finger
  final double swingSpeed;

  /// Auto Anim Duration
  final Duration animDuration;

  /// True: Block the Back Press and Restore to origin state
  final bool blockBack;

  BySlidingPanel({
    Key key,
    @required this.child,
    this.state = SlideState.CLOSE,
    this.rightButtonWidth,
    this.leftButtonWidth,
    this.leftButtons = _defButtons,
    this.rightButtons = _defButtons,
    this.onItemTap,
    this.onSlideStart,
    this.onSlideEnd,
    this.onSlideCancel,
    this.swingSpeed = _swingSpeed,
    this.animDuration = _animDuration,
    this.blockBack = false,
  }) : super(key: key);

  @override
  _BySlidingPanelState createState() => _BySlidingPanelState();
}

class _BySlidingPanelState extends State<BySlidingPanel> with TickerProviderStateMixin {
  double _offset = 0;
  double _maxLeftOffset;
  double _maxRightOffset;

  bool _isFold() => _offset == 0;

  AnimationController _animCtrl;
  double _startOffset = 0;

  Future<bool> _onBack() {
    if (widget.blockBack && _offset != 0) {
      _close();
      return Future.value(false);
    }
    return Future.value(true);
  }

  _autoOpen() {
    if (_isFold()) {
      return;
    }
    _animCtrl.animateTo(_offset > 0 ? _maxLeftOffset : -_maxRightOffset).then((value) => widget.onSlideEnd?.call());
  }

  _close() {
    if (_isFold()) {
      return;
    }
    _animCtrl.animateTo(0).then((value) => widget.onSlideCancel?.call());
  }

  @override
  void dispose() {
    _animCtrl?.dispose();
    super.dispose();
  }

  _handleDragStart(DragStartDetails details) {
    _startOffset = _offset;
    widget.onSlideStart?.call();
  }

  _handleDragUpdate(DragUpdateDetails details) => setState(() {
        _offset = (_offset + details.primaryDelta).clamp(-_maxRightOffset, _maxLeftOffset);
      });

  _handleDragEnd(DragEndDetails details) {
    _animCtrl.value = _offset;

    /// Calc Speed
    double speed = details.velocity.pixelsPerSecond.dx;
    if (speed > _swingSpeed) {
      _handleAction(true);
    } else if (speed < -_swingSpeed) {
      _handleAction(false);
    } else {
      double dx = _offset - _startOffset;
      _handleAction(_checkOverHalf(dx) ? dx > 0 : dx < 0);
    }
  }

  _handleAction(bool positive) {
    if (_offset > 0) {
      positive ? _autoOpen() : _close();
    } else {
      positive ? _close() : _autoOpen();
    }
  }

  /// Check the Distance of Dragging
  bool _checkOverHalf(double dx) {
    return dx.abs() > (_offset > 0 ? _maxLeftOffset : _maxRightOffset) / 2;
  }

  /// Matrix transforming happened in Drawing, no need to rebuild the layout.
  /// So it leads to better Performer.
  /// Refer to https://book.flutterchina.club/chapter5/transform.html
  _buildMain() => GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onTap: widget.onItemTap,
        child: Transform.translate(
          offset: Offset(_offset, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: widget.child,
              ),
            ],
          ),
        ),
      );

  _buildLeftButtons() => Positioned.fill(
          child: Row(
        children: widget.leftButtons,
      ));

  _buildRightButtons() => Positioned.fill(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: widget.rightButtons,
      ));

  double get _target =>
      widget.state == SlideState.CLOSE ? 0 : (widget.state == SlideState.LEFT ? _maxLeftOffset : -_maxRightOffset);

  @override
  void initState() {
    super.initState();

    _maxRightOffset = widget.rightButtonWidth * widget.rightButtons.length;
    _maxLeftOffset = widget.leftButtonWidth * widget.leftButtons.length;

    Duration duration = Duration();
    if (widget.rightButtons.isNotEmpty) {
      duration += widget.animDuration;
    }
    if (widget.leftButtons.isNotEmpty) {
      duration += widget.animDuration;
    }

    _animCtrl = AnimationController(
      vsync: this,
      duration: duration,
      lowerBound: -_maxRightOffset,
      upperBound: _maxLeftOffset,
    )..addListener(() {
        _offset = _animCtrl.value;
        setState(() {});
      });
    _animCtrl.value = _target;
  }

  @override
  void didUpdateWidget(BySlidingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == widget.state) {
      return;
    }
    _animCtrl.animateTo(_target).then((value) => widget.onSlideEnd?.call());
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    if (widget.leftButtons.isNotEmpty) {
      children.add(_buildLeftButtons());
    }
    if (widget.rightButtons.isNotEmpty) {
      children.add(_buildRightButtons());
    }
    children.add(_buildMain());

    return WillPopScope(
      child: Stack(
        children: children,
      ),
      onWillPop: _onBack,
    );
  }
}
