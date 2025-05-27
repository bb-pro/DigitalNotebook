//
//  CrownNotesAPI.swift
//  DigitalNotebook
//
//  Created by Developer on 24/05/25.
//

import Foundation

struct Note: Codable {
    let id: String
    let mail: String
    let title: String
    let content: String
}

class CrownNotesAPI {
    
    static let shared = CrownNotesAPI()
    private let endpoint = URL(string: "https://crownnotes.shop/back.php")!
    var name: String?
    var email: String?
    var password: String?
    
    private init() {}
    
    private func makeRequest<T: Codable>(body: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let data = data else {
                return completion(.failure(NSError(domain: "No data", code: -1)))
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 1. Registration
    func registerUser(email: String, name: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = [
            "mail": email,
            "name": name,
            "pass": password,
            "metod": "registration"
        ]
        makeRequest(body: body) { (result: Result<[String: String], Error>) in
            completion(result.map { $0["success"] ?? "Unknown response" })
        }
    }
    
    // MARK: - 2. Login
    func login(email: String, password: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        let body = [
            "mail": email,
            "pass": password,
            "metod": "login"
        ]
        makeRequest(body: body) { (result: Result<[String: String], Error>) in
            completion(result.map {
                ($0["success"] ?? "No success message", $0["name"] ?? "Unknown user")
            })
        }
    }
    
    // MARK: - 3. Delete Profile
    func deleteUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = [
            "mail": email,
            "pass": password,
            "metod": "deleteuser"
        ]
        makeRequest(body: body) { (result: Result<[String: String], Error>) in
            completion(result.map { $0["success"] ?? "Unknown response" })
        }
    }
    
    // MARK: - 4. Add Note
    func addNote(email: String, title: String, content: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = [
            "mail": email,
            "title": title,
            "content": content,
            "metod": "addnote"
        ]
        makeRequest(body: body) { (result: Result<[String: String], Error>) in
            completion(result.map { $0["success"] ?? "Unknown response" })
        }
    }
    
    // MARK: - 5. Edit Note
    func editNote(email: String, noteId: String, title: String, content: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = [
            "mail": email,
            "id": noteId,
            "title": title,
            "content": content,
            "metod": "editnote"
        ]
        makeRequest(body: body) { (result: Result<[String: String], Error>) in
            completion(result.map { $0["success"] ?? "Unknown response" })
        }
    }
    
    // MARK: - 6. Delete Note
    func deleteNote(email: String, noteId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let body = [
            "mail": email,
            "id": noteId,
            "metod": "deletenote"
        ]
        makeRequest(body: body) { (result: Result<[String: String], Error>) in
            completion(result.map { $0["success"] ?? "Unknown response" })
        }
    }
    
    // MARK: - 7. Get Notes
    func getNotes(email: String, completion: @escaping (Result<[Note], Error>) -> Void) {
        let body = [
            "mail": email,
            "metod": "getnotes"
        ]
        makeRequest(body: body) { (result: Result<[String: [Note]], Error>) in
            completion(result.map { $0["notes"] ?? [] })
        }
    }
}
