import 'package:flutter/material.dart';
import 'package:test_webrtc/pages/get_display_media_page.dart';
import 'package:test_webrtc/pages/get_loop_back_page.dart';
import 'package:test_webrtc/pages/get_user_media_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        itemCount: routes.length,
        itemBuilder: (context, index) => ListBody(
          children: [
            ListTile(
              title: Text(routes[index].title),
              onTap: () => routes[index].navigate(context),
              trailing: const Icon(Icons.arrow_right),
            ),
            const Divider()
          ],
        ),
      ),
    );
  }
}

class Route {
  final String title;
  final void Function(BuildContext) navigate;
  const Route({required this.title, required this.navigate});
}

final routes = <Route>[
  Route(
    title: 'GetUserMedia',
    navigate: (BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const GetUserMediaPage()),
    ),
  ),
  Route(
    title: 'GetDisplayMedia',
    navigate: (BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const GetDisplayMediaPage()),
    ),
  ),
  Route(
    title: 'GetLoopBack',
    navigate: (BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const GetLoopBackPage()),
    ),
  ),
];
