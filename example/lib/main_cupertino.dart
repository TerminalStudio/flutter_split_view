// ignore_for_file: prefer_const_constructors,
// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter_split_view/flutter_split_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter Demo',
      home: SplitView.cupertino(
        child: MainPage(),
        title: 'Home',
        placeholder: PlaceholderPage(),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Home'),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              child: Text('pushMain'),
              onPressed: () {
                SplitView.of(context).pushMain(
                  SecondPage(),
                  title: 'Second',
                );
              },
            ),
            CupertinoButton(
              child: Text('pushSide'),
              onPressed: () {
                SplitView.of(context).pushSide(
                  SecondPage(),
                  title: 'Second',
                );
              },
            ),
            CupertinoButton(
              child: Text('setSide'),
              onPressed: () {
                SplitView.of(context).setSide(
                  SecondPage(),
                  title: 'Second',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Second'),
      ),
      child: Center(
        child: Builder(builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                child: Text('pushMain'),
                onPressed: () {
                  SplitView.of(context).pushMain(
                    ThirdPage(),
                    title: 'Third',
                  );
                },
              ),
              CupertinoButton(
                child: Text('pushSide'),
                onPressed: () {
                  SplitView.of(context).pushSide(
                    ThirdPage(),
                    title: 'Third',
                  );
                },
              ),
              CupertinoButton(
                child: Text('setSide'),
                onPressed: () {
                  SplitView.of(context).setSide(
                    ThirdPage(),
                    title: 'Third',
                  );
                },
              ),
              CupertinoButton(
                child: Text('pop'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Third'),
      ),
      child: Center(
        child: Builder(builder: (context) {
          return CupertinoButton(
            child: Text('pop'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        }),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.secondarySystemBackground,
      child: Center(
        child: Text(
          'Click the button in main view to push to here',
          style: TextStyle(
            fontSize: 16,
            color: CupertinoColors.inactiveGray,
          ),
        ),
      ),
    );
  }
}
