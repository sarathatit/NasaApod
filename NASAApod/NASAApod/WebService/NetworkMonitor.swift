//
//  NetworkMonitor.swift
//  NASAApod
//
//  Created by Sarath kumar on 09/08/24.
//

import Foundation
import Network

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue.global(qos: .background)
    private(set) var isConnected: Bool = true
    
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                print("Network status: \(self?.isConnected == true ? "Connected" : "Disconnected")")
                
                // Notify observers about network status changes
                NotificationCenter.default.post(name: .networkStatusChanged, object: self?.isConnected)
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
