import 'package:flutter/material.dart';
import 'nf.dart';

class CommandPage extends StatefulWidget {
  const CommandPage({super.key});
  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  final _ctrl = TextEditingController();
  final _log  = <({String cmd, String resp})>[];

  Future<void> _send() async {
    final cmd = _ctrl.text.trim();
    if (cmd.isEmpty) return;
    _ctrl.clear();
    final resp = await nfCmd.invokeMethod<String>('query', {'cmd': cmd}) ?? '';
    setState(() => _log.add((cmd: cmd, resp: resp)));
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _log.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('> ${_log[i].cmd}',
            style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace')),
          Text(_log[i].resp.isEmpty ? '(応答なし)' : _log[i].resp,
            style: const TextStyle(color: Colors.white70, fontFamily: 'monospace')),
        ]),
      ),
    )),
    Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _ctrl,
          decoration: const InputDecoration(
            hintText: 'コマンド入力 (例: *IDN?)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _send(),
        )),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _send, child: const Text('送信')),
      ]),
    ),
  ]);
}
