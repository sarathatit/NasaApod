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
    var isRevisitingToday = false
    
    var showAlertClosure: (() -> Void)?
    
    init(service: WebService) {
        self.service = service
        observeNetworkStatus()
    }
    
    private func observeNetworkStatus() {
        NotificationCenter.default.publisher(for: .networkStatusChanged)
            .sink { [weak self] notification in
                if let isConnected = notification.object as? Bool {
                    self?.getData(isConnected)
                }
            }
            .store(in: &cancellable)
    }
    
    // MARK: - Service Call Methods
    private func getData(_ isConnected: Bool) {
        if isConnected {
            isRevisitingToday = self.checkRevisitingToday()
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
            if shouldShowAlert() {
                showAlertClosure?()
            }
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
           let _ = UserDefaults.standard.object(forKey: "lastSeenDate") as? Date{
            apodModel = try? JSONDecoder().decode(ApodModel.self, from: savedApodData)
        }
    }
    
    private func shouldShowAlert() -> Bool {
        if let lastSeenDate = UserDefaults.standard.object(forKey: "lastSeenDate") as? Date {
            return !Calendar.current.isDateInToday(lastSeenDate)
        }
        return true
    }
    
    private func checkRevisitingToday() -> Bool {
        if let lastSeenDate = UserDefaults.standard.object(forKey: "lastSeenDate") as? Date {
            return Calendar.current.isDateInToday(lastSeenDate)
        }
        return false
    }
    
}

