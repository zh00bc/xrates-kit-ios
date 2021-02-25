import UIKit
import XRatesKit
import CoinKit

class MainController: UITabBarController {
    private let currencyCode = "USD"

    private let marketInfoCoins = [
        XRatesKit.Coin(code: "BTC", title: "Bitcoin", type: .bitcoin),
        XRatesKit.Coin(code: "ETH", title: "Ethereum", type: .ethereum),
        XRatesKit.Coin(code: "BCH", title: "Bitcoin Cash", type: .bitcoinCash),
        XRatesKit.Coin(code: "DASH", title: "Dash", type: .dash),
        XRatesKit.Coin(code: "BNB", title: "Binance", type: .binance),
        XRatesKit.Coin(code: "EOS", title: "EOS", type: .eos),
        XRatesKit.Coin(code: "Uni", title: "UNI Token", type: .erc20(address: "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984")),
        XRatesKit.Coin(code: "ADAI", title: "aDAI Token", type: .erc20(address: "0xfc1e690f61efd961294b3e1ce3313fbd8aa4f85d"))
    ]
    private let historicalCoinType = CoinType.bitcoin
    private let chartCoinType = CoinType.bitcoin

    init() {
        super.init(nibName: nil, bundle: nil)

        let xRatesKit = XRatesKit.instance(currencyCode: currencyCode, uniswapSubgraphUrl: "https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v2", minLogLevel: .verbose)
        xRatesKit.set(coinTypes: marketInfoCoins.map { $0.type })

        let topMarketInfoController = TopMarketController(xRatesKit: xRatesKit, storage: UserDefaultsStorage(), currencyCode: currencyCode)
        topMarketInfoController.tabBarItem = UITabBarItem(title: "Top Markets", image: UIImage(systemName: "dollarsign.circle"), tag: 0)

        let marketInfoController = MarketInfoController(xRatesKit: xRatesKit, currencyCode: currencyCode, coins: marketInfoCoins)
        marketInfoController.tabBarItem = UITabBarItem(title: "Market Info", image: UIImage(systemName: "dollarsign.circle"), tag: 0)

        let historicalController = HistoricalController(xRatesKit: xRatesKit, currencyCode: currencyCode, coinType: historicalCoinType)
        historicalController.tabBarItem = UITabBarItem(title: "Historical", image: UIImage(systemName: "calendar"), tag: 1)

        let chartController = ChartController(xRatesKit: xRatesKit, currencyCode: currencyCode, coinType: chartCoinType)
        chartController.tabBarItem = UITabBarItem(title: "Chart", image: UIImage(systemName: "chart.bar"), tag: 2)

        viewControllers = [
            UINavigationController(rootViewController: topMarketInfoController),
            UINavigationController(rootViewController: marketInfoController),
            UINavigationController(rootViewController: historicalController),
            UINavigationController(rootViewController: chartController)
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
