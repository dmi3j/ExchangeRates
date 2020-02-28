//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation

protocol Storage {
    var availableCurrencies: [Currency] { get }
    func save(_ pairs: [Pair])
    func load() -> [Pair]
}

final class StorageService: Storage {

    lazy var availableCurrencies: [Currency] = {
        let result: [Currency]
        if let path = Bundle.main.path(forResource: "currencies", ofType: "json"),
            let availableCurrenciesCodes: [String] = load(from: path) {
            result = availableCurrenciesCodes.map({ Currency(countryCode: $0.uppercased()) })
        } else {
            result = [Currency]()
        }
        return result
    }()

    func save(_ pairs: [Pair]) {
        guard let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            else { return }
        save(pairs, to: documentsDir.appending("/pair.json"))
    }

    func load() -> [Pair] {
        guard let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        else { return [Pair]() }

        if let storedPairs: [Pair] = load(from: documentsDir.appending("/pair.json")) {
             return storedPairs
        } else {
            return [Pair]()
        }
    }
}

private extension StorageService {

    func load<T: Decodable>(from path: String, as type: T.Type = T.self) -> T? {
        let data: Data

        do {
            data = try Data(contentsOf: URL(fileURLWithPath: path))
        } catch {
            debugPrint("Couldn't load \(path) from main bundle:\n\(error)")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            debugPrint("Couldn't parse \(path) as \(T.self):\n\(error)")
            return nil
        }
    }

    func save<T: Encodable>(_ data: T, to path: String) {
        let url = URL(fileURLWithPath: path)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let JsonData = try encoder.encode(data)
            try JsonData.write(to: url)
        } catch {
            debugPrint("Couldn't save to \(path)")
        }
    }
}
