//
//  FTPopOverMenu.swift
//  FTPopOverMenu
//
//  Created by liufengting on 16/11/2016.
//  Copyright © 2016 LiuFengting (https://github.com/liufengting) . All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

extension FTPopOverMenu {
    
    public static func showForSender(sender : UIView, with menuArray: [String], done: @escaping (NSInteger) -> Void, cancel:@escaping () -> Void) {
        self.sharedMenu.showForSender(sender: sender, or: nil, with: menuArray, menuImageArray: [], done: done, cancel: cancel)
    }
    
    public static func showForSender(sender : UIView, with menuArray: [String], menuImageArray: [Imageable]?, done: @escaping (NSInteger) -> Void, cancel:@escaping () -> Void) {
        self.sharedMenu.showForSender(sender: sender, or: nil, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func showForEvent(event : UIEvent, with menuArray: [String], done: @escaping (NSInteger) -> Void, cancel:@escaping () -> Void) {
        self.sharedMenu.showForSender(sender: event.allTouches?.first?.view!, or: nil, with: menuArray, menuImageArray: [], done: done, cancel: cancel)
    }
    
    public static func showForEvent(event : UIEvent, with menuArray: [String], menuImageArray: [Imageable]?, done: @escaping (NSInteger) -> Void, cancel:@escaping () -> Void) {
        self.sharedMenu.showForSender(sender: event.allTouches?.first?.view!, or: nil, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func showFromSenderFrame(senderFrame : CGRect, with menuArray: [String], done: @escaping (NSInteger) -> Void, cancel:@escaping () -> Void) {
        self.sharedMenu.showForSender(sender: nil, or: senderFrame, with: menuArray, menuImageArray: [], done: done, cancel: cancel)
    }
    
    public static func showFromSenderFrame(senderFrame : CGRect, with menuArray: [String], menuImageArray: [Imageable]?, done: @escaping (NSInteger) -> Void, cancel:@escaping () -> Void) {
        self.sharedMenu.showForSender(sender: nil, or: senderFrame, with: menuArray, menuImageArray: menuImageArray, done: done, cancel: cancel)
    }
    
    public static func showForSender(sender : UIView, with menuArray: [String], menuImageArray: [Imageable]?, cellConfigurationArray: [FTCellConfiguration]?, done: @escaping (NSInteger) -> Void, cancel: (() -> Void)? = nil) {
        self.sharedMenu.showForSender(sender: sender, or: nil, with: menuArray, menuImageArray: menuImageArray, cellConfigurationArray: cellConfigurationArray, done: done, cancel: cancel)
    }
    
    public static func showForEvent(event : UIEvent, with menuArray: [String], menuImageArray: [Imageable]?, cellConfigurationArray: [FTCellConfiguration]?, done: @escaping (NSInteger) -> Void, cancel: (() -> Void)? = nil) {
        self.sharedMenu.showForSender(sender: event.allTouches?.first?.view!, or: nil, with: menuArray, menuImageArray: menuImageArray, cellConfigurationArray: cellConfigurationArray, done: done, cancel: cancel)
    }
    
    public static func showFromSenderFrame(senderFrame : CGRect, with menuArray: [String], menuImageArray: [Imageable]?, cellConfigurationArray: [FTCellConfiguration]?, done: @escaping (NSInteger) -> Void, cancel: (() -> Void)? = nil) {
        self.sharedMenu.showForSender(sender: nil, or: senderFrame, with: menuArray, menuImageArray: menuImageArray, cellConfigurationArray: cellConfigurationArray, done: done, cancel: cancel)
    }
    
    public static func dismiss() {
        self.sharedMenu.dismiss()
    }
}

fileprivate enum FTPopOverMenuArrowDirection {
    case up
    case down
}

public class FTPopOverMenu : NSObject {
    
    var sender : UIView?
    var senderFrame : CGRect?
    var menuNameArray : [String]!
    var menuImageArray : [Imageable]!
    var cellConfigurationArray : [FTCellConfiguration]?
    var done : ((_ selectedIndex : NSInteger) -> Void)!
    var cancel : (() -> Void)!
    
    fileprivate static var sharedMenu : FTPopOverMenu {
        struct Static {
            static let instance : FTPopOverMenu = FTPopOverMenu()
        }
        return Static.instance
    }
    
    fileprivate lazy var configuration : FTConfiguration = {
        return FTConfiguration.shared
    }()
    
    fileprivate lazy var backgroundView : UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        if self.configuration.globalShadow {
            view.backgroundColor = UIColor.black.withAlphaComponent(self.configuration.shadowAlpha)
        }
        view.addGestureRecognizer(self.tapGesture)
        return view
    }()
    
    fileprivate lazy var popOverMenu : FTPopOverMenuView = {
        let menu = FTPopOverMenuView(frame: CGRect.zero)
        menu.alpha = 0
        self.backgroundView.addSubview(menu)
        return menu
    }()
    
    fileprivate var isOnScreen : Bool = false {
        didSet {
            if isOnScreen {
                self.addOrientationChangeNotification()
            } else {
                self.removeOrientationChangeNotification()
            }
        }
    }
    
    fileprivate lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onBackgroudViewTapped(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    fileprivate func showForSender(sender: UIView?, or senderFrame: CGRect?, with menuNameArray: [String]!, menuImageArray: [Imageable]?, cellConfigurationArray: [FTCellConfiguration]? = nil, done: @escaping (NSInteger) -> Void, cancel: (() -> Void)? = nil){
        
        if sender == nil && senderFrame == nil {
            return
        }
        if menuNameArray.count == 0 {
            return
        }
        
        self.sender = sender
        self.senderFrame = senderFrame
        self.menuNameArray = menuNameArray
        self.menuImageArray = menuImageArray
        self.cellConfigurationArray = cellConfigurationArray
        self.done = done
        self.cancel = cancel
                
        self.backgroundView.addSubview(self.configuration.selectedView)
        
        self.backgroundView.bringSubviewToFront(self.popOverMenu)

        UIApplication.shared.keyWindow?.addSubview(self.backgroundView)
        
        self.adjustPostionForPopOverMenu()
        
    }
    
    fileprivate func adjustPostionForPopOverMenu() {
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.ft_width(), height: UIScreen.ft_height())
        
        self.setupPopOverMenu()
        
        self.showIfNeeded()
    }
    
    fileprivate func setupPopOverMenu() {
        popOverMenu.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        self.configurePopMenuFrame()
        
        popOverMenu.showWithAnglePoint(point: menuArrowPoint, frame: popMenuFrame, menuNameArray: menuNameArray, menuImageArray: menuImageArray, cellConfigurationArray: cellConfigurationArray,  arrowDirection: arrowDirection, done: { (selectedIndex: NSInteger) in
            self.isOnScreen = false
            self.doneActionWithSelectedIndex(selectedIndex: selectedIndex)
        })
        
        popOverMenu.setAnchorPoint(anchorPoint: self.getAnchorPointForPopMenu())
        
        self.popOverMenu.dropShadow(color: UIColor.darkGray.withAlphaComponent(0.8), opacity: 0.5, offSet: CGSize(width: 0, height: 0), radius: 5, scale: true)
    }
    
    fileprivate func getAnchorPointForPopMenu() -> CGPoint {
        var anchorPoint = CGPoint(x: menuArrowPoint.x/popMenuFrame.size.width, y: 0)
        if arrowDirection == .down {
            anchorPoint = CGPoint(x: menuArrowPoint.x/popMenuFrame.size.width, y: 1)
        }
        return anchorPoint
    }
    
    fileprivate var senderRect : CGRect = CGRect.zero
    fileprivate var popMenuOriginX : CGFloat = 0
    fileprivate var popMenuFrame : CGRect = CGRect.zero
    fileprivate var menuArrowPoint : CGPoint = CGPoint.zero
    fileprivate var arrowDirection : FTPopOverMenuArrowDirection = .up
    fileprivate var popMenuHeight : CGFloat {
        return configuration.menuRowHeight * CGFloat(self.menuNameArray.count) + FT.DefaultMenuArrowHeight
    }
    
    fileprivate func configureSenderRect() {
        if let sender = self.sender {
            if let superView = sender.superview {
                senderRect = superView.convert(sender.frame, to: backgroundView)
            }
        } else if let frame = senderFrame {
            senderRect = frame
        }
        senderRect.origin.y = min(UIScreen.ft_height(), senderRect.origin.y)
        
        if senderRect.origin.y + senderRect.size.height/2 < UIScreen.ft_height()/2 {
            arrowDirection = .up
        } else {
            arrowDirection = .down
        }
        //arrowDirection = AppDelegate.sharedInstance.IsKeyboardVisible ? .down : arrowDirection
    }
    
    fileprivate func configurePopMenuOriginX() {
        var senderXCenter : CGPoint = CGPoint(x: senderRect.origin.x + (senderRect.size.width)/2, y: 0)
        let menuCenterX : CGFloat = configuration.menuWidth/2 + FT.DefaultMargin
        var menuX : CGFloat = 0
        if senderXCenter.x + menuCenterX > UIScreen.ft_width() {
            senderXCenter.x = min(senderXCenter.x - (UIScreen.ft_width() - configuration.menuWidth - FT.DefaultMargin), configuration.menuWidth - FT.DefaultMenuArrowWidth - FT.DefaultMargin)
            menuX = UIScreen.ft_width() - configuration.menuWidth - FT.DefaultMargin
        } else if senderXCenter.x - menuCenterX < 0 {
            senderXCenter.x = max(FT.DefaultMenuCornerRadius + FT.DefaultMenuArrowWidth, senderXCenter.x - FT.DefaultMargin)
            menuX = FT.DefaultMargin
        } else {
            senderXCenter.x = configuration.menuWidth/2
            menuX = senderRect.origin.x + (senderRect.size.width)/2 - configuration.menuWidth/2
        }
        popMenuOriginX = menuX
    }
    
    fileprivate func configurePopMenuFrame() {
        self.configureSenderRect()
        self.configureMenuArrowPoint()
        self.configurePopMenuOriginX()
        
        if arrowDirection == .up {
            popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y + senderRect.size.height), width: configuration.menuWidth, height: popMenuHeight)
            if (popMenuFrame.origin.y + popMenuFrame.size.height > UIScreen.ft_height()) {
                popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y + senderRect.size.height), width: configuration.menuWidth, height: UIScreen.ft_height() - popMenuFrame.origin.y - FT.DefaultMargin)
            }
        } else {
            popMenuFrame = CGRect(x: popMenuOriginX, y: (senderRect.origin.y - popMenuHeight), width: configuration.menuWidth, height: popMenuHeight)
            if popMenuFrame.origin.y  < 0 {
                popMenuFrame = CGRect(x: popMenuOriginX, y: FT.DefaultMargin, width: configuration.menuWidth, height: senderRect.origin.y - FT.DefaultMargin)
            }
        }
    }
    
    fileprivate func configureMenuArrowPoint() {
        var point : CGPoint = CGPoint(x: senderRect.origin.x + (senderRect.size.width)/2, y: 0)
        let menuCenterX : CGFloat = configuration.menuWidth/2 + FT.DefaultMargin
        if senderRect.origin.y + senderRect.size.height/2 < UIScreen.ft_height()/2 {
            point.y = 0
        } else {
            point.y = popMenuHeight
        }
        if point.x + menuCenterX > UIScreen.ft_width() {
            point.x = min(point.x - (UIScreen.ft_width() - configuration.menuWidth - FT.DefaultMargin), configuration.menuWidth - FT.DefaultMenuArrowWidth - FT.DefaultMargin)
        } else if point.x - menuCenterX < 0 {
            point.x = max(FT.DefaultMenuCornerRadius + FT.DefaultMenuArrowWidth, point.x - FT.DefaultMargin)
        } else {
            point.x = configuration.menuWidth/2
        }
        menuArrowPoint = point
    }
    
    @objc fileprivate func onBackgroudViewTapped(gesture : UIGestureRecognizer) {
        self.dismiss()
    }
    
    fileprivate func showIfNeeded() {
        if self.isOnScreen == false {
            self.isOnScreen = true
            popOverMenu.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: FT.DefaultAnimationDuration, animations: {
                self.popOverMenu.alpha = 1
                self.popOverMenu.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    fileprivate func dismiss() {
        self.isOnScreen = false
        self.doneActionWithSelectedIndex(selectedIndex: -1)
    }
    
    fileprivate func doneActionWithSelectedIndex(selectedIndex: NSInteger) {
        UIView.animate(withDuration: FT.DefaultAnimationDuration,
                       animations: {
                        self.popOverMenu.alpha = 0
                        self.popOverMenu.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (isFinished) in
            if isFinished {
                _ = self.configuration.selectedView.subviews.map {
                    $0.removeFromSuperview()
                }
                self.configuration.selectedView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
                if selectedIndex < 0 {
                    if (self.cancel != nil) {
                        self.cancel()
                    }
                } else {
                    if self.done != nil {
                        self.done(selectedIndex)
                    }
                }
                
            }
        }
    }
    
}

extension FTPopOverMenu {
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self,selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: UIApplication.didChangeStatusBarOrientationNotification,
                                               object: nil)
        
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.adjustPostionForPopOverMenu()
        })
    }
    
}

