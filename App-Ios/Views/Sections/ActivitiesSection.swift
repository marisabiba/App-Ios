import SwiftUI

struct ActivitiesSection: View {
    let activities: [Activity]
    let onAddActivity: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Activities (\(activities.count))")
                .font(.headline)
            
            ForEach(activities) { activity in
                ActivityCard(activity: activity)
            }
            
            Button(action: onAddActivity) {
                Label("Add Activity", systemImage: "plus.circle.fill")
            }
        }
    }
} 