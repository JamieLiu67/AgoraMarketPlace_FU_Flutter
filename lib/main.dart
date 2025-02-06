import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'authpack.dart' as authpack;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

const rtcAppId =
    '59535f1fe3e64f3b864ae7a55bbd3196'; //------------ Need DIY -------------

// REMINDER: Update this value for ai_face_processor.bundle if the FaceUnity sdk be updated.
const aiFaceProcessorType = 1 << 8;
const aiHandProcessorType = 1 << 3;
const aiHumanProcessorType = 1 << 9;

const beautyPath = 'Resource/graphics/face_beautification.bundle';
const stickerPath = 'Resource/effect/normal/cat_sparks.bundle';
const aiFaceProcessorPath = 'Resource/model/ai_face_processor.bundle';
const aiHandProcessorPath = 'Resource/model/ai_hand_processor.bundle';
const aiHumanProcessorPath = 'Resource/model/ai_human_processor.bundle';
const aiTypePath = 'Resource/others/aitype.bundle';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FaceUnity Extension Example'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        body: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final RtcEngine _rtcEngine;
  late final RtcEngineEventHandler _rtcEngineEventHandler;

  bool _isReadyPreview = false;
  bool _enableExtension = true;
  bool _enableAITracking = false;
  bool _enableSticker = false;
  bool _enableComposer = false;

  double _colorLevel = 0.5;
  double _filterLevel = 0.5;

  int _facesNum = 0;
  int _handsNum = 0;
  int _peopleNum = 0;
  int rtcEnginebuild = 0;

  String rtcEngineVersion = 'Loading...';
  String fuVersion = 'Loading...';

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<void> _init() async {
    await _requestPermissionIfNeed();
    _rtcEngine = createAgoraRtcEngine();
    await _rtcEngine.initialize(const RtcEngineContext(
      appId: rtcAppId,
      logConfig: LogConfig(level: LogLevel.logLevelInfo),
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _rtcEngineEventHandler = RtcEngineEventHandler(
      onExtensionEventWithContext:
          (ExtensionContext context, String key, String value) {
        debugPrint(
            '[onExtensionEventWithContext] ExtensionContext: $context, key: $key, value: $value');

        final jsonObj = jsonDecode(value);

        if (key == 'fuIsTracking') {
          setState(() {
            _facesNum = jsonObj["faces"];
          });
        } else if (key == 'fuHandDetectorGetResultNumHands') {
          setState(() {
            _handsNum = jsonObj["hands"];
          });
        } else if (key == 'fuHumanProcessorGetNumResults') {
          setState(() {
            _peopleNum = jsonObj["people"];
          });
        }
      },
      onExtensionStartedWithContext: (ExtensionContext context) {
        debugPrint(
            '[onExtensionStartedWithContext] ExtensionContext: $context');
        if (context.providerName == 'FaceUnity' &&
            context.extensionName == 'Effect') {
          _initFUExtension();
        }
      },
      onExtensionErrorWithContext:
          (ExtensionContext context, int error, String message) {
        debugPrint(
            '[onExtensionErrorWithContext] ExtensionContext: $context, error: $error, message: $message');
      },
    );
    _rtcEngine.registerEventHandler(_rtcEngineEventHandler);
    await _loadVersion();

    // On Android, you should load libAgoraFaceUnityExtension.so explicitly
    if (Platform.isAndroid) {
      await _rtcEngine.loadExtensionProvider(
          path: 'AgoraFaceUnityExtension', unloadAfterUse: false);
    }
    // BugFixed: U should call enableExtension True first;
    await _rtcEngine.enableExtension(
        provider: "FaceUnity", extension: "Effect", enable: _enableExtension);

    await _rtcEngine.enableVideo();
    await _rtcEngine.startPreview();

    setState(() {
      _isReadyPreview = true;
    });
  }

  Future<void> _requestPermissionIfNeed() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
  }

  Future<void> _loadVersion() async {
    var sdkversion = await _rtcEngine.getVersion();
    rtcEngineVersion = sdkversion.version ?? 'None';
    rtcEnginebuild = sdkversion.build ?? 0;
  }

  Future<void> _initFUExtension() async {
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuSetup',
        value: jsonEncode({'authdata': authpack.gAuthPackage}));

    fuVersion = await _rtcEngine.getExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuGetVersion',
        type: MediaSourceType.primaryCameraSource,
        bufLen: 256);

    _loadAIModels();
  }

  Future<void> _loadAIModels() async {
    final aiFaceProcessorRealPath = await _copyAsset(aiFaceProcessorPath);
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuLoadAIModelFromPackage',
        value: jsonEncode(
            {'data': aiFaceProcessorRealPath, 'type': aiFaceProcessorType}));

    final aiHandProcessorRealPath = await _copyAsset(aiHandProcessorPath);
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuLoadAIModelFromPackage',
        value: jsonEncode(
            {'data': aiHandProcessorRealPath, 'type': aiHandProcessorType}));

    final aiHumanProcessorRealPath = await _copyAsset(aiHumanProcessorPath);
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuLoadAIModelFromPackage',
        value: jsonEncode(
            {'data': aiHumanProcessorRealPath, 'type': aiHumanProcessorType}));

    final aiTypeRealPath = await _copyAsset(aiTypePath);
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuCreateItemFromPackage',
        value: jsonEncode({'data': aiTypeRealPath}));
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuItemSetParam',
        value: jsonEncode({
          'obj_handle': aiTypeRealPath,
          'name': "aitype",
          "value": 1 << 8 | 16777216 | 1 << 4 | 1 << 9 | 1 << 30 | 1 << 3,
        }));
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    _rtcEngine.unregisterEventHandler(_rtcEngineEventHandler);
    await _rtcEngine.release();
  }

  Future<String> _copyAsset(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    Directory appDocDir = await getApplicationDocumentsDirectory();

    final dirname = path.dirname(assetPath);

    Directory dstDir = Directory(path.join(appDocDir.path, dirname));
    if (!(await dstDir.exists())) {
      await dstDir.create(recursive: true);
    }

    String p = path.join(appDocDir.path, path.basename(assetPath));
    final file = File(p);
    if (!(await file.exists())) {
      await file.create();
      await file.writeAsBytes(bytes);
    }

    return file.absolute.path;
  }

  Future<void> _enableStickerEffect() async {
    final stickerRealPath = await _copyAsset(stickerPath);
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuCreateItemFromPackage',
        value: jsonEncode({'data': stickerRealPath}));
  }

  Future<void> _disableStickerEffect() async {
    final stickerRealPath = await _copyAsset(stickerPath);
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuDestroyItem',
        value: jsonEncode({'item': stickerRealPath}));
  }

  Future<void> _enableComposerEffect() async {
    final bundleRealPath = await _copyAsset(beautyPath);
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuCreateItemFromPackage',
        value: jsonEncode({'data': bundleRealPath}));
  }

  Future<void> _disableComposerEffect() async {
    final bundleRealPath = await _copyAsset(beautyPath);
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuDestroyItem',
        value: jsonEncode({'item': bundleRealPath}));
  }

  Future<void> _setComposerStuff(double colorValue, double filterValue) async {
    final bundleRealPath = await _copyAsset(beautyPath);
    //Face slimming effects - 瘦脸
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuItemSetParam',
        value: jsonEncode({
          'obj_handle': bundleRealPath,
          'name': "cheek_thinning",
          'value': 0.5,
        }));

    //Filter - 滤镜
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuItemSetParam',
        value: jsonEncode({
          'obj_handle': bundleRealPath,
          'name': "filter_name",
          'value': "gexing11",
        }));

    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuItemSetParam',
        value: jsonEncode({
          'obj_handle': bundleRealPath,
          'name': "filter_level",
          'value': filterValue,
        }));
    //

    //Beauty - 美颜_红润
    await _rtcEngine.setExtensionProperty(
        provider: 'FaceUnity',
        extension: 'Effect',
        key: 'fuItemSetParam',
        value: jsonEncode({
          'obj_handle': bundleRealPath,
          'name': "color_level",
          'value': colorValue,
        }));
    //
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReadyPreview) {
      return Container();
    } else {
      return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          AgoraVideoView(
              controller: VideoViewController(
            rtcEngine: _rtcEngine,
            canvas: const VideoCanvas(uid: 0),
          )),
          Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(flex: 1, child: Container()),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Agora RTC SDK: $rtcEngineVersion($rtcEnginebuild)',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'FaceUnity SDK: $fuVersion',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  _enableAITracking
                      ? Text(
                          "faces: $_facesNum",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        )
                      : Container(),
                  _enableAITracking
                      ? Text(
                          "hands: $_handsNum",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        )
                      : Container(),
                  _enableAITracking
                      ? Text(
                          "people: $_peopleNum",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        )
                      : Container(),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    onPressed: () async {
                      setState(() {
                        _enableExtension = !_enableExtension;
                      });

                      await _rtcEngine.enableExtension(
                          provider: "FaceUnity",
                          extension: "Effect",
                          enable: _enableExtension);
                    },
                    child: Text(_enableExtension
                        ? 'disableExtension'
                        : 'enableExtension'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    onPressed: () async {
                      setState(() {
                        _enableAITracking = !_enableAITracking;
                      });

                      if (_enableAITracking) {
                        await _rtcEngine.setExtensionProperty(
                            provider: 'FaceUnity',
                            extension: 'Effect',
                            key: 'fuSetMaxFaces',
                            value: jsonEncode({
                              'n': 5,
                            }));

                        await _rtcEngine.setExtensionProperty(
                            provider: 'FaceUnity',
                            extension: 'Effect',
                            key: 'fuIsTracking',
                            value: jsonEncode({
                              'enable': true,
                            }));

                        await _rtcEngine.setExtensionProperty(
                            provider: 'FaceUnity',
                            extension: 'Effect',
                            key: 'fuHumanProcessorGetNumResults',
                            value: jsonEncode({
                              'enable': true,
                            }));

                        await _rtcEngine.setExtensionProperty(
                            provider: 'FaceUnity',
                            extension: 'Effect',
                            key: 'fuHumanProcessorSetMaxHumans',
                            value: jsonEncode({
                              'max_humans': 5,
                            }));

                        await _rtcEngine.setExtensionProperty(
                            provider: 'FaceUnity',
                            extension: 'Effect',
                            key: 'fuHandDetectorGetResultNumHands',
                            value: jsonEncode({
                              'enable': true,
                            }));
                      }
                    },
                    child: Text(_enableAITracking
                        ? 'disableAITracking'
                        : 'enableAITracking'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.cyan),
                    onPressed: () async {
                      setState(() {
                        _enableSticker = !_enableSticker;
                      });

                      if (_enableSticker) {
                        _enableStickerEffect();
                      } else {
                        _disableStickerEffect();
                      }
                    },
                    child: Text(
                        _enableSticker ? 'disableSticker' : 'enableSticker'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.yellow),
                    onPressed: () async {
                      setState(() {
                        _enableComposer = !_enableComposer;
                      });

                      if (_enableComposer) {
                        _enableComposerEffect();
                        _setComposerStuff(_colorLevel, _filterLevel);
                      } else {
                        _disableComposerEffect();
                      }
                    },
                    child: Text(
                        _enableComposer ? 'disableComposer' : 'enableComposer'),
                  ),
                  const Text('Color Level:', textAlign: TextAlign.left),
                  Slider(
                      value: _colorLevel,
                      onChanged: _enableComposer
                          ? (double value) async {
                              setState(() {
                                _colorLevel = value;
                              });

                              _setComposerStuff(_colorLevel, _filterLevel);
                            }
                          : null),
                  const Text('Filter Level:', textAlign: TextAlign.left),
                  Slider(
                      value: _filterLevel,
                      onChanged: _enableComposer
                          ? (double value) async {
                              setState(() {
                                _filterLevel = value;
                              });

                              _setComposerStuff(_colorLevel, _filterLevel);
                            }
                          : null),
                ],
              ),
            ],
          ),
        ],
      );
    }
  }
}
