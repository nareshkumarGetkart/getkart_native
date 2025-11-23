//
//  TransactionHistoryPreview.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 21/04/25.
//

import SwiftUI
import PDFKit
import QuickLook

struct TransactionHistoryPreview: View {
    
    let transaction: TransactionModel?
    var navController:UINavigationController?
    @State private var pdfUrlString = ""
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var downloadedFileURL: URL? = nil
    @State private var showPDF = false
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                navigationHeader().frame(height: 44)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {

                        // ---- Your existing content ----
                        VStack {
                            Image("success")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .padding(.vertical, 5)

                            Text("Payment successful")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color(UIColor.label))

                            Text("Successfully paid \(Local.shared.currencySymbol) \((transaction?.paymentTransaction?.amount ?? 0.0).formatNumber())")
                                .foregroundColor(.gray)
                                .font(Font.manrope(.regular, size: 16.0))

                            HStack{}.frame(height: 10)
                        }

                        HStack{
                            Text("Payment methods")
                                .font(Font.manrope(.bold, size: 16.0))
                            Spacer()
                        }

                        if transaction?.package?.type == "campaign" {
                            bannerAnalyticsdetailsCard()
                        } else {
                            detailsCard()
                        }

                        Button(action: {}) {
                            Text("Total Cost \(Local.shared.currencySymbol)\((transaction?.paymentTransaction?.amount ?? 0.0).formatNumber())")
                                .font(Font.manrope(.bold, size: 18.0))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(24)
                        }
                        .padding(.horizontal)

                        Button(action: {
                            getPdfUrlFromView()

                        }) {
                            Text("Download Invoice")
                                .font(Font.manrope(.bold, size: 18.0))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray3))
                                .cornerRadius(24)
                        }
                        .padding(.horizontal)

                    }
                    .padding(.vertical)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding([.horizontal,.top],10)
                .cornerRadius(10)
                .background(Color(.systemGray6))
            }
            .navigationBarHidden(true)

            // ---- TOP TOAST FIX ----
            if showToast {
                ToastView(message: toastMessage) {
                    // handle tap
                    showToast = false
                    //showPDF = true
                    if let url = downloadedFileURL {
                        let viewPdf = UIHostingController(rootView: PDFViewerWithActions(url: url))
                        self.navController?.pushViewController(viewPdf, animated: true)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)  // ⬅ PIN TO TOP
                .padding(.top, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(20)
            }
            
           
        } // PDF full-screen sheet
        .sheet(isPresented: $showPDF) {
            if let url = downloadedFileURL {
                PDFViewer(url: url)
               // QuickLookPDF(url: url)
                
                

            } else {
                Text("Could not find the file.")
            }
        }
        .animation(.spring(), value: showToast)
    }

    
    @ViewBuilder
    private func detailRow(title: String, value: String, isCopyable: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(Font.manrope(.medium, size: 16.0))
                .foregroundColor(.gray)
            Spacer()
            HStack(spacing: 4) {
               
                if isCopyable {
                  
                    Image("ic_baseline-content-copy")
                        .font(.subheadline)
                        .foregroundColor(.gray).onTapGesture {
                            UIPasteboard.general.string = transaction?.paymentTransaction?.orderID ?? ""
                            AlertView.sharedManager.showToast(message: "Copied successfully")
                        }
                }
                Text(value)
                    .multilineTextAlignment(.trailing)
                    .font(Font.manrope(.semiBold, size: 16.0))
                    .foregroundColor(Color(UIColor.label))
                
            }
        }
    }
    
    
    
    func getConvertedDateFromDate(date:Date) -> String{
        let dateFormatter = DateFormatter()
       
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: date)

    }
    
    func convertTimestamp(isoDateString:String) -> Int64 {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC time
        
        if let date = isoFormatter.date(from: isoDateString) {
            // print("Converted Date:", date)
            
            let timestamp = Int64(date.timeIntervalSince1970) // Convert to seconds
            
            // print("Timestamp from ISO Date:", timestamp)
            return timestamp
            
            
        } else {
            
            print("Invalid date format")
            return 0
        }
    }







