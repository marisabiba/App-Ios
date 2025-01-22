import SwiftUI

struct TripDetailsView: View {
    @ObservedObject var viewModel: TripViewModel
    @State private var selectedTab = 0
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @Environment(\.dismiss) var dismiss
    let trip: Trip
    @State private var dayIndex: Int = 0
    
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
                        budget: trip.days[dayIndex].budgetDetails,
                        trip: trip,
                        viewModel: viewModel,
                        dayIndex: dayIndex,
                        onUpdate: { newBudget in
                            viewModel.updateBudget(
                                tripId: trip.id,
                                dayIndex: dayIndex,
                                budget: newBudget
                            )
                        }
                    )
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
        }
    }
}

struct BudgetSection: View {
    let budget: BudgetDetails
    let trip: Trip
    let viewModel: TripViewModel
    let dayIndex: Int
    let onUpdate: (BudgetDetails) -> Void
    @State private var showingAddExpense = false
    @State private var totalBudget: String
    @State private var expandedCategory: BudgetCategory? 

    init(budget: BudgetDetails, trip: Trip, viewModel: TripViewModel, dayIndex: Int, onUpdate: @escaping (BudgetDetails) -> Void) {
        self.budget = budget
        self.trip = trip
        self.viewModel = viewModel
        self.dayIndex = dayIndex
        self.onUpdate = onUpdate
        _totalBudget = State(initialValue: String(format: "%.2f", budget.totalBudget))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Total Budget Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Total Budget")
                    .font(.headline)
                    .padding(.bottom, 4)

                HStack(spacing: 8) {
                    // Currency Symbol
                    Text(CurrencyService.getCurrencySymbol(for: budget.currency))
                        .font(.title3)
                        .padding(.vertical, 8)
                        .frame(width: 40, alignment: .center)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    // Text Field
                    TextField("Enter amount", text: $totalBudget)
                        .keyboardType(.decimalPad)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue.opacity(0.7), lineWidth: 1)
                        )
                        .onChange(of: totalBudget) { newValue in
                            if let newAmount = Double(newValue) {
                                var updatedBudget = budget
                                updatedBudget.totalBudget = newAmount
                                onUpdate(updatedBudget)
                            }
                        }
                }
                .frame(maxWidth: .infinity)

                let remainingBudget = budget.totalBudget - budget.expenses.reduce(0) { $0 + ($1.convertedAmount ?? $1.amount) }
                let progress = remainingBudget / budget.totalBudget

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.top)
                Text("\(remainingBudget, format: .currency(code: budget.currency)) remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)

            }
            .padding()

            // Budget Overview
            VStack(spacing: 12) {
                HStack {
                    Text("Remaining")
                        .fontWeight(.medium)
                    Spacer()
                    AnimatedNumberView(
                        value: budget.totalBudget - budget.expenses.reduce(0) { total, expense in
                            total + (expense.convertedAmount ?? expense.amount)
                        },
                        currency: budget.currency
                    )
                }

                Divider()

                // Expenses by Category
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(BudgetCategory.allCases, id: \.self) { category in
                            // Calculate total amount for the category
                            let categoryTotal = budget.expenses
                                .filter { $0.category == category }
                                .reduce(0) { total, expense in
                                    total + (expense.convertedAmount ?? expense.amount)
                                }

                            if categoryTotal > 0 {
                                VStack {
                                    // Category Header with dropdown toggle
                                    HStack {
                                        Image(systemName: category.icon)
                                            .foregroundColor(category.color)
                                            .frame(width: 24, height: 24)
                                        Text(category.rawValue)
                                        Spacer()
                                        AnimatedNumberView(
                                            value: categoryTotal,
                                            currency: budget.currency,
                                            duration: 0.3
                                        )
                                        Button(action: {
                                            // Toggle the expanded state for this category
                                            if expandedCategory == category {
                                                expandedCategory = nil
                                            } else {
                                                expandedCategory = category
                                            }
                                        }) {
                                            Image(systemName: expandedCategory == category ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.horizontal)

                                    // Show details when the category is expanded
                                    if expandedCategory == category {
                                        VStack(spacing: 8) {
                                            ForEach(budget.expenses.filter { $0.category == category }) { expense in
                                                HStack {
                                                    Text(expense.note)
                                                        .font(.body)
                                                    Spacer()
                                                    VStack(alignment: .trailing) {
                                                        if let converted = expense.convertedAmount,
                                                           expense.currency != trip.localCurrency {
                                                            Text("\(converted, format: .currency(code: trip.localCurrency))")
                                                            Text("\(expense.amount, format: .currency(code: expense.currency))")
                                                                .font(.caption)
                                                                .foregroundColor(.secondary)
                                                        } else {
                                                            Text("\(expense.amount, format: .currency(code: expense.currency))")
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal)
                                                .transition(.opacity.combined(with: .slide))
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
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
            AddExpenseView(
                viewModel: viewModel,
                trip: trip,
                dayIndex: dayIndex,
                budget: budget,
                onUpdate: onUpdate
            )
        }
        .animation(.spring(response: 0.3), value: budget.expenses)
        .animation(.spring(response: 0.3), value: budget.totalBudget)
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

// New view for displaying category expenses
struct CategoryExpensesView: View {
    @Environment(\.dismiss) var dismiss
    let category: BudgetCategory
    let expenses: [BudgetExpense]
    let currency: String
    let trip: Trip
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expenses) { expense in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(expense.note)
                                .font(.headline)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(expense.amount, format: .currency(code: expense.currency))")
                                if let converted = expense.convertedAmount,
                                   expense.currency != trip.localCurrency {
                                    Text("\(converted, format: .currency(code: trip.localCurrency))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Text(expense.date?.formatted(date: .abbreviated, time: .shortened) ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("\(category.rawValue) Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TripDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TripViewModel()
        let sampleTrip = Trip(
            name: "Sample Trip",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            days: [],
            localCurrency: "EUR"
        )
        TripDetailsView(viewModel: viewModel, trip: sampleTrip)
    }
}
