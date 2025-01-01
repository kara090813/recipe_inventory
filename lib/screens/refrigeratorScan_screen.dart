import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RefrigeratorScanScreen extends StatefulWidget {
  @override
  _RefrigeratorScanScreenState createState() => _RefrigeratorScanScreenState();
}

class _RefrigeratorScanScreenState extends State<RefrigeratorScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras available');
        return;
      }
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && _controller != null) {
            return Stack(
              children: [
                _buildCameraPreview(),
                _buildOverlay(),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller == null) return Container();

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildOverlay() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.flash_on, color: Colors.white),
                        onPressed: () {/* 플래시 기능 */},
                      ),
                    ],
                  ),
                ),
                Text(
                  '냉장고 관리',
                  style: TextStyle(color: Colors.orange, fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  '냉장고 내부 식재료를 스캔해주세요!',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/imgs/background/camera_frame.png',
                      width: 300.w,
                      height: 300.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인식된 식재료',
                    style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: Center(
                      child: Text('인식된 식재료가 여기에 표시됩니다.'),
                    ),
                  ),
                  ElevatedButton(
                    child: Text(
                      '스캔 종료',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}