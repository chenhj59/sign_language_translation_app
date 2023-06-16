import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';
import 'camera_screen.dart';
import '../../utils/isolate_utils.dart';
import '../../services/service_locator.dart';
import 'camera/widget/model_camera_preview.dart';
import '../../services/model_inference_service.dart';

class PhotographPage extends StatefulWidget {
  @override
  _PhotographPageState createState() => _PhotographPageState();
}

class _PhotographPageState extends State<PhotographPage> {

  File? _imageFile;
  VideoPlayerController? _controller;
  late IsolateUtils _isolateUtils;
  late ModelInferenceService _modelInferenceService;

  final picker = ImagePicker();

  @override
  void initState() {
    _modelInferenceService = locator<ModelInferenceService>();
    _initStateAsync();

  }
  void _initStateAsync() async {
    _isolateUtils = IsolateUtils();
    await _isolateUtils.initIsolate();
  }

Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      final image = Image(image: FileImage(_imageFile!));
      _controller = null;  //在选择照片时，要把视频变量赋null，这样如果前面非空也不会在显示
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _controller = VideoPlayerController.file(File(pickedFile.path))
        ..initialize().then((_) {
          setState(() {});
          _controller?.play();
        });
      _imageFile = null;  //在选择视频时，要把照片变量赋null，这样如果前面非空也不会在显示
    }
  }


  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传图片/视频'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // 显示对话框，让用户选择上传类型
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('选择上传类型'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          GestureDetector(
                            child: const Text("图片"),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickImage(); // 用户选择图片上传
                            },
                          ),
                          Padding(padding: EdgeInsets.all(8.0)),
                          GestureDetector(
                            child: const Text("视频"),
                            onTap: () {
                              Navigator.of(context).pop();
                              _pickVideo(); // 用户选择视频上传
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            })
        ],
      ),
      body: Center(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 9,
                  child: Stack(
                    children: [
                      _imageFile != null
                          ? Image.file(
                        _imageFile!,
                        height: 600,
                        width: double.infinity,
                      )
                          : SizedBox(),
                      _controller?.value?.isInitialized == true
                          ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      )
                          : SizedBox(),
                    ],
                  )
              ),
              Expanded(
                flex: 1,
                  child: Container(
                    color: Colors.white10,
                    child: Center(
                      child: Text(
                          '我是识别出来后文字显示得地方',
                              style: TextStyle(
                                color: Colors.black54
                              ),
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
      )
    );
  }
  Future<void> _inference({required CameraImage cameraImage}) async {
    if (!mounted) return;


    await _modelInferenceService.inference(
      isolateUtils: _isolateUtils,
      cameraImage: cameraImage,
    );

  }
}