extension FTPopOverMenu: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: backgroundView)
        let touchClass : String = NSStringFromClass((touch.view?.classForCoder)!) as String
        if touchClass == "UITableViewCellContentView" {
            return false
        } else if CGRect(x: 0, y: 0, width: configuration.menuWidth, height: configuration.menuRowHeight).contains(touchPoint){
            // when showed at the navgation-bar-button-item, there is a chance of not respond around the top arrow, so :
            self.doneActionWithSelectedIndex(selectedIndex: 0)
            return false
        }
        return true
    }
    
}

private class FTPopOverMenuView: UIControl {
    
    fileprivate var menuNameArray : [String]!
    fileprivate var menuImageArray : [Imageable]?
    fileprivate var arrowDirection : FTPopOverMenuArrowDirection = .up
    fileprivate var done : ((NSInteger) -> Void)!
    fileprivate var cellConfigurationArray : [FTCellConfiguration]?
    
    fileprivate lazy var configuration : FTConfiguration = {
        return FTConfiguration.shared
    }()
    
    lazy var menuTableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = FTConfiguration.shared.menuSeparatorColor
        tableView.layer.cornerRadius = FTConfiguration.shared.cornerRadius
        tableView.clipsToBounds = true
        return tableView
    }()
    
    fileprivate func showWithAnglePoint(point: CGPoint, frame: CGRect, menuNameArray: [String]!, menuImageArray: [Imageable]?, cellConfigurationArray: [FTCellConfiguration]? = nil, arrowDirection: FTPopOverMenuArrowDirection, done: @escaping ((NSInteger) -> Void)) {
        
        self.frame = frame
        
        self.menuNameArray = menuNameArray
        self.menuImageArray = menuImageArray
        self.cellConfigurationArray = cellConfigurationArray
        self.arrowDirection = arrowDirection
        self.done = done
        
        repositionMenuTableView()
        
        drawBackgroundLayerWithArrowPoint(arrowPoint: point)
    }
    
    fileprivate func repositionMenuTableView() {
        var menuRect : CGRect = CGRect(x: 0, y: FT.DefaultMenuArrowHeight, width: frame.size.width, height: frame.size.height - FT.DefaultMenuArrowHeight)
        if (arrowDirection == .down) {
            menuRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - FT.DefaultMenuArrowHeight)
        }
        menuTableView.frame = menuRect
        menuTableView.reloadData()
        if menuTableView.frame.height < configuration.menuRowHeight * CGFloat(menuNameArray.count) {
            menuTableView.isScrollEnabled = true
        } else {
            menuTableView.isScrollEnabled = false
        }
        addSubview(self.menuTableView)
    }
    
    fileprivate lazy var backgroundLayer : CAShapeLayer = {
        let layer : CAShapeLayer = CAShapeLayer()
        return layer
    }()
    
    
    fileprivate func drawBackgroundLayerWithArrowPoint(arrowPoint : CGPoint) {
        if self.backgroundLayer.superlayer != nil {
            self.backgroundLayer.removeFromSuperlayer()
        }
        
        backgroundLayer.path = getBackgroundPath(arrowPoint: arrowPoint).cgPath
        backgroundLayer.fillColor = configuration.backgoundTintColor.cgColor
        backgroundLayer.strokeColor = configuration.borderColor.cgColor
        backgroundLayer.lineWidth = configuration.borderWidth
        if configuration.localShadow {
            backgroundLayer.shadowColor = UIColor.black.cgColor
            backgroundLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            backgroundLayer.shadowRadius = 24.0
            backgroundLayer.shadowOpacity = 0.9
            backgroundLayer.masksToBounds = false
            backgroundLayer.shouldRasterize = true
            backgroundLayer.rasterizationScale = UIScreen.main.scale
            
        }
        self.layer.insertSublayer(backgroundLayer, at: 0)
        //        backgroundLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI))) //CATransform3DMakeRotation(CGFloat(M_PI), 1, 1, 0)
    }
    
    func getBackgroundPath(arrowPoint : CGPoint) -> UIBezierPath {
        
        let viewWidth = bounds.size.width
        let viewHeight = bounds.size.height
        
        let radius : CGFloat = configuration.cornerRadius/2
        
        let path : UIBezierPath = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        if (arrowDirection == .up){
            path.move(to: CGPoint(x: arrowPoint.x - FT.DefaultMenuArrowWidth, y: FT.DefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
            path.addLine(to: CGPoint(x: arrowPoint.x + FT.DefaultMenuArrowWidth, y: FT.DefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x:viewWidth - radius, y: FT.DefaultMenuArrowHeight))
            path.addArc(withCenter: CGPoint(x: viewWidth - radius, y: FT.DefaultMenuArrowHeight + radius),
                        radius: radius,
                        startAngle: .pi / 2 * 3,
                        endAngle: 0,
                        clockwise: true)
            path.addLine(to: CGPoint(x: viewWidth, y: viewHeight - radius))
            path.addArc(withCenter: CGPoint(x: viewWidth - radius, y: viewHeight - radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
            path.addLine(to: CGPoint(x: radius, y: viewHeight))
            path.addArc(withCenter: CGPoint(x: radius, y: viewHeight - radius),
                        radius: radius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: FT.DefaultMenuArrowHeight + radius))
            path.addArc(withCenter: CGPoint(x: radius, y: FT.DefaultMenuArrowHeight + radius),
                        radius: radius,
                        startAngle: .pi,
                        endAngle: .pi / 2 * 3,
                        clockwise: true)
            path.close()
            //            path = UIBezierPath(roundedRect: CGRect.init(x: 0, y: FTDefaultMenuArrowHeight, width: self.bounds.size.width, height: self.bounds.height - FTDefaultMenuArrowHeight), cornerRadius: configuration.cornerRadius)
            //            path.move(to: CGPoint(x: arrowPoint.x - FTDefaultMenuArrowWidth, y: FTDefaultMenuArrowHeight))
            //            path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
            //            path.addLine(to: CGPoint(x: arrowPoint.x + FTDefaultMenuArrowWidth, y: FTDefaultMenuArrowHeight))
            //            path.close()
        }else{
            path.move(to: CGPoint(x: arrowPoint.x - FT.DefaultMenuArrowWidth, y: viewHeight - FT.DefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: viewHeight))
            path.addLine(to: CGPoint(x: arrowPoint.x + FT.DefaultMenuArrowWidth, y: viewHeight - FT.DefaultMenuArrowHeight))
            path.addLine(to: CGPoint(x: viewWidth - radius, y: viewHeight - FT.DefaultMenuArrowHeight))
            path.addArc(withCenter: CGPoint(x: viewWidth - radius, y: viewHeight - FT.DefaultMenuArrowHeight - radius),
                        radius: radius,
                        startAngle: .pi / 2,
                        endAngle: 0,
                        clockwise: false)
            path.addLine(to: CGPoint(x: viewWidth, y: radius))
            path.addArc(withCenter: CGPoint(x: viewWidth - radius, y: radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: .pi / 2 * 3,
                        clockwise: false)
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(withCenter: CGPoint(x: radius, y: radius),
                        radius: radius,
                        startAngle: .pi / 2 * 3,
                        endAngle: .pi,
                        clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: viewHeight - FT.DefaultMenuArrowHeight - radius))
            path.addArc(withCenter: CGPoint(x: radius, y: viewHeight - FT.DefaultMenuArrowHeight - radius),
                        radius: radius,
                        startAngle: .pi,
                        endAngle: .pi / 2,
                        clockwise: false)
            path.close()
            //            path = UIBezierPath(roundedRect: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.height - FTDefaultMenuArrowHeight), cornerRadius: configuration.cornerRadius)
            //            path.move(to: CGPoint(x: arrowPoint.x - FTDefaultMenuArrowWidth, y: self.bounds.size.height - FTDefaultMenuArrowHeight))
            //            path.addLine(to: CGPoint(x: arrowPoint.x, y: self.bounds.size.height))
            //            path.addLine(to: CGPoint(x: arrowPoint.x + FTDefaultMenuArrowWidth, y: self.bounds.size.height - FTDefaultMenuArrowHeight))
            //            path.close()
        }
        return path
    }
    
}

extension FTPopOverMenuView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configuration.menuRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (self.done != nil) {
            self.done(indexPath.row)
        }
    }
    
}

extension FTPopOverMenuView : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FTPopOverMenuCell = FTPopOverMenuCell(style: .default, reuseIdentifier: FT.PopOverMenuTableViewCellIndentifier)
        var imageObject: Imageable? = nil
        if menuImageArray != nil {
            if (menuImageArray?.count)! >= indexPath.row + 1 {
                imageObject = menuImageArray![indexPath.row]
            }
        }
        
        var cellConfiguration: FTCellConfiguration!
        if cellConfigurationArray != nil {
            cellConfiguration = cellConfigurationArray![indexPath.row]
        } else {
            cellConfiguration = FTCellConfiguration()
        }
        
        cell.setupCellWith(menuName: menuNameArray[indexPath.row], menuImage: imageObject, cellConfiguration: cellConfiguration)
        if (indexPath.row == menuNameArray.count-1) {
            cell.separatorInset = UIEdgeInsets.init(top: 0, left: bounds.size.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = configuration.menuSeparatorInset
        }
        cell.selectionStyle = configuration.cellSelectionStyle;
        return cell
    }
    
}



extension UIView {
    
     func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: CGRect.init(x: self.bounds.origin.x, y: self.bounds.origin.y, width: UIScreen.main.bounds.size.width-20, height: self.bounds.size.height)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
     func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

