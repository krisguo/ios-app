import UIKit

public protocol TradeOffersDateFormatterProtocol {
    func dateToString(_ date: Date) -> String
    func formatDateForXAxis(_ date: Date, type: TradeOffers.Model.Period) -> String
}

extension TradeOffers {
    
    public typealias DateFormatterProtocol = TradeOffersDateFormatterProtocol
}
