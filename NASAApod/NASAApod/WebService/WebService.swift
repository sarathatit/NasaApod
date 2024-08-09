//
//  WebService.swift
//  NASAApod
//
//  Created by Sarath kumar on 09/08/24.
//

import Foundation
import Combine

class WebService {
    
    var cancellable = Set<AnyCancellable>()
    
    func getData() -> Future<ApodModel, ServiceError> {
        return Future { promise in
            
            guard let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=B0UMxhVT1jmNr8gkeS4CaeZkmYf7ARTLX0mWkd3z") else {
                return promise(.failure(.networkError(description: "Invalid URL")))
            }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap { (data, response) in
                    guard let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                        throw ServiceError.networkError(description: "Invalid Response")
                    }
                    return data
                }
                .decode(type: ApodModel.self, decoder: JSONDecoder())
                .sink { completion in
                    if case let .failure(error) = completion {
                        switch error {
                        case _ as DecodingError:
                            promise(.failure(.parseError(description: "Failed to pare the data")))
                        default:
                            promise(.failure(.networkError(description: "Not able to get the data")))
                        }
                    }
                } receiveValue: { response in
                    return promise(.success(response))
                }
                .store(in: &self.cancellable)

        }
    }
}
