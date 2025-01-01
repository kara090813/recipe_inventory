import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../status/_status.dart';
import '../widgets/_widgets.dart';

class ProfileSetScreen extends StatelessWidget {
  const ProfileSetScreen({super.key});

  Future<void> _pickImage(BuildContext context, UserStatus userStatus) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // 이미지 품질 조정
        maxWidth: 800, // 최대 너비 제한
      );

      if (image != null) {
        // 이전 프로필 이미지 삭제
        if (userStatus.profileImage != null) {
          final File oldImage = File(userStatus.profileImage!);
          if (await oldImage.exists()) {
            await oldImage.delete();
          }
        }

        // 임시 디렉토리 가져오기
        final directory = await Directory.systemTemp.createTemp();
        final String newPath =
            '${directory.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // 새 이미지 저장
        final File newImage = File(newPath);
        await newImage.writeAsBytes(await image.readAsBytes());

        // 프로필 업데이트
        if (userStatus.userProfile != null) {
          final updatedProfile = userStatus.userProfile!.copyWith(
            photoURL: newPath,
          );
          userStatus.updateUserProfile(updatedProfile);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다.')),
      );
    }
  }

  void _showNicknameDialog(BuildContext context, UserStatus userStatus) {
    final TextEditingController controller = TextEditingController();
    controller.text = userStatus.nickname;

    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                    fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF7D674B)),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '새로운 닉네임을 입력하세요',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF7D674B)),
                  ),
                ),
                style: TextStyle(fontSize: 16.sp),
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
                            fontFamily: 'Mapo'),
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
                        '저장하',
                        style: TextStyle(color:Colors.white,fontSize: 16.sp,fontWeight: FontWeight
                            .bold,fontFamily: 'Mapo'),
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
    final userStatus = context.watch<UserStatus>();

    Widget profileImage = userStatus.profileImage != null
        ? Image.file(
            File(userStatus.profileImage!),
            width: 100.w,
            height: 100.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/imgs/items/baseProfile.png',
                width: 100.w,
              );
            },
          )
        : Image.asset(
            'assets/imgs/items/baseProfile.png',
            width: 100.w,
          );

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
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
                        '계정 설정하기',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF7D674B), fontSize: 20.sp),
                      ),
                    ),
                    SizedBox(width: 40.w)
                  ],
                ),
                SizedBox(height: 10.h),
                DottedBarWidget(),
                SizedBox(height: 30.h),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(context, userStatus),
                      child: Stack(
                        children: [
                          ClipOval(child: profileImage),
                          Positioned(
                            right: 0,
                            bottom: 5,
                            child: Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.photo_camera,
                                  color: Colors.white,
                                  size: 18.w,
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
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h)
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
                        color: Color(0xFFFF8B27), fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      '현재 버전 1.1.11',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    Expanded(child: SizedBox()),
                    Text('업데이트', style: TextStyle(fontSize: 12.sp, color: Colors.redAccent))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
