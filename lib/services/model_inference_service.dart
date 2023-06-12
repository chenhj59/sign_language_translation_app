import 'dart:isolate';

import 'package:camera/camera.dart';

import '../utils/isolate_utils.dart';
import 'ai_model.dart';
import 'hands/hands_service.dart';
import 'service_locator.dart';

enum Models {
  FaceDetection,
  FaceMesh,
  Hands,
  Pose,
}

class ModelInferenceService {
  late AiModel model;
  late Function handler;
  Map<String, dynamic>? inferenceResults;

  Future<Map<String, dynamic>?> inference({
    required IsolateUtils isolateUtils,
    required CameraImage cameraImage,
  }) async {
    final responsePort = ReceivePort();

    // 主Isolate发送视频
    isolateUtils.sendMessage(
      handler: handler,
      params: {
        'cameraImage': cameraImage,
        'detectorAddress': model.getAddress,
      },
      sendPort: isolateUtils.sendPort,
      responsePort: responsePort,
    );

    inferenceResults = await responsePort.first; //处理结果
    responsePort.close();
  }

  void setModelConfig() {
        model = locator<Hands>();
        handler = runHandDetector;
  }
}
