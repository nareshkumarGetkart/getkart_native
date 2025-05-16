//
//  ZoomImageViewController.swift

//

import UIKit
import Kingfisher
import SwiftUI
import Photos

class ZoomImageViewController: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var parentZoomingScrollView : UIScrollView!
    @IBOutlet weak var pager:UIPageControl!
    @IBOutlet weak var btnDownload: UIButton!
    private var childZoomingScrollView :UIScrollView!
    var currentTag:NSInteger = 0
    var imageArrayUrl:Array = [GalleryImage]()
    private  var imageZoom : UIImageView!
    private var imageColor:UIColor = .black
    
    //MARK: Controller life cycle methods
    override func loadView() {
        super.loadView()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = imageColor
        btnBack.setImageColor(color: .black)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomAction(tappedIndex: currentTag)
        pager.isHidden = (imageArrayUrl.count > 1) ? false : true
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        swipeDown.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func downloadBtnAction(_ sender: UIButton) {
        
        
        if imageArrayUrl.count > pager.currentPage{
            if let url = URL(string: imageArrayUrl[pager.currentPage].image ?? ""){
                self.downloadAndSaveToPhotos(url: url)
            }
        }
        
        // self.downloadAllMedia(urlArray: [imageArrayUrl[currentTag].image ?? ""])
        
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
            
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Swipe Down")
            setNeedsStatusBarAppearanceUpdate()
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @objc func handleDoubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let scroll = parentZoomingScrollView.viewWithTag(888888) as! UIScrollView
        let childScroll = scroll.viewWithTag(90000 + currentTag) as! UIScrollView
        let newScale: CGFloat = scroll.zoomScale * 1.5
        let zoomRect = self.zoomRect(forScale: newScale, withCenter: gestureRecognizer.location(in: gestureRecognizer.view))
        childScroll.zoom(to: zoomRect, animated: true)
    }
    
    func zoomAction(tappedIndex: Int){
        
        let SCREEN_WIDTH = ((UIApplication.shared.statusBarOrientation == .portrait) || (UIApplication.shared.statusBarOrientation == .portraitUpsideDown) ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height)
        let SCREEN_HEIGHT = ((UIApplication.shared.statusBarOrientation == .portrait) || (UIApplication.shared.statusBarOrientation == .portraitUpsideDown) ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width)
        
        var X:CGFloat = 0
        
        parentZoomingScrollView.isUserInteractionEnabled = true
        parentZoomingScrollView.tag = 888888
        parentZoomingScrollView.delegate = self
        
        for i in 0..<imageArrayUrl.count {
            childZoomingScrollView = UIScrollView(frame: CGRect(x: CGFloat(X), y: CGFloat(0), width: CGFloat(SCREEN_WIDTH ), height: CGFloat(SCREEN_HEIGHT - 160)))
            childZoomingScrollView.isUserInteractionEnabled = true
            childZoomingScrollView.tag = 90000 + i
            childZoomingScrollView.delegate = self
            parentZoomingScrollView.addSubview(childZoomingScrollView)
            imageZoom = UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(SCREEN_WIDTH), height: CGFloat(SCREEN_HEIGHT - 160)))
            
            imageZoom.contentMode = .scaleAspectFit
            self.view.backgroundColor = .darkGray
            imageZoom.kf.setImage(with: URL(string: imageArrayUrl[i].image ?? ""), options: nil, progressBlock: nil) { response in
                // self.view.backgroundColor = self.imageZoom.image?.getAverageColour
            }
            
            
            //            imageZoom.kf.setImage(with: URL(string: imageArrayUrl[i]), placeholder: UIImage(named: "dummy"), options: [.waitForCache], progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
            //             if (image != nil){
            //                self.imageZoom.image = image
            //                 self.view.backgroundColor = self.imageZoom.image?.getAverageColour
            //             }
            //             else {
            //             }
            //             })
            
            imageZoom.isUserInteractionEnabled = true
            imageZoom.tag = 10
            childZoomingScrollView.addSubview(imageZoom)
            childZoomingScrollView.maximumZoomScale = 5.0
            childZoomingScrollView.clipsToBounds = true
            childZoomingScrollView.contentSize = CGSize(width: CGFloat(SCREEN_WIDTH), height: CGFloat(SCREEN_HEIGHT - 120))
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap))
            doubleTap.numberOfTapsRequired = 2
            imageZoom.addGestureRecognizer(doubleTap)
            X += SCREEN_WIDTH
        }
        
        parentZoomingScrollView.contentSize = CGSize(width: CGFloat(X), height: CGFloat(SCREEN_WIDTH))
        parentZoomingScrollView.isPagingEnabled = true
        //let Y: CGFloat = 70 + SCREEN_HEIGHT - 120 + 5
        //SET a property of UIPageControl
        pager.backgroundColor = UIColor.clear
        pager.numberOfPages = imageArrayUrl.count
        //as we added 3 diff views
        parentZoomingScrollView.setContentOffset(CGPoint(x: Int(SCREEN_WIDTH)*tappedIndex, y: 0), animated: false)
        pager.currentPage = tappedIndex
        pager.isHighlighted = true
        pager.pageIndicatorTintColor = UIColor.black
        pager.currentPageIndicatorTintColor = Themes.sharedInstance.themeColor // UIColor.red
        
        let newPosition = SCREEN_WIDTH * CGFloat(self.pager.currentPage)
        let toVisible = CGRect(x: CGFloat(newPosition), y: CGFloat(70), width: CGFloat(SCREEN_WIDTH), height: CGFloat(SCREEN_HEIGHT - 120))
        self.parentZoomingScrollView.scrollRectToVisible(toVisible, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView.viewWithTag(90000 + currentTag) as? UIScrollView != nil{
            let scroll = scrollView.viewWithTag(90000 + currentTag) as! UIScrollView
            let image = scroll.viewWithTag(10) as! UIImageView
            return image
        }else{
            return nil
        }
    }
    
    func zoomRect(forScale scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let scroll = parentZoomingScrollView.viewWithTag(888888) as! UIScrollView
        let childScroll = scroll.viewWithTag(90000 + currentTag) as! UIScrollView
        zoomRect.size.height = childScroll.frame.size.height / scale
        zoomRect.size.width = childScroll.frame.size.width / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
}

