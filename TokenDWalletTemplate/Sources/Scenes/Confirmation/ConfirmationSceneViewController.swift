import UIKit
import RxSwift
import RxCocoa

protocol ConfirmationSceneDisplayLogic: class {
    func displayViewDidLoad(viewModel: ConfirmationScene.Event.ViewDidLoad.ViewModel)
    func displaySectionsUpdated(viewModel: ConfirmationScene.Event.SectionsUpdated.ViewModel)
    func displayConfirmAction(viewModel: ConfirmationScene.Event.ConfirmAction.ViewModel)
}

extension ConfirmationScene {
    typealias DisplayLogic = ConfirmationSceneDisplayLogic
    
    class ViewController: UIViewController {
        
        // MARK: - Private properties
        
        private let stackView: ScrollableStackView = ScrollableStackView()
        
        private var sections: [Model.SectionViewModel] = []
        
        private let disposeBag = DisposeBag()
        
        // MARK: - Injections
        
        private var interactorDispatch: InteractorDispatch?
        private var routing: Routing?
        
        func inject(interactorDispatch: InteractorDispatch?, routing: Routing?) {
            self.interactorDispatch = interactorDispatch
            self.routing = routing
        }
        
        // MARK: - Overridden
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.setupView()
            self.setupStackView()
            self.setupConfirmActionButton()
            self.setupLayout()
            
            let request = ConfirmationScene.Event.ViewDidLoad.Request()
            self.interactorDispatch?.sendRequest { businessLogic in
                businessLogic.onViewDidLoad(request: request)
            }
        }
        
        // MARK: - Private
        
        private func updateWith(sectionViewModels: [Model.SectionViewModel]) {
            var views: [UIView] = []
            
            for sectionViewModel in sectionViewModels {
                for cell in sectionViewModel.cells {
                    switch cell {
                        
                    case let viewModel as View.TitleTextViewModel:
                        let view = self.getTitleTextView(viewModel: viewModel)
                        views.append(view)
                        
                    case let viewModel as View.TitleTextEditViewModel:
                        let view = self.getTitleTextEditView(viewModel: viewModel)
                        views.append(view)
                        
                    case let viewModel as View.TitleBoolSwitchViewModel:
                        let view = self.getTitleBoolSwitchView(viewModel: viewModel)
                        views.append(view)
                        
                    default:
                        break
                    }
                }
            }
            
            self.stackView.set(views: views, transition: .none)
        }
        
        private func getTitleTextView(viewModel: View.TitleTextViewModel) -> View.TitleTextView {
            let view = View.TitleTextView()
            view.model = viewModel
            return view
        }
        
        private func getTitleTextEditView(viewModel: View.TitleTextEditViewModel) -> View.TitleTextEditView {
            let view = View.TitleTextEditView()
            view.model = viewModel
            view.onEdit = { [weak self] (identifier, value) in
                let request = Event.TextFieldEdit.Request(
                    identifier: identifier,
                    text: value
                )
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    businessLogic.onTextFieldEdit(request: request)
                })
            }
            return view
        }
        
        private func getTitleBoolSwitchView(viewModel: View.TitleBoolSwitchViewModel) -> View.TitleBoolSwitchView {
            let view = View.TitleBoolSwitchView()
            view.model = viewModel
            view.onSwitch = { [weak self] (identifier, value) in
                let request = Event.BoolSwitch.Request(
                    identifier: identifier,
                    value: value
                )
                self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                    businessLogic.onBoolSwitch(request: request)
                })
            }
            return view
        }
        
        // MARK: - Setup
        
        private func setupView() {
            
        }
        
        private func setupStackView() {
            
        }
        
        private func setupConfirmActionButton() {
            let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Checkmark"), style: .plain, target: nil, action: nil)
            button.rx
                .tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.view.endEditing(true)
                    let request = Event.ConfirmAction.Request()
                    self?.interactorDispatch?.sendRequest(requestBlock: { (businessLogic) in
                        businessLogic.onConfirmAction(request: request)
                    })
                })
                .disposed(by: self.disposeBag)
            self.navigationItem.rightBarButtonItem = button
        }
        
        private func setupLayout() {
            self.view.addSubview(self.stackView)
            
            self.stackView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension ConfirmationScene.ViewController: ConfirmationScene.DisplayLogic {
    func displayViewDidLoad(viewModel: ConfirmationScene.Event.ViewDidLoad.ViewModel) {
        
    }
    
    func displaySectionsUpdated(viewModel: ConfirmationScene.Event.SectionsUpdated.ViewModel) {
        self.updateWith(sectionViewModels: viewModel.sectionViewModels)
    }
    
    func displayConfirmAction(viewModel: ConfirmationScene.Event.ConfirmAction.ViewModel) {
        switch viewModel {
        
        case .loading:
            self.routing?.onShowProgress()
            
        case .loaded:
            self.routing?.onHideProgress()
            
        case .failed(let errorMessage):
            self.routing?.onShowError(errorMessage)
            
        case .succeeded:
            self.routing?.onConfirmationSucceeded()
        }
    }
}
