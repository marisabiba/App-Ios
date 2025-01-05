import SwiftUI

struct TripDetailsView: View {
    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) var dismiss
    let trip: Trip
    @State private var showingAddActivity = false
    @State private var selectedDayIndex = 0
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Group {
            if trip.days.isEmpty {
                // Show empty state
                VStack {
                    Text("No days available")
                        .font(.headline)
                    Text("Please try creating the trip again")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                tripContent
            }
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button("Delete") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
                .bold()
            }
        }
        .alert("Delete Trip", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteTrip(id: trip.id)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this trip? This action cannot be undone.")
        }
    }
    
    private var tripContent: some View {
        VStack(spacing: 0) {
            // Day tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(trip.days.indices, id: \.self) { index in
                        DayTab(
                            date: trip.days[index].date,
                            title: trip.days[index].title,
                            isSelected: selectedDayIndex == index
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedDayIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            // Day content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DayHeaderSection(
                        date: trip.days[selectedDayIndex].date,
                        dayTitle: Binding(
                            get: { trip.days[selectedDayIndex].title },
                            set: { newTitle in
                                viewModel.updateDayTitle(tripId: trip.id, dayIndex: selectedDayIndex, newTitle: newTitle)
                            }
                        )
                    )
                    .padding(.horizontal)
                    
                    ActivitiesSection(
                        activities: sortedActivities,
                        onAddActivity: {
                            showingAddActivity = true
                        }
                    )
                    .padding(.horizontal)
                    
                    TransportationSection(
                        transportation: trip.days[selectedDayIndex].transportationDetails,
                        onUpdate: { newTransportation in
                            viewModel.updateTransportation(
                                tripId: trip.id,
                                dayIndex: selectedDayIndex,
                                transportation: newTransportation
                            )
                        }
                    )
                    .padding(.horizontal)
                    
                    BudgetSection(
                        budget: trip.days[selectedDayIndex].budgetDetails,
                        onUpdate: { newBudget in
                            viewModel.updateBudget(
                                tripId: trip.id,
                                dayIndex: selectedDayIndex,
                                budget: newBudget
                            )
                        }
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingAddActivity) {
            AddActivityView(
                viewModel: viewModel,
                trip: trip,
                dayIndex: selectedDayIndex
            )
        }
    }
    
    private var sortedActivities: [Activity] {
        trip.days[selectedDayIndex].activities.sorted { $0.time < $1.time }
    }
}

// Add this new view for the day tabs
struct DayTab: View {
    let date: Date
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.title3.bold())
            
            if !title.isEmpty {
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Preview Provider
struct TripDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TripViewModel()
        let sampleTrip = Trip(
            name: "Sample Trip",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 3),
            days: [
                TripDay(
                    date: Date(),
                    title: "Day 1",
                    activities: [],
                    transportationDetails: TransportationDetails(mode: "Car", time: Date()),
                    budgetDetails: BudgetDetails(amount: 100),
                    checklist: []
                )
            ]
        )
        
        NavigationView {
            TripDetailsView(viewModel: viewModel, trip: sampleTrip)
        }
    }
}
