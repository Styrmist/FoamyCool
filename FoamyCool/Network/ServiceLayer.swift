//
//  ServiceLayer.swift
//  FoamyCool
//
//  Created by Kyrylo Danylov on 9/28/19.
//  Copyright © 2019 Kyrylo Danylov. All rights reserved.
//

import Foundation

class ServiceLayer {
    class func request<T: Codable>(router: Router, completion: @escaping (Result<T, Error>) -> ()) {
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.path = router.path
        components.queryItems = router.parameters
        guard let url = components.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in

            if error != nil {
                completion(.failure(error!))
                print(error!.localizedDescription)
                return
            }
            guard response != nil else { return }
            guard let data = data else { return }

            guard let responseObject = try? JSONDecoder().decode(T.self, from: data) else {
                return
            }
            DispatchQueue.main.async {
                completion(.success(responseObject))
            }
        }
        dataTask.resume()
    }
}
