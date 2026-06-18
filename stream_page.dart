import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'nf.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});
  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  bool _running = false;
  int  _count   = 0;
  final _log    = <String>[];
  final _scroll = ScrollController();
  StreamSubscription? _sub;

  Future<void> _start() async {
    // mask: 表6-1の重みの和 (X=8, Y=16, R=32, θ=64 → X+Y=24)
    // period: 記録間隔[秒] 0.4µs〜26.4ms (1パラメタ当たり0.4µs)
    await nfCmd.invokeMethod('startStream', {'mask': 24, 'period': '1E-3'});
    _sub = nfData.receiveBroadcastStream().listen(_recv);
    setState(() { _running = true; _log.clear(); _count = 0; });
  }

  Future<void> _stop() async {
    await _sub?.cancel(); _sub = null;
    await nfCmd.invokeMethod('stop');
    setState(() => _running = false);
  }

  void _recv(dynamic raw) {
    final v = raw is Float64List ? raw : Float64List.fromList((raw as List).cast());
    final lines = <String>[];
    for (int i = 0; i + 1 < v.length; i += 2) {
      lines.add('${_count + i ~/ 2}  '
        'X=${v[i].toStringAsExponential(6)}  '
        'Y=${v[i + 1].toStringAsExponential(6)}');
    }
    setState(() {
      _count += v.length ~/ 2;
      _log.addAll(lines);
      if (_log.length > 2000) _log.removeRange(0, _log.length - 2000);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() { _sub?.cancel(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        ElevatedButton(onPressed: _running ? null : _start, child: const Text('開始')),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _running ? _stop : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('停止'),
        ),
        const Spacer(),
        Text('$_count pts', style: const TextStyle(color: Colors.greenAccent)),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => setState(() { _log.clear(); _count = 0; }),
        ),
      ]),
    ),
    Expanded(child: ListView.builder(
      controller: _scroll,
      itemCount: _log.length,
      itemBuilder: (_, i) => Text(_log[i],
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white70)),
    )),
  ]);
}
