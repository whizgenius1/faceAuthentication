import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:facial_authentication/models/user_model.dart';
import 'package:facial_authentication/services/image_converter.dart';
import 'package:facial_authentication/utilities/export_files.dart';
import 'package:facial_authentication/utilities/export_packages.dart';
import 'package:image/image.dart' as image_library;

class MLService {
  Interpreter? _interpreter;
  double threshold = .5;

  List _predictedData = [];
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

  setCurrentPrediction({required CameraImage cameraImage, required Face face}) {
    List input = _preProcessImage(cameraImage: cameraImage, face: face);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter!.run(input, output);
    output = output.reshape([192]);
    _predictedData = List.from(output);
  }

  Future<UserModel> predict() async =>
      await _searchUserResult(predictedData: predictedData);

  List _preProcessImage(
      {required CameraImage cameraImage, required Face face}) {
    image_library.Image croppedImage =
        _cropFace(cameraImage: cameraImage, faceDetected: face);
    image_library.Image image =
        image_library.copyResizeCropSquare(croppedImage, 112);

    Float32List imageAsList = imageToByteListFloat32(image: image);

    return imageAsList;
  }

  image_library.Image _cropFace(
      {required CameraImage cameraImage, required Face faceDetected}) {
    image_library.Image convertedImage =
        _convertCameraImage(cameraImage: cameraImage);
    double x = faceDetected.boundingBox.left - 10;
    double y = faceDetected.boundingBox.top - 10;
    double w = faceDetected.boundingBox.width + 10;
    double h = faceDetected.boundingBox.height + 10;

    return image_library.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  image_library.Image _convertCameraImage({required CameraImage cameraImage}) {
    image_library.Image image = convertToImage(cameraImage: cameraImage);
    image_library.Image image2 = image_library.copyRotate(image, -90);
    return image2;
  }

  Float32List imageToByteListFloat32({required image_library.Image image}) {
    Float32List convertedBytes = Float32List(1 * 112 * 112 * 3);
    Float32List buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int i = 0; i < 112; i++) {
      for (int j = 0; j < 112; j++) {
        int pixel = image.getPixel(j, 1);
        buffer[pixelIndex++] = (image_library.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (image_library.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (image_library.getBlue(pixel) - 128) / 128;
      }
    }

    return convertedBytes.buffer.asFloat32List();
  }

  Future<UserModel> _searchUserResult({required List predictedData}) async {
    UserDatabase _userDatabase = UserDatabase.instance;

    List<UserModel> userModel = await _userDatabase.queryAllUsers();
    double minDist = 999;
    double currDist = 0.0;
    UserModel predictedResult =
        UserModel(user: '', password: '', modelData: []);

    for (UserModel users in userModel) {
      currDist = _euclideanDistance(e1: users.modelData, e2: predictedData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predictedResult = users;
      }
    }
    return predictedResult;
  }

  ///formula to calculate camera distance to face
  double _euclideanDistance({required List e1, required List e2}) {
    if (e1.isEmpty || e2.isEmpty) throw Exception("Null argument");

    double sum = 0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow(e1[i] = e2[i], 2);
    }

    return sqrt(sum);
  }

  void setPredictedData({required List value}) {
    _predictedData = value;
  }

  dispose() {
    _interpreter!.close();
  }
}
