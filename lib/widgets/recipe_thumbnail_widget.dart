import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/_models.dart';
import '../funcs/_funcs.dart';
import 'dart:math' as math;
import 'dart:convert';

class RecipeThumbnailWidget extends StatelessWidget {
  final Recipe recipe;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool cropYoutubeBars;
  final bool highQuality;

  const RecipeThumbnailWidget({
    Key? key,
    required this.recipe,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.cropYoutubeBars = false,
    this.highQuality = false,
  }) : super(key: key);

  // 랜덤 파스텔 색상 생성
  Color _getRandomPastelColor() {
    final colors = [
      Color(0xFFFFE6E6), // 연한 핑크
      Color(0xFFE6F3FF), // 연한 파랑
      Color(0xFFE6FFE6), // 연한 초록
      Color(0xFFFFF0E6), // 연한 주황
      Color(0xFFF0E6FF), // 연한 보라
      Color(0xFFFFFFE6), // 연한 노랑
      Color(0xFFE6FFFF), // 연한 청록
      Color(0xFFFFE6F0), // 연한 장미
      Color(0xFFF0FFE6), // 연한 라임
      Color(0xFFE6E6FF), // 연한 라벤더
    ];
    
    // 레시피 ID를 기반으로 일관된 색상 선택
    final colorIndex = recipe.id.hashCode.abs() % colors.length;
    return colors[colorIndex];
  }

  Widget _buildFallbackContainer() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _getRandomPastelColor(),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: (width != null && height != null) 
              ? math.min(width!, height!) * 0.4 
              : 48.w,
          color: Colors.black54,
        ),
      ),
    );
  }

  bool _hasValidThumbnail() {
    // 커스텀 레시피의 경우 base64 인코딩된 이미지 데이터 확인
    if (recipe.isCustom && recipe.thumbnail.isNotEmpty) {
      return true;
    }
    
    // 일반 레시피의 경우 URL 유효성 확인
    return recipe.thumbnail.isNotEmpty && 
           recipe.thumbnail != '' && 
           !recipe.thumbnail.contains('null') &&
           Uri.tryParse(recipe.thumbnail) != null;
  }

  @override
  Widget build(BuildContext context) {
    // 썸네일이 없거나 유효하지 않은 경우 폴백 컨테이너 사용
    if (!_hasValidThumbnail()) {
      return _buildFallbackContainer();
    }

    // 커스텀 레시피의 base64 인코딩된 이미지 처리
    if (recipe.isCustom && recipe.thumbnail.isNotEmpty) {
      try {
        final imageBytes = base64Decode(recipe.thumbnail);
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Container(
            width: width,
            height: height,
            child: Image.memory(
              imageBytes,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _buildFallbackContainer(),
            ),
          ),
        );
      } catch (e) {
        return _buildFallbackContainer();
      }
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        child: cropYoutubeBars
            ? OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: Transform.scale(
                  scale: 0.62,
                  child: CachedNetworkImage(
                    imageUrl: recipe.thumbnail,
                    memCacheWidth: cropYoutubeBars ? 400 : (highQuality ? 800 : 400),
                    memCacheHeight: cropYoutubeBars ? 300 : (highQuality ? 600 : 300),
                    maxWidthDiskCache: cropYoutubeBars ? 400 : (highQuality ? 800 : 400),
                    maxHeightDiskCache: cropYoutubeBars ? 300 : (highQuality ? 600 : 300),
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeOutDuration: Duration(milliseconds: 200),
                    filterQuality: highQuality ? FilterQuality.medium : FilterQuality.low,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    cacheManager: DefaultCacheManager(),
                    placeholder: (context, url) => Container(
                      width: width,
                      height: height,
                      color: Color(0xFFF5F5F5),
                      child: Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFF8B27),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildFallbackContainer(),
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: recipe.thumbnail,
                memCacheWidth: highQuality ? 800 : 400,
                memCacheHeight: highQuality ? 600 : 300,
                maxWidthDiskCache: highQuality ? 800 : 400,
                maxHeightDiskCache: highQuality ? 600 : 300,
                fadeInDuration: Duration(milliseconds: 200),
                fadeOutDuration: Duration(milliseconds: 200),
                filterQuality: highQuality ? FilterQuality.medium : FilterQuality.low,
                fit: fit,
                alignment: Alignment.center,
                cacheManager: DefaultCacheManager(),
                placeholder: (context, url) => Container(
                  width: width,
                  height: height,
                  color: Color(0xFFF5F5F5),
                  child: Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFF8B27),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallbackContainer(),
              ),
      ),
    );
  }
}