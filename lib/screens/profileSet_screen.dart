import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../funcs/_funcs.dart';
import '../models/_models.dart';
import '../models/data.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'dart:typed_data';

class ProfileSetScreen extends StatefulWidget {
  const ProfileSetScreen({super.key});

  @override
  State<ProfileSetScreen> createState() => _ProfileSetScreenState();
}

class _ProfileSetScreenState extends State<ProfileSetScreen> {
  String _version = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;  // 1.0.0 형식
      // 또는 빌드 번호까지 포함: ${packageInfo.version}+${packageInfo.buildNumber}
    });
  }

  Future<void> _pickImage(BuildContext context, UserStatus userStatus) async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        final img.Image? originalImage = img.decodeImage(imageBytes);

        if (originalImage != null) {
          final int size = min(originalImage.width, originalImage.height);
          final int x = (originalImage.width - size) ~/ 2;
          final int y = (originalImage.height - size) ~/ 2;

          final img.Image croppedImage = img.copyCrop(originalImage, x: x, y: y, width: size, height: size);
          final img.Image resizedImage = img.copyResize(croppedImage, width: 400, height: 400);

          final directory = await getApplicationDocumentsDirectory();
          final String newPath = '${directory.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final File newImage = File(newPath);

          await newImage.writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

          if (userStatus.profileImage != null) {
            try {
              final File oldImage = File(userStatus.profileImage!);
              if (await oldImage.exists()) {
                await oldImage.delete();
              }
            } catch (e) {
              print('Error deleting old image: $e');
            }
          }

          final updatedProfile = userStatus.userProfile!.copyWith(photoURL: newPath);
          await userStatus.updateUserProfile(updatedProfile);

          setState(() {});
        }
      }
    } catch (e) {
      print('Error processing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 처리 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showNicknameDialog(BuildContext context, UserStatus userStatus) {
    final TextEditingController controller = TextEditingController();
    controller.text = userStatus.nickname;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '닉네임 수정',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7D674B),
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '새로운 닉네임을 입력하세요',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA8927F)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA8927F)),
                  ),
                ),
                style: TextStyle(fontSize: 16.sp, fontFamily: 'Mapo'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE8E8E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      child: Text(
                        '닫기',
                        style: TextStyle(
                          color: Color(0xFF7D674B),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Mapo',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          userStatus.setNickname(controller.text);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF8B27),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      child: Text(
                        '저장하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Mapo',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Consumer<UserStatus>(
        builder: (context, userStatus, child) {
          Widget profileImage = _buildProfileImage(userStatus);

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 0),
                child: Column(
                  children: [
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            color: Colors.transparent,
                            child: Image.asset(
                              'assets/imgs/icons/back_arrow.png',
                              width: 26.w,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '냉장고 털이 설정',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF7D674B),
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 40.w),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    DottedBarWidget(),
                    SizedBox(height: 30.h),
                    Column(
                      children: [
                        GestureDetector(
                          // onTap: () => _pickImage(context, userStatus),
                          onTap:(){},
                          child: Stack(
                            children: [
                              ClipOval(child: profileImage),
                              if (!_isProcessing)
                                // Positioned(
                                //   right: 0,
                                //   bottom: 5,
                                //   child: Container(
                                //     width: 28.w,
                                //     height: 28.w,
                                //     decoration: BoxDecoration(
                                //       color: Colors.black,
                                //       borderRadius: BorderRadius.circular(100),
                                //     ),
                                //     child: Center(
                                //       child: Icon(
                                //         Icons.photo_camera,
                                //         color: Colors.white,
                                //         size: 18.w,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              if (_isProcessing)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: () => _showNicknameDialog(context, userStatus),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userStatus.nickname,
                                style: TextStyle(fontSize: 22.sp),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.edit,
                                color: Color(0xFFB1B1B1),
                                size: 20.w,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "버전",
                        style: TextStyle(
                          color: Color(0xFFFF8B27),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Text(
                          '현재 버전 $_version',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "라이선스",
                        style: TextStyle(
                          color: Color(0xFFFF8B27),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '© 2025 LaMoss Tech. All rights reserved.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF707070),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '이 앱은 서울시 "마포 브랜드 서체"를 사용하고 있습니다.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF707070),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "가이드 다시보기",
                        style: TextStyle(
                          color: Color(0xFFFF8B27),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () {
                        OnboardingGuide.showGuide(context, guideContents);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h,), // 패딩
                          // 추가하여
                          // 높이 통일
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8B27),
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            // 텍스트 중앙 정렬
                            child: Text(
                              "냉장고 털이 가이드 확인",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(UserStatus userStatus) {
    if (_isProcessing) {
      return Container(
        width: 100.w,
        height: 100.w,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userStatus.profileImage != null) {
      return Image.file(
        File(userStatus.profileImage!),
        width: 100.w,
        height: 100.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading profile image: $error');
          return Image.asset(
            'assets/imgs/items/baseProfile.png',
            width: 100.w,
          );
        },
      );
    }

    return Image.asset(
      'assets/imgs/items/baseProfile.png',
      width: 100.w,
    );
  }
}