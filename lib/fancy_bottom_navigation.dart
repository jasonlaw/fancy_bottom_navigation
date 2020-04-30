library fancy_bottom_navigation;

import 'package:fancy_bottom_navigation/internal/tab_item.dart';
import 'package:fancy_bottom_navigation/paint/half_clipper.dart';
import 'package:fancy_bottom_navigation/paint/half_painter.dart';
import 'package:flutter/material.dart';

class FancyBottomNavigation extends StatefulWidget {
  FancyBottomNavigation(
      {@required this.tabs,
      this.onTabChangedListener,
      this.key,
      this.initialSelection = 0,
      this.circleSize = 60,
      this.arcHeight = 70,
      this.arcWidth = 90,
      this.circleOutline = 10,
      this.shadowAllowance = 20,
      this.barHeight = 60,
      this.circleColor,
      this.activeIconColor,
      this.inactiveIconColor,
      this.textColor,
      this.gradient,
      this.barBackgroundColor,
      this.pageController})
      : assert(onTabChangedListener != null || pageController != null),
        assert(tabs != null);

  final Function(int position) onTabChangedListener;
  final Color circleColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color textColor;
  final Gradient gradient;
  final Color barBackgroundColor;
  final List<TabData> tabs;
  final int initialSelection;
  final double circleSize;
  final double arcHeight;
  final double arcWidth;
  final double circleOutline;
  final double shadowAllowance;
  final double barHeight;
  final PageController pageController;

  final Key key;

  @override
  FancyBottomNavigationState createState() => FancyBottomNavigationState();
}

