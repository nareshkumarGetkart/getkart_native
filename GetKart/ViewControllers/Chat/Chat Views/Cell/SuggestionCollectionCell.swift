//
//  SuggestionCollectionCell.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 16/07/25.
//

import UIKit

class SuggestionCollectionCell: UICollectionViewCell {

    @IBOutlet  weak var lblTitle:UILabel!
    private var rippleLayer: CAShapeLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblTitle.layer.borderColor = UIColor.lightGray.cgColor
        lblTitle.layer.borderWidth = 0.5
        lblTitle.layer.cornerRadius = 4.0
        lblTitle.clipsToBounds = true
    }
    
     func showRipple(at point: CGPoint) {
        rippleLayer?.removeFromSuperlayer()

        let radius: CGFloat = max(bounds.width, bounds.height)
        let ripplePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: radius, height: radius))

        let layer = CAShapeLayer()
        layer.path = ripplePath.cgPath
        layer.position = CGPoint(x: point.x - radius / 2, y: point.y - radius / 2)
        layer.fillColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.layer.addSublayer(layer)
        rippleLayer = layer

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.1
        scale.toValue = 1.0
        scale.duration = 0.4

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.5
        fade.toValue = 0.0
        fade.duration = 0.4

        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 0.4
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false

        layer.add(group, forKey: "rippleEffect")
    }

    func showRipple(on view: UIView, at point: CGPoint) {
        let rippleRadius = max(view.bounds.width, view.bounds.height)
        let ripplePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: rippleRadius, height: rippleRadius))
        
        let rippleLayer = CAShapeLayer()
        rippleLayer.path = ripplePath.cgPath
        rippleLayer.position = CGPoint(x: point.x - rippleRadius / 2, y: point.y - rippleRadius / 2)
        rippleLayer.fillColor = UIColor.orange.withAlphaComponent(0.7).cgColor
        view.layer.addSublayer(rippleLayer)
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.1
        scale.toValue = 1.0
        scale.duration = 0.8
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.5
        fade.toValue = 0.0
        fade.duration = 0.8
        
        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 0.8
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        rippleLayer.add(group, forKey: "rippleEffect")
    }
}

