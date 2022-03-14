import 'package:facial_authentication/utilities/export_files.dart';
import 'package:facial_authentication/utilities/export_packages.dart';
import 'package:facial_authentication/utilities/export_services.dart';
import 'package:flutter/cupertino.dart';

class FaceDetectionService {
  final CameraService _cameraService = locator<CameraService>();

  FaceDetector? _faceDetector;
  FaceDetector? get faceDetector => _faceDetector;

  List<Face> _faces = [];
  List<Face> get faces => _faces;

  bool get faceDetected => _faces.isNotEmpty;

  void initialize() {
    _faceDetector = GoogleMlKit.vision.faceDetector(
        const FaceDetectorOptions(mode: FaceDetectorMode.accurate));
  }

  Future<void> detectFaceFromImage({required CameraImage cameraImage}) async {
    InputImageData _firstImage = InputImageData(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        inputImageFormat:
            InputImageFormatMethods.fromRawValue(cameraImage.format.raw)!,
        imageRotation: _cameraService.cameraRotation!,
        planeData: cameraImage.planes
            .map((Plane plane) => InputImagePlaneMetadata(
                  bytesPerRow: plane.bytesPerRow,
                  height: plane.height,
                  width: plane.width,
                ))
            .toList());
    InputImage _firebaseVisionImage = InputImage.fromBytes(
        bytes: cameraImage.planes[0].bytes, inputImageData: _firstImage);

    _faces = await _faceDetector!.processImage(_firebaseVisionImage);
  }

  dispose() {
    _faceDetector!.close();
  }
}