class FancyBottomNavigationState extends State<FancyBottomNavigation>
    with TickerProviderStateMixin, RouteAware {
  IconData nextIcon = Icons.search;
  IconData activeIcon = Icons.search;

  int currentSelected = 0;
  double _circleAlignX = 0;
  double _circleIconAlpha = 1;

  Color circleColor;
  Color activeIconColor;
  Color inactiveIconColor;
  Color barBackgroundColor;
  Color textColor;
  Gradient gradient;
  Color shadowColor;
  Function() _pageControllerListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    activeIcon = widget.tabs[currentSelected].iconData;

    circleColor = (widget.circleColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Theme.of(context).primaryColor
        : widget.circleColor;

    activeIconColor = (widget.activeIconColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.black54
            : Colors.white
        : widget.activeIconColor;

    barBackgroundColor = (widget.barBackgroundColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Color(0xFF212121)
            : Colors.white
        : widget.barBackgroundColor;
    textColor = (widget.textColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Colors.black54
        : widget.textColor;
    inactiveIconColor = (widget.inactiveIconColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Theme.of(context).primaryColor
        : widget.inactiveIconColor;
    gradient = widget.gradient;
    shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black12;
  }

  @override
  void initState() {
    super.initState();
    _setSelected(widget.tabs[widget.initialSelection].key);

    // add listener for page swipes
    if (this.widget.pageController != null) {
      _pageControllerListener =
          () => this.setPageOffset(this.widget.pageController.page);
      this.widget.pageController.addListener(_pageControllerListener);
      if (widget.initialSelection > 0)
        WidgetsBinding.instance
            .addPostFrameCallback((_) => setPage(widget.initialSelection));
    }
  }

  _setSelected(UniqueKey key) {
    int selected = widget.tabs.indexWhere((tabData) => tabData.key == key);

    if (mounted) {
      setState(() {
        currentSelected = selected;
        _circleAlignX = -1 + (2 / (widget.tabs.length - 1) * selected);
        nextIcon = widget.tabs[selected].iconData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          height: widget.barHeight,
          decoration: BoxDecoration(color: barBackgroundColor, boxShadow: [
            BoxShadow(color: shadowColor, offset: Offset(0, -1), blurRadius: 8)
          ]),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.tabs
                .map((t) => TabItem(
                    uniqueKey: t.key,
                    selected: t.key == widget.tabs[currentSelected].key,
                    iconData: t.iconData,
                    title: t.title,
                    iconColor: inactiveIconColor,
                    gradient: this.gradient,
                    textColor: textColor,
                    callbackFunction: (uniqueKey) {
                      int selected = widget.tabs
                          .indexWhere((tabData) => tabData.key == uniqueKey);
                      //widget.onTabChangedListener(selected);
                      //_setSelected(uniqueKey);
                      //_initAnimationAndStart(_circleAlignX, 1);
                      setPage(selected);
                    }))
                .toList(),
          ),
        ),
        Positioned.fill(
          top: -(widget.circleSize +
                  widget.circleOutline +
                  widget.shadowAllowance) /
              2,
          child: Container(
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              curve: Curves.easeOut,
              alignment: Alignment(
                  _circleAlignX *
                      (Directionality.of(context) == TextDirection.rtl
                          ? -1
                          : 1),
                  1),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: FractionallySizedBox(
                  widthFactor: 1 / widget.tabs.length,
                  child: GestureDetector(
                    onTap: widget.tabs[currentSelected].onclick,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: widget.circleSize +
                              widget.circleOutline +
                              widget.shadowAllowance,
                          width: widget.circleSize +
                              widget.circleOutline +
                              widget.shadowAllowance,
                          child: ClipRect(
                              clipper: HalfClipper(),
                              child: Container(
                                child: Center(
                                  child: Container(
                                      width: widget.circleSize +
                                          widget.circleOutline,
                                      height: widget.circleSize +
                                          widget.circleOutline,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: shadowColor,
                                                blurRadius: 8)
                                          ])),
                                ),
                              )),
                        ),
                        SizedBox(
                            height: widget.arcHeight,
                            width: widget.arcWidth,
                            child: CustomPaint(
                              painter: HalfPainter(barBackgroundColor),
                            )),
                        SizedBox(
                          height: widget.circleSize,
                          width: widget.circleSize,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: this.gradient,
                                color: circleColor),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: AnimatedOpacity(
                                duration:
                                    Duration(milliseconds: ANIM_DURATION ~/ 5),
                                opacity: _circleIconAlpha,
                                child: Icon(
                                  activeIcon,
                                  color: activeIconColor,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _initAnimationAndStart(double initialAlphaValue) {
    _circleIconAlpha = initialAlphaValue;

    Future.delayed(Duration(milliseconds: ANIM_DURATION ~/ 5), () {
      setState(() {
        activeIcon = nextIcon;
      });
    }).then((_) {
      Future.delayed(Duration(milliseconds: (ANIM_DURATION ~/ 5 * 3)), () {
        setState(() {
          _circleIconAlpha = 1;
        });
      });
    });
  }

  void setPage(int page) {
    // widget.onTabChangedListener(page);
    //_setSelected(widget.tabs[page].key);
    //_initAnimationAndStart(_circleAlignX, 1);

    if (widget.pageController != null) {
      widget.pageController.removeListener(_pageControllerListener);
      var f = widget.pageController.animateToPage(page,
          duration: Duration(milliseconds: ANIM_DURATION),
          curve: Curves.easeOut);

      f.then((v) {
        // be shure that listener is added only one times
        // ignore: INVALID_USE_OF_PROTECTED_MEMBER
        if (!widget.pageController.hasListeners) {
          widget.pageController.addListener(_pageControllerListener);
        }
      });

      _setSelected(widget.tabs[page].key);
      _initAnimationAndStart(0);
    } else {
      widget.onTabChangedListener(page);

      _setSelected(widget.tabs[page].key);
      _initAnimationAndStart(0);

      setState(() {
        currentSelected = page;
      });
    }
  }

  void setPageOffset(double page) {
    _setSelected(widget.tabs[page.round()].key);
    _initAnimationAndStart(1);

    setState(() {
      //currentSelected = page;
      currentSelected = page.round();
    });
  }
}

class TabData {
  TabData({@required this.iconData, @required this.title, this.onclick});

  IconData iconData;
  String title;
  Function onclick;
  final UniqueKey key = UniqueKey();
}
