import 'package:flutter/material.dart';
import 'nf.dart';
import 'command_page.dart';
import 'stream_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _connected = false;

  Future<void> _connect() async {
    final ok = await nfCmd.invokeMethod<bool>('connect') ?? false;
    setState(() => _connected = ok);
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(radius: 5, backgroundColor: _connected ? Colors.green : Colors.red),
          const SizedBox(width: 10),
          const Text('NF TYO70856'),
        ]),
        actions: [
          if (!_connected)
            IconButton(icon: const Icon(Icons.usb), tooltip: '接続', onPressed: _connect),
        ],
        bottom: const TabBar(tabs: [
          Tab(icon: Icon(Icons.terminal), text: 'コマンド'),
          Tab(icon: Icon(Icons.list),     text: 'ストリーム'),
        ]),
      ),
      body: const TabBarView(children: [CommandPage(), StreamPage()]),
    ),
  );
}
