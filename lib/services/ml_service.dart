import 'dart:io';

import 'package:facial_authentication/utilities/export_packages.dart';

class MLService {
  Interpreter? _interpreter;
  double threshold = .5;

  final List _predictedData = [];
  List get predictedData => _predictedData;

  Future initialize() async {
    Delegate? delegate;
    if (Platform.isAndroid) {
      delegate = GpuDelegateV2(
          options: GpuDelegateOptionsV2(
              isPrecisionLossAllowed: false,
              inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
              inferencePriority1: TfLiteGpuInferencePriority.minLatency,
              inferencePriority2: TfLiteGpuInferencePriority.auto,
              inferencePriority3: TfLiteGpuInferencePriority.auto));
    } else if (Platform.isIOS) {
      delegate = GpuDelegate(
          options: GpuDelegateOptions(
              allowPrecisionLoss: true,
              waitType: TFLGpuDelegateWaitType.active));
    }
    InterpreterOptions interpreterOptions = InterpreterOptions()
      ..addDelegate(delegate!);
    _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite',
        options: interpreterOptions);
  }
}
