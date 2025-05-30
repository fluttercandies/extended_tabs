import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:extended_tabs_example/extended_tabs_example_route.dart';
import 'package:extended_tabs_example/extended_tabs_example_routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'extended_tabs demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.fluttercandiesMainpage,
      onGenerateRoute: (RouteSettings settings) {
        return onGenerateRoute(
          settings: settings,
          getRouteSettings: getRouteSettings,
          routeSettingsWrapper: (FFRouteSettings ffRouteSettings) {
            if (ffRouteSettings.name == Routes.fluttercandiesMainpage ||
                ffRouteSettings.name == Routes.fluttercandiesDemogrouppage) {
              return ffRouteSettings;
            }
            return ffRouteSettings.copyWith(
              builder: () => CommonWidget(
                title: ffRouteSettings.routeName,
                child: ffRouteSettings.builder(),
              ),
            );
          },
        );
      },
    );
  }
}

class CommonWidget extends StatelessWidget {
  const CommonWidget({
    super.key,
    this.child,
    this.title,
  });

  final Widget? child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title!,
        ),
      ),
      body: child,
    );
  }
}
