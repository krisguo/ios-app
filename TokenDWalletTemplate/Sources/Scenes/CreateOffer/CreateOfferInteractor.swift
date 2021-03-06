import Foundation
import RxCocoa
import RxSwift
import TokenDSDK

protocol CreateOfferBusinessLogic {
    func onViewDidLoadSync(request: CreateOffer.Event.ViewDidLoadSync.Request)
    func onFieldEditing(request: CreateOffer.Event.FieldEditing.Request)
    func onButtonAction(request: CreateOffer.Event.ButtonAction.Request)
}

extension CreateOffer {
    typealias BusinessLogic = CreateOfferBusinessLogic
    
    class Interactor {
        
        // MARK: - Private properties
        
        private var sceneModel: Model.SceneModel
        private let presenter: PresentationLogic
        private let accountId: String
        private let feeLoader: FeeLoaderProtocol
        private let disposeBag: DisposeBag = DisposeBag()
        
        init(
            presenter: PresentationLogic,
            accountId: String,
            sceneModel: Model.SceneModel,
            feeLoader: FeeLoaderProtocol
            ) {
            
            self.presenter = presenter
            self.sceneModel = sceneModel
            self.accountId = accountId
            self.feeLoader = feeLoader
        }
        
        private enum LoadFeesResult {
            case succeeded(fee: Model.FeeModel)
            case failed(CreateOfferFeeLoaderResult.FeeLoaderError)
        }
        private func loadFee(
            amount: Decimal,
            asset: String,
            completion: @escaping (LoadFeesResult) -> Void
            ) {
            
            self.feeLoader.loadFee(
                accountId: self.accountId,
                asset: asset,
                amount: amount,
                completion: { (result) in
                    switch result {
                        
                    case .succeeded(let fee):
                        completion(.succeeded(fee: fee))
                        
                    case .failed(let error):
                        completion(.failed(error))
                    }
            })
        }
        
        enum HandleActionResult {
            case offer(Model.CreateOfferModel)
            case error(String)
        }
        private func handleAction(
            isBuy: Bool,
            completion: @escaping (HandleActionResult) -> Void
            ) {
            
            guard let amount = self.sceneModel.amount,
                amount > 0,
                let price = self.sceneModel.price,
                price > 0
                else {
                    return
            }
            
            self.loadFee(
                amount: amount * price,
                asset: self.sceneModel.quoteAsset
            ) { [weak self] (result) in
                guard let strongSelf = self else { return }
                
                switch result {
                    
                case .succeeded(let fee):
                    let offer = Model.CreateOfferModel(
                        baseAsset: strongSelf.sceneModel.baseAsset,
                        quoteAsset: strongSelf.sceneModel.quoteAsset,
                        isBuy: isBuy,
                        amount: amount,
                        price: price,
                        fee: fee.percent
                    )
                    completion(.offer(offer))
                    
                case .failed(let errors):
                    completion(.error(errors.localizedDescription))
                }
            }
        }
    }
}

extension CreateOffer.Interactor: CreateOffer.BusinessLogic {
    func onViewDidLoadSync(request: CreateOffer.Event.ViewDidLoadSync.Request) {
        let total = self.totalPrice()
        let price = CreateOffer.Model.Amount(
            value: self.sceneModel.price,
            asset: self.sceneModel.quoteAsset
        )
        let amount = CreateOffer.Model.Amount(
            value: self.sceneModel.amount,
            asset: self.sceneModel.baseAsset
        )
        
        let response = CreateOffer.Event.ViewDidLoadSync.Response(
            price: price,
            amount: amount,
            total: total
        )
        self.presenter.presentViewDidLoadSync(response: response)
    }
    
    func onFieldEditing(request: CreateOffer.Event.FieldEditing.Request) {
        switch request.field.type {
            
        case .price:
            self.sceneModel.price = request.field.value
            
        case .amount:
            self.sceneModel.amount = request.field.value
        }
        
        let total = self.totalPrice()
        let response = CreateOffer.Event.FieldEditing.Response(total: total)
        self.presenter.presentFieldEditing(response: response)
        
        let stateDidChangeResponse = CreateOffer.Event.FieldStateDidChange.Response(
            priceFieldIsFilled: self.checkFieldValue(value: self.sceneModel.price),
            amountFieldIsFilled: self.checkFieldValue(value: self.sceneModel.amount)
        )
        self.presenter.presentFieldStateDidChange(response: stateDidChangeResponse)
    }
    
    func onButtonAction(request: CreateOffer.Event.ButtonAction.Request) {
        let isBuy: Bool = {
            switch request.type {
            case .buy:
                return true
            case .sell:
                return false
            }
        }()
        
        self.handleAction(
            isBuy: isBuy,
            completion: { [weak self] (result) in
                switch result {
                case .offer(let offer):
                    let response = CreateOffer.Event.ButtonAction.Response.offer(offer)
                    self?.presenter.presentButtonAction(response: response)
                case .error(let error):
                    let response = CreateOffer.Event.ButtonAction.Response.error(error)
                    self?.presenter.presentButtonAction(response: response)
                }
        })
    }
}

extension CreateOffer.Interactor {
    private func totalPrice() -> CreateOffer.Model.Amount {
        let total = self.countTotal(
            price: self.sceneModel.price,
            amount: self.sceneModel.amount
        )
        let amount = CreateOffer.Model.Amount(
            value: total,
            asset: self.sceneModel.quoteAsset
        )
        return amount
    }
    
    private func countTotal(price: Decimal?, amount: Decimal?) -> Decimal {
        let result = (price ?? 0) * (amount ?? 0)
        return result
    }
    
    private func checkFieldValue(value: Decimal?) -> Bool {
        return value != nil && value ?? 0 > 0
    }
}