@ViewBuilder
private func navigationHeader() -> some View {
    HStack {
        Button(action: {
            navController?.popViewController(animated: true)
        }) {
            Image("arrow_left")
                .renderingMode(.template)
                .foregroundColor(Color(UIColor.label))
                .padding()
        }
        Text("Order Details")
            .font(.custom("Manrope-Bold", size: 20.0))
            .foregroundColor(Color(UIColor.label))
        Spacer()
    }
    .frame(height: 44)
}



@ViewBuilder
private func detailsCard() -> some View {
    VStack(spacing: 12) {
        let date = Date(timeIntervalSince1970: TimeInterval(convertTimestamp(isoDateString: transaction?.paymentTransaction?.createdAt ?? "")))

        detailRow(title: "Name", value: "\(transaction?.package?.name ?? "")")
        detailRow(title: "Category", value:"\(transaction?.package?.category ?? "")")
        detailRow(title: "Location", value: "\(transaction?.paymentTransaction?.city ?? "")")
        detailRow(title: "Bought pack", value: "\(transaction?.package?.itemLimit ?? "") Ads")

        detailRow(title: "Transaction ID", value: transaction?.paymentTransaction?.orderID ?? "", isCopyable: true)
        detailRow(title: "Date", value: getConvertedDateFromDate(date: date))
        detailRow(title: "Purchase from", value: "\(transaction?.paymentTransaction?.paymentGateway?.capitalized ?? "")")
        detailRow(title: "Package validity", value: "\(transaction?.package?.duration ?? "") days")

        
        if (transaction?.remainingDays ?? "") ==  "0" {
            HStack {
                Text("Expires after")
                    .foregroundColor(.gray)
                Spacer()
                Text("Expired")
                    .foregroundColor(.red)
            }
        } else {
            detailRow(title: "Expires after", value: "\(transaction?.remainingDays ?? "") days")
        }

        HStack {
            Text("Active Ads")
                .foregroundColor(.green)
            Spacer()
            Text("\(transaction?.usedLimit ?? 0) Ads")
                .foregroundColor(.primary)
        }

        HStack {
            Text("Remaining Ads")
                .foregroundColor(.orange)
            Spacer()
            Text("\(transaction?.remainingItemLimit ?? 0) Ads")
                .foregroundColor(.primary)
        }
    }
    .padding()
    .background(Color(UIColor.systemBackground))
    .cornerRadius(16)
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color(hex:"#DADADA"), lineWidth: 0.5)
    )
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
}


    
    @ViewBuilder
    private func bannerAnalyticsdetailsCard() -> some View {
        VStack(spacing: 12) {
            let date = Date(timeIntervalSince1970: TimeInterval(convertTimestamp(isoDateString: transaction?.paymentTransaction?.createdAt ?? "")))

            detailRow(title: "Name", value: "\(transaction?.package?.name ?? "")")
          //  detailRow(title: "Category", value:"\(transaction?.package?.category ?? "")")
            detailRow(title: "Location", value: "\(transaction?.paymentTransaction?.city ?? "")")
            detailRow(title: "Bought pack", value: "\(transaction?.package?.itemLimit ?? "") clicks")

            detailRow(title: "Transaction ID", value: transaction?.paymentTransaction?.orderID ?? "", isCopyable: true)
            detailRow(title: "Date", value: getConvertedDateFromDate(date: date))
            detailRow(title: "Purchase from", value: "\(transaction?.paymentTransaction?.paymentGateway?.capitalized ?? "")")
           
          //  BannerAnalyticCell(title: "Status", value: "", isActive: true)
            
            
                HStack {
                   
                    Spacer()
                    
                    Button(action:{
                        pushToBannerAnalytics()
                    },label:{
                        
                        Text("Banner analytics").foregroundColor(.blue).underline().font(.manrope(.regular, size: 17))
                    })
                    
                    Spacer()
                }.padding(.top,10).padding(.bottom,10)
         
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex:"#DADADA"), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }


    func pushToBannerAnalytics(){
        if let bannerId = transaction?.banners?.first?.id{
            let swiftView = BannerAlalyticsView(navigationController: self.navController, bannerId: bannerId)
            let destVC = UIHostingController(rootView: swiftView)
            self.navController?.pushViewController(destVC, animated: true)
        }
      
        
    }
    
    // MARK: SAVE TO FILES
       func saveToFiles(url: URL) {
           let controller = UIDocumentPickerViewController(forExporting: [url])
           controller.allowsMultipleSelection = false
           UIApplication.shared.windows.first?.rootViewController?
               .present(controller, animated: true)
       }
    
    func getPdfUrlFromView(){
        
      
        if let invoiceId = transaction?.invoiceId {
            URLhandler.sharedinstance.makeCall(url: "\(Constant.shared.invoice_download)/\(invoiceId)", param: nil,methodType: .get) { responseObject, error in
                
                if error == nil {
                    
                    
                 
               
                      if  let result = responseObject{
                        if let data = result["data"] as? String{
                            pdfUrlString = data
                            
                            self.toastMessage = "Invoice downloaded successfully."
                            self.showToast = true
                            //  startDownload()
                            if let pdfUlr = URL(string: data){
                                
                                downloadedFileURL = pdfUlr
                            }
                        }

                    }
                }
            }
        }
    }
    
    // MARK: - Download logic
       
        
       
    

    func downloadPDF(from urlString: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: urlString) else  {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let localURL = localURL else {
                completion(.failure(URLError(.cannotCreateFile)))
                return
            }

            // Move the downloaded file to a permanent location
            do {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)

                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                completion(.success(destinationURL))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

}

