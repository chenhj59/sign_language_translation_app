import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib; //解码各种图像数据
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import '../../constants/model_file.dart';
import '../../utils/image_utils.dart';
import '../ai_model.dart';

// ignore: must_be_immutable
class Hands extends AiModel {
  Hands({this.interpreter}) {
    loadModel();
  }

  final int inputSize = 224;
  final double exist_threshold = 0.001;
  final double score_threshold = 0.001;

  @override
  Interpreter? interpreter;

  @override
  List<Object> get props => [];

  @override
  int get getAddress => interpreter!.address;

  @override
  Future<void> loadModel() async {
    try {
      /*
      InterpreterOptions() 是 TensorFlow Lite 中的一个类，用于设置模型的解释器选项。具体来说，它是一个包含一系列属性的对象，这些属性影响着如何构建和运行解释器。
在使用 TensorFlow Lite 执行推理时，您通常需要为解释器提供模型文件和一组选项，以确定应如何加载和运行该模型。其中 InterpreterOptions() 类允许您设置以下选项/属性：
      ThreadNum: 设置线程池中的线程数。默认值为 1。
      UseNNAPI: 启用或禁用 NNAPI（Android 上的 Neural Networks API）。默认值为 false。
      UseXNNPACK: 启用或禁用 XNNPack（一个高效的 CPU 加速库）。默认值为 true。
      UseDelegate: 启用或禁用委托模式，在 Android 和 iOS 上可以使用 GPU 进行加速。默认值为 false。
       */
      final interpreterOptions = InterpreterOptions();

      /*
      Interpreter.fromAsset(ModelFile.hands, options: interpreterOptions) 是 TensorFlow Lite 中用于从本地资产文件加载模型并创建解释器的方法。
在这个例子中，ModelFile.hands 是一个本地资产文件的名称，它包含了模型的二进制数据。该文件必须保存在您的应用程序的 assets 文件夹下，以便可以在运行时加载模型。
interpreterOptions 是一个 InterpreterOptions() 对象，其中包含一些自定义选项和配置，用来设置解释器的行为。
       */
      interpreter ??= await Interpreter.fromAsset(ModelFile.hands,
          options: interpreterOptions);

      final outputTensors = interpreter!.getOutputTensors(); //得到输出

      outputTensors.forEach((tensor) {
        outputShapes.add(tensor.shape);
        outputTypes.add(tensor.type);
      });
    } catch (e) {
      print('Error while creating interpreter: $e');
    }
  }

  /*
  getProcessedImage() 是一个处理图像数据的方法，用于将输入图像数据进行预处理，使其适合用于 TensorFlow Lite 模型的输入。具体来说，该方法使用了 ImageProcessor 类来实现一系列对图像数据的处理操作。
在方法中，首先我们使用 ImageProcessorBuilder() 创建了一个 imageProcessor 对象，它是一个包含多个图像处理操作的管道。
然后，我们依次添加了两个图像处理操作：
ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR)：该操作将输入图像重新调整大小为指定的 inputSize，并使用双线性插值的方法进行图像缩放。
NormalizeOp(0, 255)：该操作将输入图像的像素值归一化为 0-1 范围内的数值。具体来说，它将每个像素点的数值除以 255，以得到一个 0-1 范围内的浮点数。
最后，我们使用 imageProcessor.process(inputImage) 方法将输入图像数据传递给 imageProcessor 管道，并执行上述预处理操作。处理后的图像数据将作为方法的返回值返回。
   */
  @override
  TensorImage getProcessedImage(TensorImage inputImage) {
    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        .add(NormalizeOp(0, 255))
        .build();

    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  @override
  Map<String, dynamic>? predict(image_lib.Image image) {
    if (interpreter == null) {
      print('Interpreter not initialized');
      return null;
    }

    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, -90);
      image = image_lib.flipHorizontal(image);
    }
    final tensorImage = TensorImage(TfLiteType.float32);
    tensorImage.loadImage(image);
    final inputImage = getProcessedImage(tensorImage);

    TensorBuffer outputLandmarks = TensorBufferFloat(outputShapes[0]);
    TensorBuffer outputExist = TensorBufferFloat(outputShapes[1]);
    TensorBuffer outputScores = TensorBufferFloat(outputShapes[2]);

    final inputs = <Object>[inputImage.buffer];

    final outputs = <int, Object>{
      0: outputLandmarks.buffer,
      1: outputExist.buffer,
      2: outputScores.buffer,
    };

    interpreter!.runForMultipleInputs(inputs, outputs);  //调用model

    //IOU和置信度验证
    if (outputExist.getDoubleValue(0) < exist_threshold ||
        outputScores.getDoubleValue(0) < score_threshold) {
      return null;
    }

    final landmarkPoints = outputLandmarks.getDoubleList().reshape([21, 3]);
    final landmarkResults = <Offset>[];
    for (var point in landmarkPoints) {
      landmarkResults.add(Offset(
        point[0] / inputSize * image.width,
        point[1] / inputSize * image.height,
      ));
    }

    return {'point': landmarkResults};
  }
}

Map<String, dynamic>? runHandDetector(Map<String, dynamic> params) {
  final hands =
      Hands(interpreter: Interpreter.fromAddress(params['detectorAddress']));
  final image = ImageUtils.convertCameraImage(params['cameraImage']);
  final result = hands.predict(image!);

  return result;
}
