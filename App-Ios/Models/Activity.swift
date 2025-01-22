import Foundation
import SwiftUI

struct Activity: Identifiable, Codable {
    var id = UUID()
    var time: Date
    var title: String
    var location: String
    var notes: String
    var category: ActivityCategory
}
