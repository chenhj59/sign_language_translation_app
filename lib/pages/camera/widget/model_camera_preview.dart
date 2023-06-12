import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../services/model_inference_service.dart';
import '../../../services/service_locator.dart';
import 'hands_painter.dart';
import '../../../services/hands/hands_service.dart';
import '../../../services/ai_model.dart';

class ModelCameraPreview extends StatelessWidget {
  ModelCameraPreview({
    required this.cameraController,
    required this.draw,
    Key? key,
  }) : super(key: key);

  final CameraController? cameraController;
  final bool draw;
  var result;
  late AiModel model;

  late final double _ratio;
  final Map<String, dynamic>? inferenceResults =
      locator<ModelInferenceService>().inferenceResults;

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size; //获取屏幕尺寸
    _ratio = screenSize.width / cameraController!.value.previewSize!.height;
    //Visibility 主要有三种状态：visible、invisible 和 gone。
    // 当 Visibility 的属性设置为 visible 时，其中包含的子 Widget 会显示在界面上；
    // 而当属性设置为 invisible 时，子 Widget 仍然存在，但是不可见，其占用的空间不会被释放；
    // 当属性设置为 gone 时，子 Widget 不仅不可见，而且不再占用空间，它们在界面中被完全移除。
    return Stack(
      children: [
        CameraPreview(cameraController!),
        Visibility(
          visible: draw,
          child: IndexedStack(
            children: [
              _drawHands,
            ],
          ),
        ),
      ],
    );
  }

  Widget get _drawHands => _ModelPainter(
        customPainter: HandsPainter(
          points: inferenceResults?['point'] ?? [],
          ratio: _ratio,
        ),
      );

}

class _ModelPainter extends StatelessWidget {
  _ModelPainter({
    required this.customPainter,
    Key? key,
  }) : super(key: key);

  final CustomPainter customPainter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: customPainter,
    );
  }
}
