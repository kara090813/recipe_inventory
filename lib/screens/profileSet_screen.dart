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
import '../status/recipeStatus.dart';
import '../status/badgeStatus.dart';
import '../status/questStatus.dart';
import '../widgets/_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'dart:typed_data';
import '../utils/custom_snackbar.dart';

class ProfileSetScreen extends StatefulWidget {
  const ProfileSetScreen({super.key});

  @override
  State<ProfileSetScreen> createState() => _ProfileSetScreenState();
}

class _ProfileSetScreenState extends State<ProfileSetScreen> {
  String _version = '';
  bool _isProcessing = false;
  bool _isAdminMode = false; // 관리자 모드 변수
  int _versionTapCount = 0;

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
      CustomSnackBar.showError(context, '이미지 처리 중 오류가 발생했습니다.');
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
                maxLength: 15,
                decoration: InputDecoration(
                  hintText: '새로운 닉네임을 입력하세요 (최대 15자)',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA8927F)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA8927F)),
                  ),
                  counterText: '',
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

          return SingleChildScrollView(
            child: Column(
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: profileImage,
                                ),
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
                      GestureDetector(
                        onTap: () {
                          _versionTapCount++;
                          if (_versionTapCount >= 5) {
                            setState(() {
                              _isAdminMode = !_isAdminMode;
                              _versionTapCount = 0;
                            });
                            CustomSnackBar.showInfo(context, _isAdminMode ? '관리자 모드 활성화' : '관리자 모드 비활성화');
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              '현재 버전 $_version',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            Expanded(child: SizedBox()),
                          ],
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
                // 관리자 섹션
                if (_isAdminMode) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "관리자 모드",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Switch(
                              value: _isAdminMode,
                              onChanged: (value) {
                                setState(() {
                                  _isAdminMode = value;
                                });
                              },
                              activeColor: Colors.red,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildAdminButton(
                          "유저 Status 초기화",
                          Icons.person_off,
                          () async {
                            final userStatus = Provider.of<UserStatus>(context, listen: false);
                            final questStatus = Provider.of<QuestStatus>(context, listen: false);
                            await userStatus.reset();
                            await questStatus.clearQuests();
                            CustomSnackBar.showSuccess(context, '유저 데이터가 초기화되었습니다.');
                          },
                        ),
                        SizedBox(height: 8.h),
                        _buildAdminButton(
                          "레시피 초기화",
                          Icons.restaurant_menu,
                          () async {
                            final recipeStatus = Provider.of<RecipeStatus>(context, listen: false);
                            await recipeStatus.clearAllRecipes();
                            CustomSnackBar.showSuccess(context, '레시피가 초기화되었습니다.');
                          },
                        ),
                        SizedBox(height: 8.h),
                        _buildAdminButton(
                          "기타 Status 초기화",
                          Icons.clear_all,
                          () async {
                            final badgeStatus = Provider.of<BadgeStatus>(context, listen: false);
                            await badgeStatus.clearBadges();
                            CustomSnackBar.showSuccess(context, '기타 데이터가 초기화되었습니다.');
                          },
                        ),
                        SizedBox(height: 8.h),
                        _buildAdminButton(
                          "XP +100",
                          Icons.trending_up,
                          () async {
                            final userStatus = Provider.of<UserStatus>(context, listen: false);
                            await userStatus.addExperience(100);
                            CustomSnackBar.showSuccess(context, 'XP가 100 증가했습니다.');
                          },
                        ),
                        SizedBox(height: 8.h),
                        _buildAdminButton(
                          "포인트 +100",
                          Icons.monetization_on,
                          () {
                            final userStatus = Provider.of<UserStatus>(context, listen: false);
                            userStatus.addPoints(100);
                            CustomSnackBar.showSuccess(context, '포인트가 100 증가했습니다.');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 150.h),
                ],
              ],
            ),
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

  Widget _buildAdminButton(String text, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.red, size: 20.w),
                  SizedBox(width: 12.w),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}