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
        child: CupertinoButton(
          child: Text('click'),
          onPressed: () {
            SplitView.of(context).setSecondary(
              SecondPage(),
              title: 'Second',
            );
          },
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
                child: Text('back'),
                onPressed: () {
                  SplitView.of(context).pop();
                },
              ),
              CupertinoButton(
                child: Text('forward'),
                onPressed: () {
                  SplitView.of(context).push(
                    ThirdPage(),
                    title: 'Third',
                  );
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
            child: Text('back'),
            onPressed: () {
              SplitView.of(context).pop();
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
