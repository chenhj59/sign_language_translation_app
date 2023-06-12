import 'dart:isolate';

/*
这段代码实现了一个 Dart 中的 Isolate 通信工具类 IsolateUtils，
可以在不同的 Isolate 之间进行消息传递和函数调用。
Isolate 是 Dart 中的一种并发机制，它可以让开发者在不同的线程或进程中运行不同的代码，
以提高应用程序的性能和效率。
 */
class IsolateUtils {
  Isolate? _isolate; //存储创建的 Isolate 对象；
  late SendPort _sendPort;//存储发送消息的端口；
  late ReceivePort _receivePort;// 存储接收消息的端口。

  SendPort get sendPort => _sendPort;

  Future<void> initIsolate() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn<SendPort>(
      _entryPoint,
      _receivePort.sendPort,
    );

    _sendPort = await _receivePort.first;
  }

  static void _entryPoint(SendPort mainSendPort) async {
    final childReceivePort = ReceivePort();
    mainSendPort.send(childReceivePort.sendPort);

    // 调用模型处理数据。等待主Isolate发送的消息，执行handler(函数类型)后，再返回给主Isolate
    await for (final _IsolateData? isolateData in childReceivePort) {
      if (isolateData != null) {
        final results = isolateData.handler(isolateData.params);
        isolateData.responsePort.send(results);
      }
    }
  }

  void sendMessage({
    required Function handler,
    required Map<String, dynamic> params,
    required SendPort sendPort,
    required ReceivePort responsePort,
  }) {
    final isolateData = _IsolateData(
      handler: handler,
      params: params,
      responsePort: responsePort.sendPort,
    );
    sendPort.send(isolateData);
  }

  void dispose() {
    _receivePort.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}

class _IsolateData {
  Function handler;
  Map<String, dynamic> params;
  SendPort responsePort;

  _IsolateData({
    required this.handler,
    required this.params,
    required this.responsePort,
  });
}
