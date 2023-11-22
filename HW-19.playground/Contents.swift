import Foundation

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
                print("JSON serialization failed")
            }
        } else {
            if let response = response as? HTTPURLResponse {
                print("Status Code: \(response.statusCode). Failed to fetch data. Verify the URL.")
            }
        }
    }.resume()
}

getData(urlRequest: url)


