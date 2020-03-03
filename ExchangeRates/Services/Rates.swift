//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation

protocol Rates {
    func rates(for pairs: [Pair], completion: @escaping (_ error: Error?, _ rates: [Pair: Float]) -> Void)
}

final class RatesService: Rates {

    static private let baseURL = "https://europe-west1-revolut-230009.cloudfunctions.net/revolut-ios"
    private lazy var urlSession: URLSession = {
        let internalURLSession = URLSession(configuration: .default)
        return internalURLSession
    }()

    func rates(for pairs: [Pair], completion: @escaping (_ error: Error?, _ rates: [Pair: Float]) -> Void) {
        guard var url = URL(string: RatesService.baseURL) else {
            DispatchQueue.main.async {
                completion(nil, [Pair: Float]())
            }
            return
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = pairs.map {
            URLQueryItem(name: "pairs", value: "\($0.source.countryCode)\($0.target.countryCode)")
        }
        if let modifiedURL = urlComponents?.url {
            url = modifiedURL
        }

        let request = URLRequest(url: url)

        let task = urlSession.dataTask(with: request) { (data, responce, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(error, [Pair: Float]())
                }
                return
            }
            let encodedRates: [String: Float]
            do {
                let decoder = JSONDecoder()
                encodedRates = try decoder.decode([String: Float].self, from: data)
            } catch {
                DispatchQueue.main.async {
                    completion(error, [Pair: Float]())
                }
                return
            }

            var result = [Pair: Float]()

            encodedRates.forEach { (key, value) in
                if key.count == 6 {
                    let pair = Pair(source: Currency(countryCode: String(key.prefix(3))),
                                    target: Currency(countryCode: String(key.suffix(3))))
                    result[pair] = value
                }
            }
            DispatchQueue.main.async {
                completion(error, result)
            }
        }
        task.resume()
    }
}

protocol RateObserver: class {
    func rateChanged()
}

protocol RatePublisher: class {
    func addObserver(_ observer: RateObserver)
    func removeObserver(_ observer: RateObserver)
    func rate(for pair: Pair) -> Float?
}

final class WeakObserver {
    weak var object: RateObserver?
    init(object: RateObserver) {
        self.object = object
    }
}
