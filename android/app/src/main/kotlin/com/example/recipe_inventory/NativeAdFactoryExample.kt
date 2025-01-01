package com.example.recipe_inventory

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactoryExample(private val context: Context) :
        GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
            nativeAd: NativeAd,
            customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        // 1) my_native_ad 레이아웃 inflate
        val nativeAdView = LayoutInflater.from(context)
                .inflate(R.layout.my_native_ad, null) as NativeAdView

        // 2) MediaView
        val mediaView = nativeAdView.findViewById<View>(R.id.ad_media)
        if (mediaView is MediaView) {
            nativeAdView.mediaView = mediaView
        }

        // 3) 광고 배지
        val adBadgeView = nativeAdView.findViewById<View>(R.id.tv_ad_badge)
        adBadgeView.visibility = View.VISIBLE // 필요 시 조건부

        // 4) 아이콘
        val iconView = nativeAdView.findViewById<View>(R.id.ad_icon)
        val icon = nativeAd.icon
        if (icon != null) {
            iconView.visibility = View.VISIBLE
            if (iconView is ImageView) {
                iconView.setImageDrawable(icon.drawable)
            }
        } else {
            iconView.visibility = View.GONE
        }
        nativeAdView.iconView = iconView

        // 5) 광고 제목 (Headline)
        val headlineView = nativeAdView.findViewById<View>(R.id.ad_headline)
        val headlineText = nativeAd.headline
        if (headlineText != null && headlineText.length > 0) {
            headlineView.visibility = View.VISIBLE
            if (headlineView is android.widget.TextView) {
                headlineView.text = headlineText
            }
        } else {
            headlineView.visibility = View.GONE
        }
        nativeAdView.headlineView = headlineView

        // 6) 광고 본문 (Body)
        val bodyView = nativeAdView.findViewById<View>(R.id.ad_body)
        val bodyText = nativeAd.body
        if (bodyText != null && bodyText.length > 0) {
            bodyView.visibility = View.VISIBLE
            if (bodyView is android.widget.TextView) {
                bodyView.text = bodyText
            }
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        // 7) 별표 평점 (RatingBar)
        val ratingView = nativeAdView.findViewById<View>(R.id.ad_star_rating)
        val ratingVal = nativeAd.starRating
        if (ratingVal != null && ratingVal > 0) {
            ratingView.visibility = View.VISIBLE
            // cast해서 rating 세팅
            if (ratingView is android.widget.RatingBar) {
                ratingView.rating = ratingVal.toFloat()
            }
        } else {
            ratingView.visibility = View.GONE
        }

        // 8) 클릭 유도 문구 (CallToAction) -> 버튼
        val ctaView = nativeAdView.findViewById<View>(R.id.ad_call_to_action)
        val ctaText = nativeAd.callToAction
        if (ctaText != null && ctaText.length > 0) {
            ctaView.visibility = View.VISIBLE
            // Button도 실제로는 TextView 상속
            if (ctaView is android.widget.TextView) {
                ctaView.text = ctaText
            }
        } else {
            ctaView.visibility = View.GONE
        }
        nativeAdView.callToActionView = ctaView

        // 9) NativeAd 등록
        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}