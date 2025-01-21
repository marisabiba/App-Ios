import Foundation
import SwiftUI

final class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = [] {
        didSet {
            saveTrips()
        }
    }

    private let tripsKey = "savedTrips"

    init() {
        loadTrips()
    }

    func addTrip(_ trip: Trip) {
        var newTrip = trip
        let calendar = Calendar.current
        
        // Calculate days including both start and end dates
        let numberOfDays = calendar.dateComponents([.day], from: calendar.startOfDay(for: trip.startDate), 
                                                 to: calendar.startOfDay(for: trip.endDate)).day ?? 0
        let totalDays = numberOfDays + 1
        
        var days: [TripDay] = []
        for dayIndex in 0..<totalDays {
            if let date = calendar.date(byAdding: .day, value: dayIndex, to: calendar.startOfDay(for: trip.startDate)) {
                let day = TripDay(
                    date: date,
                    title: formatDayTitle(date),
                    activities: [],
                    transportationDetails: TransportationDetails(mode: "", time: date),
                    budgetDetails: BudgetDetails(totalBudget: 0, expenses: [], currency: trip.localCurrency),
                    checklist: []
                )
                days.append(day)
            }
        }
        
        newTrip.days = days
        trips.append(newTrip)
    }

    func addActivity(to trip: Trip, dayIndex: Int, activity: Activity) {
        guard let tripIndex = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[tripIndex].days[dayIndex].activities.append(activity)
    }

    private func saveTrips() {
        if let data = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(data, forKey: tripsKey)
        }
    }

    private func loadTrips() {
        if let data = UserDefaults.standard.data(forKey: tripsKey),
           let savedTrips = try? JSONDecoder().decode([Trip].self, from: data) {
            trips = savedTrips
        }
    }

    func updateTrip(id: UUID, name: String, startDate: Date, endDate: Date) {
        if let index = trips.firstIndex(where: { $0.id == id }) {
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: startDate)
            let end = calendar.startOfDay(for: endDate)
            
            // Calculate days between start and end dates (inclusive)
            let numberOfDays = calendar.dateComponents([.day], from: start, to: end).day ?? 0
            let totalDays = numberOfDays + 1  // Add 1 to include both start and end dates
            
            // Create array to hold all days
            var days: [TripDay] = []
            
            // Create a day for each date in the range
            for dayOffset in 0..<totalDays {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: start) {
                    // If there's an existing day at this index, preserve its data
                    if dayOffset < trips[index].days.count {
                        var existingDay = trips[index].days[dayOffset]
                        existingDay.date = date
                        days.append(existingDay)
                    } else {
                        // Create new day with default values
                        let newDay = TripDay(
                            date: date,
                            title: formatDayTitle(date),
                            activities: [],
                            transportationDetails: TransportationDetails(mode: "", time: date),
                            budgetDetails: BudgetDetails(totalBudget: 0, expenses: [], currency: trips[index].localCurrency),
                            checklist: []
                        )
                        days.append(newDay)
                    }
                }
            }
            
            // Update the trip with new information
            var updatedTrip = trips[index]
            updatedTrip.name = name
            updatedTrip.startDate = startDate
            updatedTrip.endDate = endDate
            updatedTrip.days = days
            
            trips[index] = updatedTrip
        }
    }

    // Helper function to format the day title
    private func formatDayTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }

    func deleteTrip(id: UUID) {
        trips.removeAll { $0.id == id }
    }

    func updateDayTitle(tripId: UUID, dayIndex: Int, newTitle: String) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].days[dayIndex].title = newTitle
        }
    }

    func updateTransportation(tripId: UUID, dayIndex: Int, transportation: TransportationDetails) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].days[dayIndex].transportationDetails = transportation
        }
    }

    func updateBudget(tripId: UUID, dayIndex: Int, budget: BudgetDetails) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].days[dayIndex].budgetDetails = budget
        }
    }

    func updateExpenseWithConversion(_ expense: BudgetExpense, tripId: UUID, dayIndex: Int) async {
        // If the currencies are the same, no conversion needed
        guard let tripIndex = trips.firstIndex(where: { $0.id == tripId }),
              expense.currency != trips[tripIndex].days[dayIndex].budgetDetails.currency else {
            return
        }
        
        do {
            let currencyService = CurrencyService()
            let convertedAmount = try await currencyService.convertCurrency(
                amount: expense.amount,
                from: expense.currency,
                to: trips[tripIndex].days[dayIndex].budgetDetails.currency
            )
            
            // Update the expense with the converted amount
            DispatchQueue.main.async {
                var updatedTrip = self.trips[tripIndex]
                var updatedExpense = expense
                updatedExpense.amount = convertedAmount
                updatedExpense.currency = updatedTrip.days[dayIndex].budgetDetails.currency
                updatedTrip.days[dayIndex].budgetDetails.expenses.append(updatedExpense)
                self.trips[tripIndex] = updatedTrip
            }
        } catch {
            print("Currency conversion failed: \(error)")
        }
    }
    
    func getTotalBudgetInLocalCurrency(for trip: Trip) async -> Double {
        var total = 0.0
        
        for day in trip.days {
            for expense in day.budgetDetails.expenses {
                if expense.currency == trip.localCurrency {
                    total += expense.amount
                } else if let convertedAmount = expense.convertedAmount {
                    total += convertedAmount
                }
            }
        }
        
        return total
    }
}
