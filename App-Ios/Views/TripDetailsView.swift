import SwiftUI

struct TripDetailsView: View {
    @ObservedObject var viewModel: TripViewModel
    @State private var selectedTab = 0
    let trip: Trip
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(0..<trip.numberOfDays, id: \.self) { dayIndex in
                DayPlanView(
                    viewModel: viewModel,
                    trip: trip,
                    dayIndex: dayIndex,
                    date: Calendar.current.date(byAdding: .day, value: dayIndex, to: trip.startDate) ?? trip.startDate
                )
                .tabItem {
                    Text("Day \(dayIndex + 1)")
                }
                .tag(dayIndex)
            }
        }
        .navigationTitle("\(trip.name) - Itinerary")
    }
}

struct DayPlanView: View {
    @ObservedObject var viewModel: TripViewModel
    let trip: Trip
    let dayIndex: Int
    let date: Date
    @State private var showingAddActivity = false
    @State private var dayTitle = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Day Header
                DayHeaderSection(date: date, dayTitle: $dayTitle)
                
                // Activities Section
                ActivitiesSection(
                    activities: trip.days[dayIndex].activities,
                    onAddActivity: { showingAddActivity = true }
                )
                
                // Transportation Details
                TransportationSection(transportation: trip.days[dayIndex].transportationDetails)
                
                // Budget Details
                BudgetSection(budget: trip.days[dayIndex].budgetDetails)
                
                // Checklist
                ChecklistSection(checklist: trip.days[dayIndex].checklist)
            }
            .padding()
        }
        .sheet(isPresented: $showingAddActivity) {
            AddActivityView(viewModel: viewModel, trip: trip, dayIndex: dayIndex)
        }
    }
}

// Helper Views
struct DayHeaderSection: View {
    let date: Date
    @Binding var dayTitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(date.formatted(date: .long, time: .omitted))
                .font(.headline)
            TextField("Day Title", text: $dayTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

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

// Add other helper views for Transportation, Budget, and Checklist sections...

struct TripDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TripViewModel()
        let sampleTrip = Trip(name: "Sample Trip", 
                            startDate: Date(), 
                            endDate: Date().addingTimeInterval(86400 * 3))
        
        TripDetailsView(viewModel: viewModel, trip: sampleTrip)
    }
}