//MARK:- UIScrollView
extension ZoomImageViewController : UIScrollViewDelegate {
    
 
    
    func downloadAndSaveToPhotos(url: URL) {
        DispatchQueue.main.async {
            Themes.sharedInstance.activityView(uiView: self.view)
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    Themes.sharedInstance.removeActivityView(uiView: self.view)
                }
                return
            }

            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Do UI work on the main thread
                    DispatchQueue.main.async {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        AlertView.sharedManager.showToast(message: "Downloaded successfully")
                        Themes.sharedInstance.removeActivityView(uiView: self.view)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("Permission denied to access photo library")
                        AlertView.sharedManager.showToast(message: "Permission denied to access photo library")
                        Themes.sharedInstance.removeActivityView(uiView: self.view)
                    }
                }
            }
        }.resume()
    }

    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 888888{
            let pageWidth: CGFloat = self.parentZoomingScrollView.frame.size.width
            let page = floor((self.parentZoomingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
            self.currentTag = NSInteger(page)
            self.pager.currentPage = Int(page)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag == 888888{
            let pageWidth: CGFloat = self.parentZoomingScrollView.frame.size.width
            let page = floor((self.parentZoomingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
            
            let fullurl = imageArrayUrl[self.currentTag].image ?? ""

            UIImageView().kf.setImage(with: URL(string: fullurl), placeholder: UIImage(named: "getkartPlaceholder"), options: [.waitForCache], progressBlock: nil, completionHandler: {_ in // image, error, cacheType, imageURL in
//                if (image != nil){
//                   // self.view.backgroundColor = image?.getAverageColour
//                }
//                else {
//                    // cell.imgv.image = UIImage.init(named: "user")
//                }
            })
            
        }
    }
}
