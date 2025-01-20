import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:korean_levenshtein/korean_levenshtein.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/_models.dart';
import '../status/_status.dart';
import '../models/data.dart';

class MatchedFood {
  final Food food;
  final Rect boundingBox;

  MatchedFood(this.food, this.boundingBox);
}

class ReceiptScanScreen extends StatefulWidget {
  @override
  _ReceiptScanScreenState createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> with TickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late TextRecognizer _textRecognizer;
  File? _imageFile;
  Size? _imageSize;
  bool _isProcessing = false;
  bool _isProcessed = false;
  List<MatchedFood> _matchedFoods = [];

  List<AnimationController> _controllers = [];
  List<Animation<double>> _scaleAnimations = [];
  AnimationController? _animationStarterController;
  Animation<double>? _animationStarter;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    _controllers.forEach((controller) => controller.dispose());
    _animationStarterController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      await _processImage(File(image.path));
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

      setState(() {
        _imageFile = imageFile;
        _imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
        _matchedFoods = _matchFoods(recognizedText);
        _isProcessed = true;
      });

      _initializeAnimations();

      // 카메라 컨트롤러 해제
      await _controller?.dispose();
      _controller = null;
      _initializeControllerFuture = null;
    } catch (e) {
      print('Error processing image: $e');
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      _matchedFoods.length,
          (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      ),
    );

    _scaleAnimations = _controllers
        .map(
          (controller) => CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    )
        .toList();

    _animationStarterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _animationStarter = CurvedAnimation(
      parent: _animationStarterController!,
      curve: Curves.fastOutSlowIn,
    )..addListener(() {
      for (int i = 0; i < _matchedFoods.length; i++) {
        if (i / _matchedFoods.length <= _animationStarter!.value) {
          _controllers[i].forward();
        }
      }
    });

    _animationStarterController!.forward();
  }

  bool _isTextMatched(String text, Food food) {
    try {
      // 1. 정확한 매칭 검사
      if (text.toLowerCase() == food.name.toLowerCase()) return true;

      // 2. similarNames 검사
      if (food.similarNames.any((name) => text.toLowerCase() == name.toLowerCase())) return true;

      // 3. 한글 자모 유사도는 정확한 부분 문자열 매칭이 있는 경우에만 계산
      if (text.toLowerCase().contains(food.name.toLowerCase())) {
        // 1글자 식재료 특별 처리
        if (food.name.length == 1) {
          int index = text.indexOf(food.name.toLowerCase());
          if (index >= 0) {
            // 앞뒤 문자 체크
            bool validPrefix = index == 0 || !RegExp(r'[ㄱ-ㅎ가-힣]').hasMatch(text[index - 1]);
            bool validSuffix = index == text.length - 1 || !RegExp(r'[ㄱ-ㅎ가-힣]').hasMatch(text[index + 1]);
            return validPrefix && validSuffix;
          }
          return false;
        }

        // 2글자 이상 식재료는 자모 유사도 계산
        double similarity = KoreanLevenshtein.jamoSimilarityPercentage(
          text,
          food.name,
          replaceNumberToKorean: true,
          replaceSpecialCharToKorean: true,
        );

        return similarity >= 0.8; // 매우 높은 임계값 설정
      }

      return false;

    } catch (e) {
      // 에러 발생시 정확한 문자열 포함 여부만 확인
      return text.toLowerCase() == food.name.toLowerCase();
    }
  }

  List<MatchedFood> _matchFoods(RecognizedText recognizedText) {
    List<MatchedFood> matchedFoods = [];
    Set<String> matchedFoodNames = {}; // 중복 방지를 위한 Set

    final List<String> startKeywordList = ['상품명', '품명', '단가', '수량', '금액'];
    final List<String> endKeywordList = ['부가세', '합계', '총액', '결제'];
    bool startProcessing = false;

    for (var block in recognizedText.blocks) {
      String blockText = block.text.trim();

      // 영수증 섹션 체크
      if (!startProcessing) {
        if (startKeywordList.any((keyword) => blockText.contains(keyword))) {
          startProcessing = true;
          continue; // 헤더 라인은 건너뛰기
        }
        continue;
      }

      if (endKeywordList.any((keyword) => blockText.contains(keyword))) {
        break;
      }

      for (var line in block.lines) {
        String lineText = line.text.trim();

        // 숫자나 가격만 있는 라인 제외
        if (RegExp(r'^[\d,]+원?$').hasMatch(lineText)) continue;
        if (RegExp(r'^\d+$').hasMatch(lineText)) continue;

        for (var food in FOOD_LIST) {
          // 이미 매치된 식재료는 건너뛰기
          if (matchedFoodNames.contains(food.name)) continue;

          if (_isTextMatched(lineText, food)) {
            matchedFoods.add(MatchedFood(food, line.boundingBox));
            matchedFoodNames.add(food.name);
            print('Matched food: ${food.name} in line: ${lineText}');
            break;
          }
        }
      }
    }

    return matchedFoods;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: _isProcessed ? _buildProcessedImageOverlay() : _buildCameraPreview()),
          _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isProcessed) {
      return AspectRatio(
        aspectRatio: 9 / 16, // 16:9 비율의 역수를 사용하여 세로로 긴 화면을 만듭니다.
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      );
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: 9 / 16, // 16:9 비율의 역수를 사용합니다.
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Container(
                    width: _controller!.value.previewSize!.height,
                    height: _controller!.value.previewSize!.width,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildOverlay() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(child: Container()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _isProcessed
              ? SizedBox(width: 48.w) // 플래시 아이콘 자리 유지를 위한 빈 공간
              : IconButton(
            icon: Icon(Icons.flash_on, color: Colors.white),
            onPressed: () {
              // 플래시 기능 구현
            },
          ),
          Column(
            children: [
              Text(
                _isProcessed ? '영수증 인식이 완료되었습니다' : '식재료 추가',
                style: TextStyle(color: Color(0xFFFF8B27), fontSize: 22.sp),
              ),
              Text(
                _isProcessed ? '잘못인식된 식재료는 완료 후\n삭제 또는 직접추가 해주세요.' : '영수증을 촬영해주세요!',
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _isProcessed
            ? [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              setState(() {
                _isProcessed = false;
                _initializeCamera();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () {
              Provider.of<SelectedFoodProvider>(context, listen: false)
                  .updateSelectedFoods(_matchedFoods.map((mf) => mf.food).toList());
              context.pop();
            },
          ),
        ]
            : [
          IconButton(
            icon: Icon(Icons.photo_library, color: Colors.white),
            onPressed: _pickImageFromGallery,
          ),
          GestureDetector(
            onTap: _captureAndProcess,
            child: Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 50.w),
        ],
      ),
    );
  }

  Widget _buildProcessedImageOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageAspectRatio = _imageSize!.width / _imageSize!.height;
        final screenAspectRatio = constraints.maxWidth / constraints.maxHeight;

        double scale;
        double offsetX = 0;
        double offsetY = 0;

        if (imageAspectRatio > screenAspectRatio) {
          scale = constraints.maxWidth / _imageSize!.width;
          offsetY = (constraints.maxHeight - _imageSize!.height * scale) / 2;
        } else {
          scale = constraints.maxHeight / _imageSize!.height;
          offsetX = (constraints.maxWidth - _imageSize!.width * scale) / 2;
        }

        final highlightPainter = HighlightPainter(
          matchedFoods: _matchedFoods,
          imageSize: _imageSize!,
          scale: scale,
          offsetX: offsetX,
          offsetY: offsetY,
        );

        return Stack(
          children: [
            // 이미지를 한 번만 렌더링합니다
            Positioned.fill(
              child: Image.file(
                _imageFile!,
                fit: BoxFit.contain,
              ),
            ),
            // 하이라이트 오버레이
            Positioned.fill(
              child: CustomPaint(
                painter: highlightPainter,
              ),
            ),
            // 정보 팝업
            ..._buildInfoPopUps(constraints, scale, offsetX, offsetY, highlightPainter),
          ],
        );
      },
    );
  }

  List<Widget> _buildInfoPopUps(BoxConstraints constraints, double scale, double offsetX,
      double offsetY, HighlightPainter highlightPainter) {
    final infoPopUps = <Widget>[];
    final popUpWidth = 48.0;
    final popUpHeight = 24.0;

    // PictureRecorder와 Canvas를 사용하여 textBoxes를 초기화합니다.
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    highlightPainter.paint(canvas, constraints.biggest);

    for (int i = 0; i < _matchedFoods.length; i++) {
      final matchedFood = _matchedFoods[i];
      final highlightRect = highlightPainter.textBoxes[i];

      infoPopUps.add(
        Positioned(
          top: highlightRect.top,
          left: highlightRect.right + 5, // 하이라이팅 박스 오른쪽에 5픽셀 간격을 두고 배치
          child: ScaleTransition(
            scale: _scaleAnimations[i],
            child: Container(
              width: popUpWidth,
              height: popUpHeight,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(1, 1),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  matchedFood.food.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return infoPopUps;
  }
}

class HighlightPainter extends CustomPainter {
  final List<MatchedFood> matchedFoods;
  final Size imageSize;
  final double scale;
  final double offsetX;
  final double offsetY;
  final List<Rect> _textBoxes = [];

  HighlightPainter({
    required this.matchedFoods,
    required this.imageSize,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  List<Rect> get textBoxes => _textBoxes;

  @override
  void paint(Canvas canvas, Size size) {
    final highlightPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    _textBoxes.clear();

    for (var matchedFood in matchedFoods) {
      final scaledRect = Rect.fromLTRB(
        matchedFood.boundingBox.left * scale + offsetX,
        matchedFood.boundingBox.top * scale + offsetY,
        matchedFood.boundingBox.right * scale + offsetX,
        matchedFood.boundingBox.bottom * scale + offsetY,
      );

      // 하이라이팅 박스의 높이를 텍스트 높이에 맞게 조정
      final adjustedRect = Rect.fromLTRB(
        scaledRect.left,
        scaledRect.top,
        scaledRect.right,
        scaledRect.top + (scaledRect.height * 0.8),
      );

      canvas.drawRect(adjustedRect, highlightPaint);

      // 텍스트 박스 위치 저장
      _textBoxes.add(adjustedRect);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}