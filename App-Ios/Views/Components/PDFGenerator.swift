import SwiftUI
import PDFKit

struct PDFGenerator {
    static func generatePDF(for trip: Trip) -> URL? {
        let pdfDocument = PDFDocument()
        
        // Iterate over each day of the trip
        for (dayIndex, day) in trip.days.enumerated() {
            let pageData = createPDFPage(for: day, dayIndex: dayIndex + 1, tripName: trip.name, trip: trip)
            
            // Create a PDFDocument from the data
            if let pageDocument = PDFDocument(data: pageData) {
                if let page = pageDocument.page(at: 0) {
                    pdfDocument.insert(page, at: pdfDocument.pageCount)
                }
            }
        }
        
        // Save the PDF to a temporary file
        let fileName = "\(trip.name)_Itinerary.pdf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        guard pdfDocument.write(to: fileURL) else {
            print("Failed to write PDF document.")
            return nil
        }
        
        return fileURL
    }
    
    private static func createPDFPage(for day: TripDay, dayIndex: Int, tripName: String, trip: Trip) -> Data {
        // Page dimensions
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let context = context.cgContext
            
            // Title: Trip Name and Day
            let title = "\(tripName) - Day \(dayIndex)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.black
            ]
            title.draw(at: CGPoint(x: 20, y: 20), withAttributes: titleAttributes)
            
            // Activities Section
            let activityTitle = "Activities:"
            let activityTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ]
            activityTitle.draw(at: CGPoint(x: 20, y: 60), withAttributes: activityTitleAttributes)
            
            var yOffset = 90
            for activity in day.activities {
                let activityText = "\(activity.time.formatted(date: .omitted, time: .shortened)) - \(activity.title) at \(activity.location)"
                let activityAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.darkGray
                ]
                activityText.draw(at: CGPoint(x: 20, y: CGFloat(yOffset)), withAttributes: activityAttributes)
                yOffset += 25
            }
            
            // Budget Section
            let budgetTitle = "Budget for the Day:"
            let budgetTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ]
            budgetTitle.draw(at: CGPoint(x: 20, y: CGFloat(yOffset) + 10), withAttributes: budgetTitleAttributes)
            
            yOffset += 35
            let budgetText = "Total Budget: \(day.budgetDetails.totalBudget) \(trip.localCurrency)"
            let budgetAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            budgetText.draw(at: CGPoint(x: 20, y: CGFloat(yOffset)), withAttributes: budgetAttributes)
            yOffset += 25
            
            let remainingBudgetText = "Remaining Budget: \(day.budgetDetails.remainingBudget) \(trip.localCurrency)"
            remainingBudgetText.draw(at: CGPoint(x: 20, y: CGFloat(yOffset)), withAttributes: budgetAttributes)
            
            yOffset += 25
            
            if !day.budgetDetails.expenses.isEmpty {
                let expensesTitle = "Expenses:"
                expensesTitle.draw(at: CGPoint(x: 20, y: CGFloat(yOffset)), withAttributes: budgetTitleAttributes)
                yOffset += 25
                
                for expense in day.budgetDetails.expenses {
                    let expenseText = "\(expense.category.rawValue): \(expense.amount) \(expense.currency) - \(expense.note)"
                    expenseText.draw(at: CGPoint(x: 20, y: CGFloat(yOffset)), withAttributes: budgetAttributes)
                    yOffset += 25
                }
            }
        }
        
        return data
    }
}
