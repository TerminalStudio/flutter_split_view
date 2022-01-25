library flutter_split_view;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _kDefaultWidth = 300.0;

const _kDefaultBreakpoint = 500.0;

typedef PageBuilder = Page Function({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
});

MaterialPage<void> _materialPageBuilder({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
}) =>
    MaterialPage<void>(
      name: title,
      arguments: arguments,
      key: key,
      restorationId: restorationId,
      child: child,
      fullscreenDialog: fullscreenDialog ?? false,
    );

CupertinoPage<void> _cupertinoPageBuilder({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
}) =>
    CupertinoPage<void>(
      title: title,
      arguments: arguments,
      key: key,
      restorationId: restorationId,
      child: child,
      fullscreenDialog: fullscreenDialog ?? false,
    );

class _PageConfig {
  final Widget child;
  final String? name;
  final Object? arguments;
  final String? restorationId;
  final bool? fullscreenDialog;

  _PageConfig({
    required this.child,
    this.name,
    this.arguments,
    this.restorationId,
    this.fullscreenDialog,
  });
}

/// A widget that splits the screen into two views automatically when the
/// device's width is greater than [breakpoint].
class SplitView extends StatefulWidget {
  const SplitView.material({
    Key? key,
    required this.child,
    this.childWidth = _kDefaultWidth,
    this.breakpoint = _kDefaultBreakpoint,
    this.placeholder,
    this.title,
  })  : pageBuilder = _materialPageBuilder,
        super(key: key);

  const SplitView.cupertino({
    Key? key,
    required this.child,
    this.childWidth = _kDefaultWidth,
    this.breakpoint = _kDefaultBreakpoint,
    this.placeholder,
    this.title,
  })  : pageBuilder = _cupertinoPageBuilder,
        super(key: key);

  const SplitView.custom({
    Key? key,
    required this.child,
    this.childWidth = _kDefaultWidth,
    this.breakpoint = _kDefaultBreakpoint,
    this.placeholder,
    this.title,
    required this.pageBuilder,
  }) : super(key: key);

  static SplitViewState of(BuildContext context) {
    final state = context.findAncestorStateOfType<SplitViewState>();
    assert(state != null, 'No SplitViewState found in the context');
    return state!;
  }

  /// The width threshold at which the secondary view will be shown.
  final double breakpoint;

  /// The root page.
  final Widget child;

  /// Width of the child when it is in the main view.
  final double childWidth;

  /// Title of the root page, used for the back button in Cupertino.
  final String? title;

  /// Placeholder widget to show when the secondary view is visible and no page
  /// is selected.
  final Widget? placeholder;

  final PageBuilder pageBuilder;

  @override
  SplitViewState createState() => SplitViewState();
}

class SplitViewState extends State<SplitView> {
  /// Configuration of pages in the main view.
  final _mainPageConfigs = <_PageConfig>[];

  /// Configuration of pages in the side view.
  final _sidePageConfigs = <_PageConfig>[];

  /// List of pages that are actually visible in the main view.
  var _mainPages = <Page>[];

  /// List of pages that are actually visible in the side view.
  var _sidePages = <Page>[];

  /// Whether the side view is visible.
  var _splitted = false;

  /// Whether the configuration has changed and the pages need to be rebuilt.
  var _dirty = true;

