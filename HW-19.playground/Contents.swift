import Foundation
import CryptoKit
import SystemConfiguration

// MARK: Network Request

func getData(urlRequest: String) {
    if WiFiChecker.isWiFiAvailable() {
        guard let url = URL(string: urlRequest) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Done! Status Code: \(response.statusCode) -> ", terminator: "")
                if let data = data, let dataAsString = String(data: data, encoding: .utf8) {
                    parseData(dataAsString)
                }
            } else if let response = response as? HTTPURLResponse {
                print("Status Code: \(response.statusCode). Failed to fetch data. Verify the URL.")
            }
        }.resume()
    } else {
        print("Wi-Fi is not available")
    }
}

func parseData(_ dataAsString: String) {
    guard let jsonData = dataAsString.data(using: .utf8),
          let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
        print("JSON serialization failed")
        return
    }
    
    if let fact = jsonObject["facts"] {
        processFact(fact)
    } else if let data = jsonObject["data"] as? [String: Any],
              let results = data["results"] as? [[String: Any]],
              let character = results.first,
              let name = character["name"] as? String {
        print("Marvel Character Name: \(name)")
    } else {
        print("Key 'facts' or 'data' doesn't found")
    }
}

func processFact(_ fact: Any) {
    let stringValue = String(describing: fact)
    let cleanStringValue = stringValue.replacingOccurrences(of: "(", with: "")
        .replacingOccurrences(of: ")", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    print("Random fact about Dogs: \(cleanStringValue)")
}

// MARK: MD5 Hash Function

func MD5(string: String) -> String {
    let digest = Insecure.MD5.hash(data: Data(string.utf8))
    return digest.map { String(format: "%02hhx", $0) }.joined()
}

// MARK: URL Objects

let url = "https://dogapi.dog/api/facts/"
getData(urlRequest: url)

let marvelUrl = "https://gateway.marvel.com:443/v1/public/characters/1011136?ts=1&apikey=cbb2452d6645b4338f0e732373eb6647&hash=dbf085cf11af35cfb528412c9a11d58d"
getData(urlRequest: marvelUrl)


class WiFiChecker {
    
    static func isWiFiAvailable() -> Bool {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
}
