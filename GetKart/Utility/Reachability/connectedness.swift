import Foundation

protocol NetworkSpeedDelegate: AnyObject {
    func speedDidChange(speed: NetworkSpeed)
}

public enum NetworkSpeed: String {
    case slow
    case medium
    case fast
    case hostUnreachable
}

/// Class that tests the network quality for a given url
final class NetworkSpeedTester {
    
    private(set) var currentNetworkSpeed = NetworkSpeed.fast
    
    /// Delegate called when the network speed changes
    weak var delegate: NetworkSpeedDelegate?
    
    private let testURL: URL
    
    private var timerForSpeedTest: Timer?
    private let updateInterval: TimeInterval
    private let urlSession: URLSession
    
    
    /// Create a new instance of network speed tester.
    /// You need to call start / stop on this instance.
    ///
    /// - Parameters:
    ///   - updateInterval: the time interval in seconds to elapse between checks
    ///   - testUrl: the test url to check against
    init(updateInterval: TimeInterval, testUrl: URL) {
        self.updateInterval = updateInterval
        self.testURL = testUrl
        
        let urlSessionConfig = URLSessionConfiguration.ephemeral
        urlSessionConfig.timeoutIntervalForRequest = updateInterval - 1.0
        urlSessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.urlSession = URLSession(configuration: urlSessionConfig)
    }
    
    deinit {
        stop()
    }
    
    /// Starts the check
    func start() {
        timerForSpeedTest = Timer.scheduledTimer(timeInterval: updateInterval,
                                                 target: self,
                                                 selector: #selector(testForSpeed),
                                                 userInfo: nil,
                                                 repeats: true)
    }
    
    /// Stops the check
    func stop(){
        timerForSpeedTest?.invalidate()
        timerForSpeedTest = nil
    }
    
    @objc private func testForSpeed() {
        Task {
            let startTime = Date()
            
            do {
                _ = try await urlSession.data(for: URLRequest(url: testURL))
                let endTime = Date()
                
                let duration = abs(endTime.timeIntervalSince(startTime))
                print("duration: \(duration)")
                
                switch duration {
                case 0.0...2.0:
                    currentNetworkSpeed = .fast
                    delegate?.speedDidChange(speed: .fast)
                case 2.1...5.0:
                    currentNetworkSpeed = .medium
                    delegate?.speedDidChange(speed: .medium)
                    
                default:
                    currentNetworkSpeed = .slow
                    delegate?.speedDidChange(speed: .slow)
                }
            } catch let error {
                guard let urlError = error as? URLError else {
                    return
                }
                
                switch urlError.code {
                case    .cannotConnectToHost,
                        .cannotFindHost,
                        .clientCertificateRejected,
                        .dnsLookupFailed,
                        .networkConnectionLost,
                        .notConnectedToInternet,
                        .resourceUnavailable,
                        .serverCertificateHasBadDate,
                        .serverCertificateHasUnknownRoot,
                        .serverCertificateNotYetValid,
                        .serverCertificateUntrusted,
                        .timedOut:
                    currentNetworkSpeed = .hostUnreachable
                    delegate?.speedDidChange(speed: .hostUnreachable)
                default:
                    break
                }
            }
        }
    }
}
