//
//  NetworkService.swift
//  8BallDelegator
//
//  Created by Veronika Andrianova on 18.10.2021.
//

import Foundation

class NetworkService: NetworkDataProvider {
    private let BASEURL = "https://8ball.delegator.com"
    private var commonFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
        return dateFormatter
    }()

    func getAnswer(
        question: String,
        completion: @escaping (Result<MagicJsonResponse<Magic>?, CallError>) -> Void) {
            var urlString = BASEURL + "/magic/JSON/\(question)"
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            self.requestGet(urlString: urlString, completion: completion)
        }

    private func requestGet<T: Decodable>(
        urlString: String,
        completion: @escaping (Result<MagicJsonResponse<T>?, CallError>) -> Void) {
            guard let url = URL(string: urlString) else { return }
            var urlRequest = URLRequest(url: url)
            let requestHeaders: [String: String] = [
                "Content-Type": "application/json; charset=utf-8" ]
            urlRequest.httpMethod = "GET"
            urlRequest.allHTTPHeaderFields = requestHeaders
            let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        if let error = error as NSError?,
                           error.domain == NSURLErrorDomain &&
                            error.code == NSURLErrorNotConnectedToInternet {
                            completion(.failure(
                                .networkError("Please check your internet connection or try again later")))
                        } else {
                            completion(.failure(.unknownError(error)))
                        }
                    }
                    guard let data = data else {
                        completion(.failure(.unknownWithoutError))
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 200..<300:
                            self?.decodeJson(type: MagicJsonResponse<T>.self, from: data) { (result) in
                                switch result {
                                case .success(let decode):
                                    guard let decode = decode else {return}
                                    completion(.success(decode))
                                case .failure(let error):
                                    completion(.failure(error))
                                    print(error)
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
            task.resume()
        }

    private func decodeJson<T: Decodable>(type: T.Type, from: Data?, completion: (Result<T?, CallError>) -> Void) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            guard let date = self.commonFormatter.date(from: dateStr) else { throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateStr)") }
            return date
        })
        guard let data = from else { return }
        do {
            let object = try decoder.decode(type.self, from: data)
            completion(.success(object))
        } catch let jsonError {
            completion(.failure(.jsonError(jsonError)))
        }
    }
}

// MARK: - NetworkDataProvider
protocol NetworkDataProvider {
    func getAnswer(
        question: String,
        completion: @escaping (Result<MagicJsonResponse<Magic>?, CallError>) -> Void)
}

enum CallError: Error {
    case networkError(String)
    case jsonError(Error)
    case unknownError(Error)
    case unknownWithoutError
}

struct MagicJsonResponse<T: Decodable>: Decodable {
    public var magic: T?
}

struct Magic: Codable {
    var question: String?
    var answer: String?
    var type: String?
}

extension Magic {
    func toManagedAnswer() -> ManagedAnswer {
        return ManagedAnswer(question: question, answer: answer, type: type)
    }
}
