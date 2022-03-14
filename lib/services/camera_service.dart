import 'dart:ui';

import 'package:facial_authentication/utilities/export_packages.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => _cameraRotation;

  String? _imagePath;
  String? get imagePath => _imagePath;

  Future<void> initialize() async {
    if (_cameraController != null) return;
    CameraDescription description = await _getCameraDescription();
    await _setupCameraController(cameraDescription: description);
    _cameraRotation =
        rotationIntToImageRotation(rotation: description.sensorOrientation);
  }

  Future<CameraDescription> _getCameraDescription() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere((CameraDescription camera) =>
        camera.lensDirection == CameraLensDirection.front);
  }

  Future _setupCameraController(
      {required CameraDescription cameraDescription}) async {
    _cameraController = CameraController(
        cameraDescription, ResolutionPreset.high,
        enableAudio: false);
    await _cameraController!.initialize();
  }

  InputImageRotation rotationIntToImageRotation({required int rotation}) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  Future<XFile> takePicture() async {
    await _cameraController!.stopImageStream();
    XFile file = await _cameraController!.takePicture();
    _imagePath = file.path;
    return file;
  }

  Size getImageSize() {
    assert(_cameraController != null, 'Camera controller not initialized');
    return Size(
      _cameraController!.value.previewSize!.height,
      _cameraController!.value.previewSize!.width,
    );
  }

  dispose() async {
    await _cameraController!.dispose();
    _cameraController = null;
  }
}
