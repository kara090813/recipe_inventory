import UIKit
import google_mobile_ads

class ListTileNativeAdFactory : FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)!.first
        let nativeAdView = nibView as! GADNativeAdView
        
        // 미디어 뷰 설정
        if let mediaView = nativeAdView.mediaView {
            mediaView.backgroundColor = UIColor(red: 0.933, green: 0.933, blue: 0.933, alpha: 1.0)
        }
        
        // 광고 배지
        if let adBadgeView = nativeAdView.viewWithTag(101) as? UILabel {
            adBadgeView.text = "Ad"
            adBadgeView.backgroundColor = UIColor(red: 0.945, green: 0.596, blue: 0.224, alpha: 1.0)
            adBadgeView.textColor = .white
            adBadgeView.font = UIFont.systemFont(ofSize: 12)
            adBadgeView.isHidden = false
        }
        
        // 아이콘
        if let iconView = nativeAdView.iconView as? UIImageView {
            iconView.image = nativeAd.icon?.image
            iconView.backgroundColor = UIColor(red: 0.867, green: 0.867, blue: 0.867, alpha: 1.0)
            iconView.contentMode = .scaleAspectFit
            iconView.isHidden = nativeAd.icon == nil
        }
        
        // 헤드라인
        if let headlineView = nativeAdView.headlineView as? UILabel {
            headlineView.text = nativeAd.headline
            headlineView.textColor = .black
            headlineView.font = UIFont.boldSystemFont(ofSize: 16)
            headlineView.numberOfLines = 2
            headlineView.isHidden = nativeAd.headline == nil
        }
        
        // 본문
        if let bodyView = nativeAdView.bodyView as? UILabel {
            bodyView.text = nativeAd.body
            bodyView.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
            bodyView.font = UIFont.systemFont(ofSize: 14)
            bodyView.numberOfLines = 3
            bodyView.isHidden = nativeAd.body == nil
        }
        
        // 클릭 유도 문구
        if let ctaView = nativeAdView.callToActionView as? UIButton {
            ctaView.setTitle("클릭하여 다운로드", for: .normal)
            ctaView.backgroundColor = UIColor(red: 1.0, green: 0.545, blue: 0.153, alpha: 1.0)
            ctaView.setTitleColor(.white, for: .normal)
            ctaView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            ctaView.layer.cornerRadius = 10
            ctaView.isUserInteractionEnabled = false
        }
        
        nativeAdView.nativeAd = nativeAd
        
        return nativeAdView
    }
}
