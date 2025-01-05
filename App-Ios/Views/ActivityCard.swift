import SwiftUI

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activity.time, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(activity.title)
                    .font(.headline)
            }
            
            if !activity.location.isEmpty {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.secondary)
                    Text(activity.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if !activity.notes.isEmpty {
                Text(activity.notes)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Preview
struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleActivity = Activity(
            time: Date(),
            title: "Visit Museum",
            location: "City Center Museum",
            notes: "Don't forget to check out the special exhibition on the second floor."
        )
        
        ActivityCard(activity: sampleActivity)
            .padding()
            .previewLayout(.sizeThatFits)
    }
} 