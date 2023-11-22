import Foundation
import CryptoKit

let url = "https://dogapi.dog/api/facts/"

// MARK: Base Network Request

func getData(urlRequest: String) {
    let urlRequest = URL(string: urlRequest)
    guard let url = urlRequest else { return }
    URLSession.shared.dataTask(with: url) { data, response, error in
        
        if error != nil {
            if let error = error {
                print("Error: \(String(describing: error.localizedDescription))")
            }
        } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
            print("Done! Status Code: \(response.statusCode)")
            guard let data = data else { return }
            let dataAsString = String(data: data, encoding: .utf8)
            guard let finalData = dataAsString else { return }
            
            if let jsonData = finalData.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                if let header = jsonObject["facts"] {
                    if let fact = jsonObject["facts"] {
                        let stringValue = String(describing: fact)
                        let cleanStringValue = stringValue.replacingOccurrences(of: "(", with: "")
                            .replacingOccurrences(of: ")", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        print("Random fact about Dogs: \(cleanStringValue)")
                    } else {
                        print("Key 'facts' doesn't found")
                    }
                } else {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let data = jsonObject["data"] as? [String: Any],
                           let results = data["results"] as? [[String: Any]],
                           let character = results.first,
                           let name = character["name"] as? String {
                            print("Character Name: \(name)")
                        } else {
                            print("Failed to extract character name")
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
//                    else {
//                       print("JSON serialization failed")
//                   }
                }
                             
            } else {
                if let response = response as? HTTPURLResponse {
                    print("Status Code: \(response.statusCode). Failed to fetch data. Verify the URL.")
                }
            }
        }
    }.resume()
}

getData(urlRequest: url)

// MARK: 🌟🌟🌟

func MD5(string: String) -> String {
    let digest = Insecure.MD5.hash(data: Data(string.utf8))
    
    return digest.map {
        String(format: "%02hhx", $0)
    }.joined()
}

MD5(string: "1b89768d6681ac50fb8a9c470d083935e7f677cdbcbb2452d6645b4338f0e732373eb6647")

getData(urlRequest: "https://gateway.marvel.com:443/v1/public/characters/1011136?ts=1&apikey=cbb2452d6645b4338f0e732373eb6647&hash=dbf085cf11af35cfb528412c9a11d58d")