#Preview {
    TransactionHistoryPreview(transaction: nil)
}



// MARK: - Toast View
struct ToastView: View {
    let message: String
    var onTap: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image("Logo") // optional small app logo, replace with system image if not present
                    .resizable()
                    .frame(width: 60, height: 20)
                    .cornerRadius(3)
                    .padding(.leading, 8)
                   // .opacity(0.0) // hide by default; keep placeholder so it matches layout if you add a logo
                VStack(alignment: .leading, spacing: 2) {
                    Text("Download Complete")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Your invoice was downloaded. Tap here to see it.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(Date(), style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.trailing, 8)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)).shadow(radius: 6))
            .padding(.horizontal)
            .onTapGesture {
                onTap()
            }
            
            Spacer()
        }
        .padding(.top, 8)
    }
}




// MARK: - PDF Viewer (PDFKit wrapper)
struct PDFViewer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let v = PDFView()
        v.autoScales = true
        v.displayMode = .singlePageContinuous
        v.displayDirection = .vertical
        v.backgroundColor = .systemGroupedBackground
        
        if let doc = PDFDocument(url: url) {
            v.document = doc
        } else {
            // if not a PDF, try to show image
            if let img = UIImage(contentsOfFile: url.path) {
                let data = img.pngData()
                if let data = data, let doc = PDFDocument(data: data) {
                    v.document = doc
                }
            }
        }
        return v
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - URLSession Delegate for progress
class SessionDelegate: NSObject, URLSessionDownloadDelegate {
    private let progressHandler: (Double) -> Void
    
    init(progressHandler: @escaping (Double) -> Void) {
        self.progressHandler = progressHandler
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressHandler(progress)
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {

        // Handle temp file "location"
        print("File downloaded to: \(location)")
    }

}



import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
//PDFKitView(url: Bundle.main.url(forResource: "sample", withExtension: "pdf")!)


struct PDFViewerWithActions: View {
    let url: URL
    
    @State private var showShareSheet = false
    
    var body: some View {
        VStack {
            PDFKitView(url: url)
        }
        .navigationBarTitle("Invoice", displayMode: .inline)
        .toolbar {
            
            // SHARE BUTTON
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            // DOWNLOAD BUTTON
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    saveToFiles(url: url)
                } label: {
                    Image(systemName: "arrow.down.circle")
                }
            }
        }.navigationBarHidden(false)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [url])
        }
    }
    
    // MARK: SAVE TO FILES
    func saveToFiles(url: URL) {
        let controller = UIDocumentPickerViewController(forExporting: [url])
        controller.allowsMultipleSelection = false
        UIApplication.shared.windows.first?.rootViewController?
            .present(controller, animated: true)
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
