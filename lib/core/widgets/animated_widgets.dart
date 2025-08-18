import 'package:flutter/material.dart';

/// 动画组件库
class AnimatedWidgets {
  /// 淡入淡出动画
  static Widget fadeInOut({
    required Widget child,
    required bool visible,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 滑动进入动画
  static Widget slideIn({
    required Widget child,
    required bool visible,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
    Offset beginOffset = const Offset(0, 1),
  }) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : beginOffset,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 缩放动画
  static Widget scale({
    required Widget child,
    required bool visible,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.elasticOut,
    double beginScale = 0.0,
  }) {
    return AnimatedScale(
      scale: visible ? 1.0 : beginScale,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 旋转动画
  static Widget rotate({
    required Widget child,
    required bool rotating,
    Duration duration = const Duration(seconds: 1),
  }) {
    return AnimatedRotation(
      turns: rotating ? 1.0 : 0.0,
      duration: duration,
      child: child,
    );
  }

  /// 弹跳按钮动画
  static Widget bounceButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _BounceButton(
      onPressed: onPressed,
      duration: duration,
      child: child,
    );
  }

  /// 波纹扩散动画
  static Widget rippleEffect({
    required Widget child,
    Color rippleColor = Colors.blue,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return _RippleEffect(
      rippleColor: rippleColor,
      duration: duration,
      child: child,
    );
  }

  /// 渐变背景动画
  static Widget gradientBackground({
    required Widget child,
    required List<Color> colors,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _GradientBackground(
      colors: colors,
      duration: duration,
      child: child,
    );
  }

  /// 加载脉冲动画
  static Widget loadingPulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minOpacity = 0.3,
    double maxOpacity = 1.0,
  }) {
    return _LoadingPulse(
      duration: duration,
      minOpacity: minOpacity,
      maxOpacity: maxOpacity,
      child: child,
    );
  }

  /// 卡片翻转动画
  static Widget cardFlip({
    required Widget front,
    required Widget back,
    required bool showFront,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return _CardFlip(
      front: front,
      back: back,
      showFront: showFront,
      duration: duration,
    );
  }

  /// 列表项进入动画
  static Widget listItemAnimation({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _ListItemAnimation(
      index: index,
      delay: delay,
      duration: duration,
      child: child,
    );
  }
}

/// 弹跳按钮实现
class _BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;

  const _BounceButton({
    required this.child,
    required this.onPressed,
    required this.duration,
  });

  @override
  State<_BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<_BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 波纹效果实现
class _RippleEffect extends StatefulWidget {
  final Widget child;
  final Color rippleColor;
  final Duration duration;

  const _RippleEffect({
    required this.child,
    required this.rippleColor,
    required this.duration,
  });

  @override
  State<_RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<_RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 100 * _animation.value,
              height: 100 * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.rippleColor.withOpacity(1 - _animation.value),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 渐变背景实现
class _GradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;

  const _GradientBackground({
    required this.child,
    required this.colors,
    required this.duration,
  });

  @override
  State<_GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<_GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              stops: [
                _animation.value * 0.3,
                _animation.value * 0.7,
                _animation.value,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 加载脉冲实现
class _LoadingPulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const _LoadingPulse({
    required this.child,
    required this.duration,
    required this.minOpacity,
    required this.maxOpacity,
  });

  @override
  State<_LoadingPulse> createState() => _LoadingPulseState();
}

class _LoadingPulseState extends State<_LoadingPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// 卡片翻转实现
class _CardFlip extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool showFront;
  final Duration duration;

  const _CardFlip({
    required this.front,
    required this.back,
    required this.showFront,
    required this.duration,
  });

  @override
  State<_CardFlip> createState() => _CardFlipState();
}

class _CardFlipState extends State<_CardFlip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(_CardFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFront != oldWidget.showFront) {
      if (widget.showFront) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isShowingFront = _animation.value < 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value * 3.14159),
          child: isShowingFront ? widget.front : widget.back,
        );
      },
    );
  }
}

/// 列表项动画实现
class _ListItemAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const _ListItemAnimation({
    required this.child,
    required this.index,
    required this.delay,
    required this.duration,
  });

  @override
  State<_ListItemAnimation> createState() => _ListItemAnimationState();
}

class _ListItemAnimationState extends State<_ListItemAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // 延迟启动动画
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}