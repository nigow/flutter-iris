import 'package:flutter/services.dart';

class CoreMLService {
  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_coreml/coreml');

  static final CoreMLService _instance = CoreMLService._internal();

  factory CoreMLService() {
    return _instance;
  }

  CoreMLService._internal();

  Future<String?> predictIrisSpecies({
    required double sepalWidth,
    required double sepalLength,
    required double petalLength,
    required double petalWidth,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('predict', {
        'sepalLength': sepalLength,
        'sepalWidth': sepalWidth,
        'petalLength': petalLength,
        'petalWidth': petalWidth,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to predict species: ${e.message}');
      return null;
    }
  }

  Future<bool> isUsingNeuralEngine() async {
    try {
      final result = await _channel.invokeMethod<bool>('isUsingNeuralEngine');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to check Neural Engine: ${e.message}');
      return false;
    }
  }
}