  @override
  void initState() {
    _mainPageConfigs.add(
      _PageConfig(child: widget.child, name: widget.title),
    );

    _updatePagesIfNeeded();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        _splitted = constrains.maxWidth >= widget.breakpoint;

        _updatePagesIfNeeded();

        if (!_splitted) {
          return Navigator(
            pages: _mainPages,
            onPopPage: _onPopTop,
          );
        }

        return Row(
          children: <Widget>[
            SizedBox(
              width: widget.childWidth,
              child: Navigator(
                pages: _mainPages,
                onPopPage: _onPopMain,
              ),
            ),
            const VerticalDivider(
              width: 0,
            ),
            Expanded(
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: _buildSideView(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSideView() {
    if (_sidePages.isEmpty) {
      return widget.placeholder ?? Container();
    }

    return Navigator(
      pages: _sidePages,
      onPopPage: _onPopSide,
    );
  }

  /// Push a new page to the side view.
  void pushMain(
    Widget page, {
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    final pageConfig = _PageConfig(
      child: page,
      name: title,
      arguments: arguments,
      restorationId: restorationId,
      fullscreenDialog: fullscreenDialog,
    );

    _mainPageConfigs.add(pageConfig);

    setState(_markDirty);
  }

  /// Push a new page to the side view.
  void pushSide(
    Widget page, {
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    final pageConfig = _PageConfig(
      child: page,
      name: title,
      arguments: arguments,
      restorationId: restorationId,
      fullscreenDialog: fullscreenDialog,
    );

    _sidePageConfigs.add(pageConfig);

    setState(_markDirty);
  }

  /// Pop a page from the top of the stack.
  bool pop() {
    return popSide() || popMain();
  }

  /// Pop a page from the top of the main view.
  bool popMain() {
    if (_mainPageConfigs.length <= 1) {
      return false;
    }

    _mainPageConfigs.removeLast();

    setState(_markDirty);

    return true;
  }

  /// Pop a page from the side view.
  bool popSide() {
    if (_sidePageConfigs.isEmpty) {
      return false;
    }

    _sidePageConfigs.removeLast();

    setState(_markDirty);

    return true;
  }

  /// Number of pages in the stack.
  int get pageCount => mainPageCount + sidePageCount;

  /// Number of pages in the main view.
  int get mainPageCount => _mainPageConfigs.length;

  /// Number of pages in the side view.
  int get sidePageCount => _sidePageConfigs.length;

  /// Sets the page displayed in the main view.
  void setMain(
    Widget page, {
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    _mainPageConfigs.clear();

    _mainPageConfigs.add(
      _PageConfig(
        child: page,
        name: title,
        arguments: arguments,
        restorationId: restorationId,
        fullscreenDialog: fullscreenDialog,
      ),
    );

    setState(_markDirty);
  }

  /// Sets the page displayed in the side view.
  void setSide(
    Widget page, {
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    _sidePageConfigs.clear();

    _sidePageConfigs.add(
      _PageConfig(
        child: page,
        name: title,
        arguments: arguments,
        restorationId: restorationId,
        fullscreenDialog: fullscreenDialog,
      ),
    );

    setState(_markDirty);
  }

  /// Clears all pages in the side view.
  void clearSide() {
    _sidePageConfigs.clear();

    setState(_markDirty);
  }

  bool get isSplitted {
    return _splitted;
  }

  void _markDirty() {
    _dirty = true;
  }

  void _updatePagesIfNeeded() {
    if (_dirty) {
      _dirty = false;
    }

    if (_splitted) {
      _mainPages = _buildPages(_mainPageConfigs);
      _sidePages = _buildPages(_sidePageConfigs);
    } else {
      _mainPages = _buildPages([..._mainPageConfigs, ..._sidePageConfigs]);
      _sidePages = [];
    }
  }

  List<Page> _buildPages(List<_PageConfig> pageConfigs) {
    final pages = <Page>[];
    for (var i = 0; i < pageConfigs.length; i++) {
      final pageConfig = pageConfigs[i];
      final pageKey = ValueKey(i);
      final page = widget.pageBuilder(
        key: pageKey,
        child: pageConfig.child,
        title: pageConfig.name,
        arguments: pageConfig.arguments,
        restorationId: pageConfig.restorationId,
      );
      pages.add(page);
    }
    return pages;
  }

  bool _onPopTop(Route<dynamic> route, dynamic result) {
    return _onPopSide(route, result) || _onPopMain(route, result);
  }

  bool _onPopMain(Route<dynamic> route, dynamic result) {
    print('_onPopMain');
    if (_mainPageConfigs.length <= 1) {
      return false;
    }
    if (route.didPop(result)) {
      _mainPageConfigs.removeLast();
      return true;
    }
    return false;
  }

  bool _onPopSide(Route<dynamic> route, dynamic result) {
    print('_onPopSide');
    if (_sidePageConfigs.isEmpty) {
      return false;
    }
    if (route.didPop(result)) {
      _sidePageConfigs.removeLast();
      // _markDirty();
      setState(_markDirty);
      return true;
    }
    return false;
  }
}
