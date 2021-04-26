import RxSwift
import CoinKit

class CoinMarketsManager {
    private let disposeBag = DisposeBag()

    private let provider: CoinGeckoProvider
    private let defiMarketsProvider: IDefiMarketsProvider
    private let coinInfoManager: CoinInfoManager

    init(coinInfoManager: CoinInfoManager, provider: CoinGeckoProvider, defiMarketsProvider: IDefiMarketsProvider) {
        self.provider = provider
        self.defiMarketsProvider = defiMarketsProvider

        self.coinInfoManager = coinInfoManager
    }

}

extension CoinMarketsManager: ICoinMarketsManager {

    func topCoinMarketsSingle(currencyCode: String, fetchDiffPeriod: TimePeriod, itemCount: Int, defiFilter: Bool) -> Single<[CoinMarket]> {
        provider.topCoinMarketsSingle(currencyCode: currencyCode, fetchDiffPeriod: fetchDiffPeriod, itemCount: itemCount, defiFilter: defiFilter)
    }

    func coinMarketsSingle(currencyCode: String, fetchDiffPeriod: TimePeriod, coinTypes: [CoinType], defiFilter: Bool) -> Single<[CoinMarket]> {
        provider.coinMarketsSingle(
                currencyCode: currencyCode,
                fetchDiffPeriod: fetchDiffPeriod,
                coinTypes: coinTypes,
                defiFilter: defiFilter
        )
    }

    func coinMarketInfoSingle(coinType: CoinType, currencyCode: String, rateDiffTimePeriods: [TimePeriod], rateDiffCoinCodes: [String]) -> Single<CoinMarketInfo> {
        let coin = coinInfoManager.coinInfo(coinType: coinType)

        return Single.zip(
                provider.coinMarketInfoSingle(coinType: coinType, currencyCode: currencyCode, rateDiffTimePeriods: rateDiffTimePeriods, rateDiffCoinCodes: rateDiffCoinCodes),
                defiMarketsProvider.defiTvl(coinType: coinType, currencyCode: currencyCode)
                        .catchErrorJustReturn(DefiTvl(data: CoinData(coinType: coinType, code: "", name: ""), tvl: 0, tvlDiff: 0))
        )
                .map { coinInfoResponse, defiTvl in
                    var links = [LinkType: String]()

                    for linkType in LinkType.allCases {
                        links[linkType] = coin?.meta.links[linkType] ?? coinInfoResponse.links[linkType] ?? ""
                    }

                    let data: CoinData = CoinData(coinType: coinType, code: coin?.data.code ?? "", name: coin?.data.name ?? "")
                    let meta = CoinMeta(
                            description: coin?.meta.description ?? coinInfoResponse.description,
                            links: links,
                            rating: coin?.meta.rating,
                            categories: coin?.meta.categories ?? [],
                            fundCategories: coin?.meta.fundCategories ?? [],
                            platforms: coinInfoResponse.platforms
                    )

                    return CoinMarketInfo(
                            data: data,
                            meta: meta,
                            currencyCode: currencyCode,
                            rate: coinInfoResponse.rate,
                            rateHigh24h: coinInfoResponse.rateHigh24h,
                            rateLow24h: coinInfoResponse.rateLow24h,
                            totalSupply: coinInfoResponse.totalSupply,
                            circulatingSupply: coinInfoResponse.circulatingSupply,
                            volume24h: coinInfoResponse.volume24h,
                            marketCap: coinInfoResponse.marketCap,
                            dilutedMarketCap: coinInfoResponse.dilutedMarketCap,
                            marketCapDiff24h: coinInfoResponse.marketCapDiff24h,
                            defiTvl: defiTvl.tvl,
                            rateDiffs: coinInfoResponse.rateDiffs,
                            tickers: coinInfoResponse.tickers
                    )
                }
    }

}