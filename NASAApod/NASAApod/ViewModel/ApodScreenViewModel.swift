//
//  ApodScreenViewModel.swift
//  NASAApod
//
//  Created by Sarath kumar on 09/08/24.
//

import Foundation
import Combine
import Network

class ApodScreenViewModel: ObservableObject {
    
    @Published var apodModel: ApodModel?
    var cancellable = Set<AnyCancellable>()
    let service: WebService
    var monitor: NWPathMonitor?
    var isConnected: Bool = true
    
    init(service: WebService) {
        self.service = service
        startNetworkMonitoring()
        getData()
    }
    
    deinit {
        stopNetworkMonitoring()
    }
    
    // MARK: - Service Call Methods
    private func getData() {
        if isConnected {
            service.getData()
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        print("error", error)
                    case .finished:
                        print("completion")
                    }
                } receiveValue: { [weak self] respones in
                    self?.apodModel = respones
                    self?.saveData(respones)
                }
                .store(in: &self.cancellable)
        } else {
            loadStoredData()
        }
    }

    // MARK: - Local Saving
    private func saveData(_ apod: ApodModel) {
        if let encoded = try? JSONEncoder().encode(apod) {
            UserDefaults.standard.set(encoded, forKey: "cachedApod")
            UserDefaults.standard.set(Date(), forKey: "lastSeenDate")
        }
    }
    
    private func loadStoredData() {
        if let savedApodData = UserDefaults.standard.data(forKey: "cachedApod"),
           let lastSeenDate = UserDefaults.standard.object(forKey: "lastSeenDate") as? Date{
            apodModel = try? JSONDecoder().decode(ApodModel.self, from: savedApodData)
        }
    }
}

// MARK: - NetWork methods

extension ApodScreenViewModel {
    
        private func startNetworkMonitoring() {
            monitor = NWPathMonitor()
            let queue = DispatchQueue.global(qos: .background)
            monitor?.start(queue: queue)
            
            monitor?.pathUpdateHandler = { [weak self] path in
                self?.isConnected = path.status == .satisfied
                if self?.isConnected == false {
                    DispatchQueue.main.async {
                        self?.loadStoredData()
                    }
                }
            }
        }
        
        private func stopNetworkMonitoring() {
            monitor?.cancel()
        }
}
