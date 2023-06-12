import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/model_inference_service.dart';
import '../../services/service_locator.dart';
import '../../utils/isolate_utils.dart';
import 'camera/widget/model_camera_preview.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  int _selectedCameraIndex = 0;
  late IsolateUtils _isolateUtils;
  late ModelInferenceService _modelInferenceService;
  late bool _isRun;
  bool _predicting = false;
  bool _draw = false;

  @override
  void initState() {
    _modelInferenceService = locator<ModelInferenceService>();
    _initStateAsync();
    super.initState();
    // 获取可用的摄像头列表
    availableCameras().then((value) {
      setState(() {
        _cameras = value;
        // 默认使用后置摄像头
        _controller = CameraController(
            _cameras[_selectedCameraIndex], ResolutionPreset.medium);
        _controller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      });
    });
  }

  void _initStateAsync() async {
    _isolateUtils = IsolateUtils();
    await _isolateUtils.initIsolate();
    _predicting = false;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleCamera() {
    setState(() {
      _draw = false;
    });
    _isRun = false;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      _controller = CameraController(
          _cameras[_selectedCameraIndex], ResolutionPreset.medium);
      _controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: ModelCameraPreview(
        cameraController: _controller,
        draw: _draw,
      ),
      floatingActionButton: _buildFloatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // 悬浮按钮
  Row get _buildFloatingActionButton => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        verticalDirection: VerticalDirection.up,
        children: [
          Column(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            verticalDirection: VerticalDirection.up,
            children: [
              IconButton(
                onPressed: () => _imageStreamToggle,
                color: Colors.black54,
                iconSize: ScreenUtil().setWidth(30.0),
                icon: const Icon(
                  Icons.filter_center_focus,
                ),
              ),

              const SizedBox(height: 40), // 控制组件的距离

              Text('我是识别出来后文字显示得地方', style: TextStyle(color: Colors.black54))
            ],
          )
        ],
      );
  /*
  这是一个私有方法，名为 _imageStreamToggle ，用于切换 _draw 布尔类型的状态，并启动或停止相机图像流。
首先，调用 setState 函数将 _draw 状态值取反，并重建视图。然后根据 _isRun 的值决定是要启动还是停止相机图像流。
如果 _isRun 为 true，则使用 startImageStream 函数启动相机图像流，并将回调函数设置为 _inference 函数。
_inference 函数用于对相机捕获的图像进行推断和处理。如果 _isRun 为 false，则调用 stopImageStream 函数停止相机图像流。
   */
  void get _imageStreamToggle {
    setState(() {
      _draw = !_draw;
    });
    _isRun = !_isRun;
    if (_isRun) {
      _controller!.startImageStream(
        (CameraImage cameraImage) async =>
            await _inference(cameraImage: cameraImage),
      );
    } else {
      _controller!.stopImageStream();
    }
  }

  Future<void> _inference({required CameraImage cameraImage}) async {
    if (!mounted) return;

    if (_modelInferenceService.model.interpreter != null) {
      if (_predicting || !_draw) {
        return;
      }

      setState(() {
        _predicting = true;
      });

      if (_draw) {
        await _modelInferenceService.inference(
          isolateUtils: _isolateUtils,
          cameraImage: cameraImage,
        );
      }

      setState(() {
        _predicting = false;
      });
    }
  }
}
