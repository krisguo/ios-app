import UIKit
import RxSwift
import Nuke

extension Sales {
    
    enum SaleListCell {
        
        struct ViewModel: CellViewModel {
            
            let imageUrl: URL?
            let name: String
            let description: String
            
            let investedAmountText: String
            let investedPercentage: Float
            let investedPercentageText: String
            let investorsText: String
            
            let isUpcomming: Bool
            let timeText: String
            
            let saleIdentifier: String
            
            func setup(cell: View) {
                cell.imageURL = self.imageUrl
                cell.saleName = self.name
                cell.saleDescription = self.description
                
                cell.investedAmountText = self.investedAmountText
                cell.investedPercentageText = self.investedPercentageText
                cell.investedPercent = self.investedPercentage
                cell.investorsAmountText = self.investorsText
                
                cell.isUpcoming = self.isUpcomming
                cell.timeText = self.timeText
                
                cell.identifier = self.saleIdentifier
            }
        }
        
        class View: UITableViewCell {
            
            // MARK: - Public property
            
            public var imageURL: URL? {
                didSet {
                    if let imageURL = self.imageURL {
                        Nuke.loadImage(
                            with: imageURL,
                            into: self.saleImageView
                        )
                    } else {
                        self.saleImageView.image = nil
                    }
                }
            }
            
            public var isUpcoming: Bool = false {
                didSet {
                    if self.isUpcoming {
                        self.upcomingImageView.image = #imageLiteral(resourceName: "Upcoming image")
                    } else {
                        self.upcomingImageView.image = nil
                    }
                }
            }
            
            public var saleName: String? {
                get { return self.nameLabel.text }
                set { self.nameLabel.text = newValue }
            }
            
            public var saleDescription: String? {
                get { return self.shortDescriptionLabel.text }
                set { self.shortDescriptionLabel.text = newValue }
            }
            
            public var investedAmountText: String? {
                get { return self.investedAmountLabel.text }
                set { self.investedAmountLabel.text = newValue }
            }
            
            public var investedPercent: Float {
                get { return self.progressView.progress }
                set { self.progressView.progress = newValue }
            }
            
            public var investedPercentageText: String? {
                get { return self.percentLabel.text }
                set { self.percentLabel.text = newValue }
            }
            
            public var investorsAmountText: String? {
                get { return self.investorsAmountLabel.text }
                set { self.investorsAmountLabel.text = newValue }
            }
            
            public var timeText: String? {
                get { return self.timeLabel.text }
                set { self.timeLabel.text = newValue }
            }
            
            public var identifier: Sales.CellIdentifier = ""
            
            // MARK: - Private properties
            
            private let saleImageView: UIImageView = UIImageView()
            private let upcomingImageView: UIImageView = UIImageView()
            private let nameLabel: UILabel = UILabel()
            private let shortDescriptionLabel: UILabel = UILabel()
            private let investContenView: UIView = UIView()
            
            private var saleImageDisposable: Disposable?
            
            // Invested views
            
            private let investedAmountLabel: UILabel = UILabel()
            private let percentLabel: UILabel = UILabel()
            private let progressView: UIProgressView = UIProgressView()
            private let investorsAmountLabel: UILabel = UILabel()
            private let timeLabel: UILabel = UILabel()
            
            private let sideInset: CGFloat = 20
            private let topInset: CGFloat = 15
            private let bottomInset: CGFloat = 15
            
            // MARK: -
            
            override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                
                self.commonInit()
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            deinit {
                self.saleImageDisposable?.dispose()
            }
            
            // MARK: - Private
            
            private func commonInit() {
                self.setupView()
                self.setupSaleImageView()
                self.setupNameLabel()
                self.setupShortDescriptionLabel()
                self.setupInvestedAmountLabel()
                self.setupPercentLabel()
                self.setupProgressView()
                self.setupInvestorsAmountLabel()
                self.setupTimeLabel()
                
                self.setupLayout()
            }
            
            private func setupView() {
                self.backgroundColor = Theme.Colors.contentBackgroundColor
                self.selectionStyle = .none
            }
            
            private func setupSaleImageView() {
                self.saleImageView.clipsToBounds = true
                self.saleImageView.contentMode = .scaleAspectFill
                self.saleImageView.backgroundColor = Theme.Colors.containerBackgroundColor
            }
            
            private func setupNameLabel() {
                self.nameLabel.font = Theme.Fonts.largeTitleFont
                self.nameLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.nameLabel.textAlignment = .left
                self.nameLabel.numberOfLines = 0
                self.nameLabel.lineBreakMode = .byWordWrapping
            }
            
