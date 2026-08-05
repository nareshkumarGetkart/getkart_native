import SwiftUI
import UIKit

struct VerticalPager<Page: View>: UIViewRepresentable {

    @Binding var index: Int
    let count: Int
    let spacing: CGFloat
    let content: (Int) -> Page

    init(
        index: Binding<Int>,
        count: Int,
        spacing: CGFloat = 0,
        @ViewBuilder content: @escaping (Int) -> Page
    ) {
        self._index = index
        self.count = count
        self.spacing = spacing
        self.content = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {

        let scrollView = UIScrollView()

        scrollView.delegate = context.coordinator
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.bounces = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .black

        context.coordinator.scrollView = scrollView

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {

        context.coordinator.parent = self

        // NEW — find and store the real owning view controller once the
        // scroll view is actually in a window/VC hierarchy. Needed so
        // fullScreenCover/sheet presented from inside hosted pages
        // (e.g. SafariView) have a valid presentation context.
        if context.coordinator.hostingParentVC == nil {
            context.coordinator.hostingParentVC = scrollView.findParentViewController()
        }

        context.coordinator.reloadIfNeeded()
    }
}

// NEW — walks the responder chain to find the owning UIViewController
private extension UIView {
    func findParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc
            }
            responder = r.next
        }
        return nil
    }
}

extension VerticalPager {

    final class Coordinator: NSObject, UIScrollViewDelegate {

        var parent: VerticalPager
        weak var scrollView: UIScrollView?
        weak var hostingParentVC: UIViewController?   // NEW

        private var controllers: [Int: UIHostingController<Page>] = [:]
        private var currentPage = 0
        private var isProgrammaticScroll = false

        init(_ parent: VerticalPager) {
            self.parent = parent
        }

        func reloadIfNeeded() {

            guard let scrollView else { return }

            let height = scrollView.bounds.height
            let width = scrollView.bounds.width

            guard height > 0 else {
                DispatchQueue.main.async { self.reloadIfNeeded() }
                return
            }

            scrollView.contentSize = CGSize(
                width: width,
                height: CGFloat(max(parent.count, 1)) * height
            )

            layoutVisiblePages()

            let offset = CGPoint(x: 0, y: CGFloat(parent.index) * height)

            if scrollView.contentOffset != offset {
                isProgrammaticScroll = true
                scrollView.setContentOffset(offset, animated: false)
                isProgrammaticScroll = false
            }
        }

        private func layoutVisiblePages() {

            guard let scrollView else { return }

            let page = parent.index

            let needed = [
                max(page - 1, 0),
                page,
                min(page + 1, parent.count - 1)
            ]

            removeUnusedPages(needed)

            for index in needed {
                addPage(index)
            }
        }

        private func addPage(_ index: Int) {

            guard controllers[index] == nil else {
                updateFrame(index)
                return
            }

            guard index >= 0, index < parent.count else { return }
            guard let scrollView else { return }

            let host = UIHostingController(rootView: parent.content(index))

            host.view.backgroundColor = .clear
            host.view.translatesAutoresizingMaskIntoConstraints = true

            if #available(iOS 16.4, *) {
                host.safeAreaRegions = SafeAreaRegions()
            }

            // NEW — properly parent the hosting controller so SwiftUI's
            // presentation system (fullScreenCover, sheet, dismiss) works
            // correctly for views hosted inside this scroll view.
            if let parentVC = hostingParentVC {
                parentVC.addChild(host)
                scrollView.addSubview(host.view)
                host.didMove(toParent: parentVC)
            } else {
                scrollView.addSubview(host.view)
            }

            controllers[index] = host

            updateFrame(index)
        }

        private func updateFrame(_ index: Int) {

            guard let scrollView else { return }
            guard let host = controllers[index] else { return }

            // Keep the hosted view's data (like isCurrent) in sync with the latest state.
            host.rootView = parent.content(index)

            let width = scrollView.bounds.width
            let height = scrollView.bounds.height

            host.view.frame = CGRect(
                x: 0,
                y: CGFloat(index) * height,
                width: width,
                height: height
            )
        }

        private func removeUnusedPages(_ needed: [Int]) {

            for (page, controller) in controllers {
                if !needed.contains(page) {

                    // NEW — properly remove from parent VC hierarchy too.
                    controller.willMove(toParent: nil)
                    controller.view.removeFromSuperview()
                    controller.removeFromParent()

                    controllers.removeValue(forKey: page)
                }
            }
        }

        // MARK: - UIScrollViewDelegate

        func scrollViewDidScroll(_ scrollView: UIScrollView) {

            guard !isProgrammaticScroll else { return }

            let height = scrollView.bounds.height
            guard height > 0 else { return }

            let page = Int(round(scrollView.contentOffset.y / height))

            if page != currentPage {

                currentPage = page

                if page >= 0 && page < parent.count {
                    DispatchQueue.main.async {
                        self.parent.index = page
                        self.layoutVisiblePages()
                    }
                }
            }
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate { snap(scrollView) }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            snap(scrollView)
        }

        private func snap(_ scrollView: UIScrollView) {

            let height = scrollView.bounds.height
            guard height > 0 else { return }

            let page = Int(round(scrollView.contentOffset.y / height))
            let safePage = max(0, min(parent.count - 1, page))

            currentPage = safePage

            DispatchQueue.main.async {
                self.parent.index = safePage
            }

            UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
                scrollView.contentOffset = CGPoint(x: 0, y: CGFloat(safePage) * height)
            }

            layoutVisiblePages()
        }
    }
}
