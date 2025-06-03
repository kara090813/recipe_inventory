import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../status/_status.dart';

class NotificationRedirectScreen extends StatefulWidget {
  final String recipeId;

  const NotificationRedirectScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  State<NotificationRedirectScreen> createState() => _NotificationRedirectScreenState();
}

class _NotificationRedirectScreenState extends State<NotificationRedirectScreen> {
  @override
  void initState() {
    super.initState();
    // 메인 화면으로 바로 이동 후 레시피 상세 페이지로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleRedirect();
      }
    });
  }

  void _handleRedirect() async {
    if (widget.recipeId.isEmpty) {
      // ID가 없으면 홈으로만 이동
      context.go('/');
      return;
    }

    try {
      // 레시피 ID 확인
      final recipeStatus = Provider.of<RecipeStatus>(context, listen: false);
      final recipe = recipeStatus.findRecipeById(widget.recipeId);

      if (recipe != null) {
        // 홈으로 이동 후 레시피 상세 페이지로 이동
        context.go('/');

        // 탭 인덱스 설정
        Provider.of<TabStatus>(context, listen: false).setIndex(0);

        // 잠시 지연 후 레시피 페이지로 이동 (URL 형식으로)
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            context.go('/recipeInfo/${widget.recipeId}');
          }
        });
      } else {
        // 레시피를 찾을 수 없으면 홈으로만 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('레시피를 찾을 수 없습니다: ${widget.recipeId}')),
        );
        context.go('/');
      }
    } catch (e) {
      print('알림 리다이렉트 처리 중 오류: $e');
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFF8B27),
            ),
            SizedBox(height: 16),
            Text('레시피 정보를 불러오는 중입니다...'),
          ],
        ),
      ),
    );
  }
}