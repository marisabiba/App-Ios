import Foundation

struct Place: Identifiable, Codable {
    let id: String
    let name: String
    let fullName: String
    let photoReference: String?
} 