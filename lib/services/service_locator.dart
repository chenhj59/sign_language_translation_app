import 'package:get_it/get_it.dart';

import 'hands/hands_service.dart';
import 'model_inference_service.dart';


final locator = GetIt.instance;

/*
这段代码使用了 Flutter 中的依赖注入框架 get_it，用于注册和管理对象的生命周期。
在这段代码中，首先通过 registerSingleton() 方法将一个新的 FaceDetection、FaceMesh、Hands 和 Pose 对象注册成单例（Singleton），并且将其注册到 locator 对象中。
这样，在整个应用程序的生命周期内，只会创建一个 FaceDetection、FaceMesh、Hands 和 Pose 实例，其他需要使用它们的类都可以直接从 locator 对象中获取它们的实例。
接着，通过 registerLazySingleton() 方法将 ModelInferenceService 注册成为一个延迟加载的单例对象，这意味着在第一次使用时才会创建它的实例。
这种方式可以提高应用程序的性能和资源使用效率，因为仅有需要时才会创建对象。
 */
void setupLocator() {
  locator.registerSingleton<Hands>(Hands());

  locator.registerLazySingleton<ModelInferenceService>(
      () => ModelInferenceService());
}
