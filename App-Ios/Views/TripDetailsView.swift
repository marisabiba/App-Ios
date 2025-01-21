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
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Add Activity")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
        }
        .padding(.top)
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Transportation")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 4) {
                Button(action: {
                    mode = "Bus"
                    onUpdate(TransportationDetails(mode: "Bus", time: time))
                }) {
                    HStack {
                        Image(systemName: "bus")
                            .foregroundColor(.black)
                        Text("Bus")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
.background(mode == "Bus" ? Color(.secondarySystemBackground) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
                
                Button(action: {
                    mode = "Metro"
                    onUpdate(TransportationDetails(mode: "Metro", time: time))
                }) {
                    HStack {
                        Image(systemName: "tram")
                            .foregroundColor(.black)
                        Text("Metro")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
.background(mode == "Metro" ? Color(.secondarySystemBackground) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
                
                Button(action: {
                    mode = "Walk"
                    onUpdate(TransportationDetails(mode: "Walk", time: time))
                }) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.black)
                        Text("Walk")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
.background(mode == "Walk" ? Color(.secondarySystemBackground) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                .onChange(of: time) { newValue in
                    onUpdate(TransportationDetails(mode: mode, time: newValue))
                }
                .padding(.horizontal)
        }
    }
}

struct BudgetSection: View {
    let budget: BudgetDetails
    let onUpdate: (BudgetDetails) -> Void
    @State private var showingAddExpense = false
    @State private var totalBudget: String
    
    init(budget: BudgetDetails, onUpdate: @escaping (BudgetDetails) -> Void) {
        self.budget = budget
        self.onUpdate = onUpdate
        _totalBudget = State(initialValue: String(format: "%.2f", budget.totalBudget))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Total Budget Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Budget")
                    .font(.headline)
                
                HStack {
                    Text("$")
                    TextField("Total Budget", text: $totalBudget)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: totalBudget) { newValue in
                            if let newAmount = Double(newValue) {
                                var updatedBudget = budget
                                updatedBudget.totalBudget = newAmount
                                onUpdate(updatedBudget)
                            }
                        }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Budget Overview
            VStack(spacing: 12) {
                HStack {
                    Text("Remaining")
                        .fontWeight(.medium)
                    Spacer()
                    Text("$\(String(format: "%.2f", budget.remainingBudget))")
                        .foregroundColor(budget.remainingBudget >= 0 ? .green : .red)
                        .fontWeight(.bold)
                }
                
                Divider()
                
                // Expenses by Category
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(BudgetCategory.allCases, id: \.self) { category in
                            let amount = budget.expenses
                                .filter { $0.category == category }
                                .reduce(0) { $0 + $1.amount }
                            
                            if amount > 0 {
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(category.color)
                                        .frame(width: 24, height: 24)
                                    Text(category.rawValue)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", amount))")
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
            
            // Add Expense Button
            Button(action: { showingAddExpense = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Expense")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(budget: budget, onUpdate: onUpdate)
        }
    }
}

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    let budget: BudgetDetails
    let onUpdate: (BudgetDetails) -> Void
    
    @State private var selectedCategory: BudgetCategory = .other
    @State private var amount = ""
    @State private var note = ""
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(BudgetCategory.allCases, id: \.self) { category in
                                Label(
                                    title: { Text(category.rawValue) },
                                    icon: { Image(systemName: category.icon) }
                                )
                                .foregroundColor(category.color)
                                .tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        HStack {
                            Text("$")
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                                .focused($isAmountFocused)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            isAmountFocused = false
                                        }
                                    }
                                }
                        }
                        
                        TextField("Note", text: $note)
                            .textFieldStyle(.roundedBorder)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let amountValue = Double(amount), amountValue > 0 {
                            var updatedBudget = budget
                            let newExpense = BudgetExpense(
                                category: selectedCategory,
                                amount: amountValue,
                                note: note
                            )
                            updatedBudget.expenses.append(newExpense)
                            onUpdate(updatedBudget)
                            dismiss()
                        }
                    }
                    .disabled(Double(amount) == nil || amount.isEmpty)
                }
            }
        }
    }
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: activity.category.icon)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(activity.category.color)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(activity.title)
                    .font(.headline)
                Text(activity.time, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
        .cornerRadius(10)
        .padding(.vertical, 4)
    }
}

struct ChecklistSection: View {
    let checklist: [ChecklistItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Checklist")
                .font(.title2)
                .fontWeight(.bold)
            ForEach(checklist) { item in
                HStack {
                    Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                    Text(item.title)
                        .font(.body)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
        )
    }
}
