import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class GetUserMediaPage extends StatefulWidget {
  const GetUserMediaPage({Key? key}) : super(key: key);

  @override
  State<GetUserMediaPage> createState() => _GetUserMediaPageState();
}

class _GetUserMediaPageState extends State<GetUserMediaPage> {
  MediaStream? _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _isTorchOn = false;

  List<MediaDeviceInfo>? _mediaDevicesList;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
  }

  void _hangUp() async {
    try {
      await _localStream?.dispose();
      _localRenderer.srcObject = null;
      setState(() {
        _inCalling = false;
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30'
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      MediaStream stream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      log(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _inCalling = true;
    });
  }

  void _toggleTorch() async {
    if (_localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = _localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final hasTorch = await videoTrack.hasTorch();
    if (hasTorch) {
      log('[TORCH] Current camera supports torch mode');
      setState(() => _isTorchOn = !_isTorchOn);
      await videoTrack.setTorch(_isTorchOn);
      log('[TORCH] Torch state is now ${_isTorchOn ? 'on' : 'off'}');
    } else {
      log('[TORCH] Current camera does not support torch mode');
    }
  }

  void _toggleCamera() async {
    if (_localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = _localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await Helper.switchCamera(videoTrack);
  }

  void _captureFrame() async {
    if (_localStream == null) throw Exception('Stream is not initialized');

    final videoTrack = _localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final frame = await videoTrack.captureFrame();
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Image.memory(
                frame.asUint8List(),
                height: 720,
                width: 1280,
              ),
              actions: [
                TextButton(
                    onPressed: Navigator.of(context, rootNavigator: true).pop,
                    child: const Text('OK'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetUserMedia'),
        actions: _inCalling
            ? <Widget>[
                IconButton(
                    onPressed: _toggleTorch,
                    icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on)),
                IconButton(
                    onPressed: _toggleCamera, icon: Icon(Icons.switch_video)),
                IconButton(onPressed: _captureFrame, icon: Icon(Icons.camera)),
                PopupMenuButton<String>(
                    onSelected: (String deviceId) =>
                        _localRenderer.audioOutput(deviceId),
                    itemBuilder: (BuildContext context) {
                      if (_mediaDevicesList != null) {
                        return _mediaDevicesList!
                            .where((device) => device.kind == 'audiooutput')
                            .map((device) => PopupMenuItem(
                                value: device.deviceId,
                                child: Text(device.label)))
                            .toList();
                      }
                      return [];
                    })
              ]
            : null,
      ),
      body: Center(
        child: Container(
            margin: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(color: Colors.black54),
            child: RTCVideoView(
              _localRenderer,
              mirror: true,
            )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'HangUp' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
