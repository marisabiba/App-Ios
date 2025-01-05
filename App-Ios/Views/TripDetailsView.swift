import SwiftUI

struct TripDetailsView: View {
    @ObservedObject var viewModel: TripViewModel
    @State private var selectedTab = 0
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @Environment(\.dismiss) var dismiss
    let trip: Trip
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal day selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<trip.numberOfDays, id: \.self) { dayIndex in
                        DayTab(
                            dayNumber: dayIndex + 1,
                            date: Calendar.current.date(byAdding: .day, value: dayIndex, to: trip.startDate) ?? trip.startDate,
                            isSelected: selectedTab == dayIndex,
                            title: dayIndex < trip.days.count ? trip.days[dayIndex].title : "Day \(dayIndex + 1)"
                        )
                        .onTapGesture {
                            selectedTab = dayIndex
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Day content
            TabView(selection: $selectedTab) {
                ForEach(0..<min(trip.numberOfDays, trip.days.count), id: \.self) { dayIndex in
                    DayPlanView(
                        viewModel: viewModel,
                        trip: trip,
                        dayIndex: dayIndex,
                        date: Calendar.current.date(byAdding: .day, value: dayIndex, to: trip.startDate) ?? trip.startDate
                    )
                    .tag(dayIndex)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("\(trip.name) - Itinerary")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .none) {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Trip", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Trip", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.blue)
                }
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
        .sheet(isPresented: $showingEditSheet) {
            EditTripView(viewModel: viewModel, trip: trip)
        }
    }
}

// New component for day tabs
struct DayTab: View {
    let dayNumber: Int
    let date: Date
    let isSelected: Bool
    let title: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
            Text(date.formatted(.dateTime.day().month()))
                .font(.caption)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.blue : Color.clear)
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(8)
    }
}

struct DayPlanView: View {
    @ObservedObject var viewModel: TripViewModel
    let trip: Trip
    let dayIndex: Int
    let date: Date
    @State private var showingAddActivity = false
    @State private var dayTitle: String
    
    init(viewModel: TripViewModel, trip: Trip, dayIndex: Int, date: Date) {
        self.viewModel = viewModel
        self.trip = trip
        self.dayIndex = dayIndex
        self.date = date
        
        // Safely initialize the day title
        if dayIndex < trip.days.count {
            self._dayTitle = State(initialValue: trip.days[dayIndex].title)
        } else {
            // Fallback to formatted date if the day doesn't exist yet
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            self._dayTitle = State(initialValue: formatter.string(from: date))
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Day Header
                DayHeaderSection(
                    date: date,
                    dayTitle: $dayTitle,
                    onTitleChanged: { newTitle in
                        if dayIndex < trip.days.count {
                            viewModel.updateDayTitle(tripId: trip.id, dayIndex: dayIndex, newTitle: newTitle)
                        }
                    }
                )
                
                // Only show these sections if we have valid day data
                if dayIndex < trip.days.count {
                    // Activities Section
                    ActivitiesSection(
                        activities: trip.days[dayIndex].activities,
                        onAddActivity: { showingAddActivity = true }
                    )
                    
                    // Transportation Details
                    TransportationSection(
                        transportation: trip.days[dayIndex].transportationDetails
                    ) { newTransportation in
                        viewModel.updateTransportation(
                            tripId: trip.id,
                            dayIndex: dayIndex,
                            transportation: newTransportation
                        )
                    }
                    
                    // Budget Details
                    BudgetSection(
                        budget: trip.days[dayIndex].budgetDetails
                    ) { newBudget in
                        viewModel.updateBudget(
                            tripId: trip.id,
                            dayIndex: dayIndex,
                            budget: newBudget
                        )
                    }
                }
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
    let onTitleChanged: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(date.formatted(date: .long, time: .omitted))
                .font(.headline)
            TextField("Day Title", text: $dayTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: dayTitle) { newValue in
                    onTitleChanged(newValue)
                }
        }
    }
}

struct ActivitiesSection: View {
    let activities: [Activity]
    let onAddActivity: () -> Void
    
    var sortedActivities: [Activity] {
        activities.sorted { $0.time < $1.time }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Activities (\(activities.count))")
                .font(.headline)
            
            ForEach(sortedActivities) { activity in
                ActivityCard(activity: activity)
            }
            
            Button(action: onAddActivity) {
                Label("Add Activity", systemImage: "plus.circle.fill")
            }
        }
    }
}

struct TransportationSection: View {
    let transportation: TransportationDetails
    let onUpdate: (TransportationDetails) -> Void
    @State private var mode: String
    @State private var time: Date
    
    init(transportation: TransportationDetails, onUpdate: @escaping (TransportationDetails) -> Void) {
        self.transportation = transportation
        self.onUpdate = onUpdate
        _mode = State(initialValue: transportation.mode)
        _time = State(initialValue: transportation.time)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transportation")
                .font(.headline)
            
            TextField("Mode of transport", text: $mode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: mode) { newValue in
                    onUpdate(TransportationDetails(mode: newValue, time: time))
                }
            
            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                .onChange(of: time) { newValue in
                    onUpdate(TransportationDetails(mode: mode, time: newValue))
                }
        }
    }
}

struct BudgetSection: View {
    let budget: BudgetDetails
    let onUpdate: (BudgetDetails) -> Void
    @State private var amount: String
    
    init(budget: BudgetDetails, onUpdate: @escaping (BudgetDetails) -> Void) {
        self.budget = budget
        self.onUpdate = onUpdate
        _amount = State(initialValue: String(format: "%.2f", budget.amount))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Budget")
                .font(.headline)
            
            HStack {
                Text("$")
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: amount) { newValue in
                        if let newAmount = Double(newValue) {
                            onUpdate(BudgetDetails(amount: newAmount))
                        }
                    }
            }
        }
    }
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(activity.title)
                .font(.headline)
            Text(activity.location)
                .font(.subheadline)
            if !activity.notes.isEmpty {
                Text(activity.notes)
                    .font(.caption)
            }
            Text(activity.time.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ChecklistSection: View {
    let checklist: [ChecklistItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Checklist")
                .font(.headline)
            ForEach(checklist) { item in
                HStack {
                    Image(systemName: item.isCompleted ? "checkmark.square" : "square")
                    Text(item.title)
                }
            }
        }
    }
}
