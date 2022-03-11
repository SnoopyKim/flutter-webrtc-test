import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class GetDisplayMediaPage extends StatefulWidget {
  const GetDisplayMediaPage({Key? key}) : super(key: key);

  @override
  State<GetDisplayMediaPage> createState() => _GetDisplayMediaState();
}

class _GetDisplayMediaState extends State<GetDisplayMediaPage> {
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  Timer? _timer;

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _stop();
    }

    _timer?.cancel();
    _localRenderer.dispose();
  }

  Future<void> _stop() async {
    try {
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _hangUp() async {
    await _stop();
    setState(() {
      _inCalling = false;
    });
    _timer?.cancel();
  }

  Future<void> _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': true,
    };

    try {
      MediaStream stream =
          await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      stream.getVideoTracks()[0].onEnded = () {
        log('By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
      };
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      log(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _inCalling = true;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetDisplayMedia'),
      ),
      body: Center(
        child: Stack(children: [
          Center(
            child: Text('counter $_counter'),
          ),
          Container(
            margin: const EdgeInsets.all(0.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(color: Colors.black54),
            child: RTCVideoView(_localRenderer),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