            private func setupShortDescriptionLabel() {
                self.shortDescriptionLabel.font = Theme.Fonts.smallTextFont
                self.shortDescriptionLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.shortDescriptionLabel.textAlignment = .left
                self.shortDescriptionLabel.numberOfLines = 0
                self.shortDescriptionLabel.lineBreakMode = .byWordWrapping
            }
            
            private func setupInvestedAmountLabel() {
                self.investedAmountLabel.font = Theme.Fonts.smallTextFont
                self.investedAmountLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.investedAmountLabel.textAlignment = .left
            }
            
            private func setupPercentLabel() {
                self.percentLabel.font = Theme.Fonts.smallTextFont
                self.percentLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.percentLabel.textAlignment = .right
            }
            
            private func setupProgressView() {
                self.progressView.tintColor = Theme.Colors.mainColor
            }
            
            private func setupInvestorsAmountLabel() {
                self.investorsAmountLabel.font = Theme.Fonts.smallTextFont
                self.investorsAmountLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.investorsAmountLabel.textAlignment = .left
            }
            
            private func setupTimeLabel() {
                self.timeLabel.font = Theme.Fonts.smallTextFont
                self.timeLabel.textColor = Theme.Colors.textOnContentBackgroundColor
                self.timeLabel.textAlignment = .right
            }
            
            private func setupLayout() {
                self.contentView.addSubview(self.saleImageView)
                self.saleImageView.addSubview(self.upcomingImageView)
                self.contentView.addSubview(self.nameLabel)
                self.contentView.addSubview(self.shortDescriptionLabel)
                self.contentView.addSubview(self.investContenView)
                
                self.saleImageView.snp.makeConstraints { (make) in
                    make.top.leading.trailing.equalToSuperview()
                    make.width.equalTo(self.saleImageView.snp.height).multipliedBy(16.0/9.0)
                }
                
                self.upcomingImageView.snp.makeConstraints { (make) in
                    make.top.trailing.equalToSuperview()
                    make.height.width.equalTo(self.saleImageView.snp.height).multipliedBy(0.5)
                }
                
                self.nameLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(self.saleImageView.snp.bottom).offset(self.topInset)
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                }
                
                self.shortDescriptionLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(self.nameLabel.snp.bottom).offset(self.topInset)
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                }
                
                self.investContenView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.shortDescriptionLabel.snp.bottom).offset(self.topInset)
                    make.leading.trailing.equalToSuperview().inset(self.sideInset)
                    make.bottom.equalToSuperview().inset(self.bottomInset)
                }
                
                self.setupInvestedViewLayout()
            }
            
            private func setupInvestedViewLayout () {
                self.investContenView.addSubview(self.investedAmountLabel)
                self.investContenView.addSubview(self.percentLabel)
                self.investContenView.addSubview(self.progressView)
                self.investContenView.addSubview(self.investorsAmountLabel)
                self.investContenView.addSubview(self.timeLabel)
                
                let sideInset: CGFloat = 10
                let topInset: CGFloat = 10
                
                self.investedAmountLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                self.investedAmountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                
                self.percentLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                self.percentLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                
                self.investorsAmountLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                self.investorsAmountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                
                self.timeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                self.timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                
                self.investedAmountLabel.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.leading.equalToSuperview()
                }
                
                self.percentLabel.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.leading.equalTo(self.investedAmountLabel.snp.trailing).offset(sideInset)
                }
                
                self.progressView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.investedAmountLabel.snp.bottom).offset(topInset)
                    make.leading.equalTo(self.investorsAmountLabel.snp.leading)
                    make.trailing.equalTo(self.percentLabel.snp.trailing)
                }
                
                self.investorsAmountLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(self.progressView.snp.bottom).offset(topInset)
                    make.leading.equalToSuperview()
                    make.bottom.lessThanOrEqualToSuperview()
                }
                
                self.timeLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(self.progressView.snp.bottom).offset(topInset)
                    make.trailing.equalToSuperview()
                    make.leading.equalTo(self.investorsAmountLabel.snp.trailing).offset(sideInset)
                    make.bottom.lessThanOrEqualToSuperview()
                }
            }
        }
    }
}

extension Sales.SaleListCell.View {
    enum ImageState {
        case empty
        case loaded(UIImage)
        case loading
    }
}

extension Sales.Model.SaleModel.ImageState {
    var saleCellImageState: Sales.SaleListCell.View.ImageState {
        switch self {
            
        case .empty:
            return .empty
            
        case .loaded(let image):
            return .loaded(image)
            
        case .loading:
            return .loading
        }
    }
}