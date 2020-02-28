//  Copyright © 2020 Dmitrijs Beloborodovs. All rights reserved.

import Foundation

struct Currency: Codable, Hashable {
    let countryCode: String
}

struct Pair: Codable, Hashable {
    let source: Currency
    let target: Currency
    
    static func == (lhs: Pair, rhs: Pair) -> Bool {
        return lhs.source.countryCode == rhs.source.countryCode
            && lhs.target.countryCode == rhs.target.countryCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(source.countryCode)
        hasher.combine(target.countryCode)
    }
}

extension Currency {
    
    //TODO: temporary solution; should use localization instead
    // info from https://en.wikipedia.org/wiki/List_of_circulating_currencies
    // images from https://www.flaticon.com/packs/countrys-flags
    var currencyName: String {
        switch countryCode {
        case "AUD": return "Australian Dollar"
        case "BGN": return "Bulgarian Lev"
        case "BRL": return "Brazilian Real"
        case "CAD": return "Canadian Dollar"
        case "CHF": return "Swiss Franc"
        case "CNY": return "Chinese Yuan"
        case "CZK": return "Czech Koruna"
        case "DKK": return "Danish Krone"
        case "EUR": return "Euro"
        case "GBP": return "British Pound"
        case "HKD": return "Hong Kong Dollar"
        case "HRK": return "Croatian Kuna"
        case "HUF": return "Hungarian forint"
        case "IDR": return "Indonesian Rupiah"
        case "ILS": return "Israeli New Shekel"
        case "INR": return "Indian Rupee"
        case "ISK": return "Icelandic Króna"
        case "JPY": return "Japanese Yen"
        case "KRW": return "South Korean Won"
        case "MXN": return "Mexican Peso"
        case "MYR": return "Malaysian ringgit"
        case "NOK": return "Norwegian Krone"
        case "NZD": return "New Zealand dollar"
        case "PHP": return "Philippine peso"
        case "PLN": return "Polish złoty"
        case "RON": return "Romanian Leu"
        case "RUB": return "Russian ruble"
        case "SEK": return "Swedish Krona"
        case "SGD": return "Singapore dollar    "
        case "THB": return "Thai baht"
        case "USD": return "US Dollar"
        case "ZAR": return "South African rand"
        default:
            return countryCode
        }
    }
}


