import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'camera_screen.dart';
import '../../../services/service_locator.dart';
import '../../../services/model_inference_service.dart';
class HomePage extends StatelessWidget {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手语翻译'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: (){
              locator<ModelInferenceService>().setModelConfig();
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
          child: Stack(
            children: [
              Expanded(
                flex: 9,
                 child: Image.asset('assets/images/1.png',
                   fit: BoxFit.cover,
                   height: 900,),
              ),
             Expanded(
               flex: 1,
                 child: Container(
                     child:Align(
                         alignment: Alignment.bottomCenter,
                         child: TextField(
                           controller: myController, //myController.text输入内容
                           decoration: const InputDecoration(
                             hintText: "请输入要转换为手语的中文",
                           ),
                         )
                     )
                 ),
               ),
          ],
        )
      ),
    );
  }
}

