//
//  CafeListViewModel.swift
//  CoffeeMap
//
//  Created by owenkao on 2022/09/01.
//

struct CafeListViewModelActions {
    let showCafeRoute: (CafeTableViewCellModel) -> Void
    
}
protocol CafeListViewModelInput {
    func fetchDataBy(latitudeLongitude: String) async
    func didLoadNextPage() async
    func didSelectItem(_ viewModel: CafeTableViewCellModel)
    func didSortList(_ sort: CafeListViewModel.SortType) async
    func refreshQuery()
}

protocol CafeListViewModelOutput {
    var placeList: Observable<[CafeTableViewCellModel]> { get }
    var error: Observable<String> { get }
    var errorTitle: String { get }
}

protocol CafeListViewModelType: CafeListViewModelInput, CafeListViewModelOutput {}

final class CafeListViewModel: CafeListViewModelType {

    enum PageStatus {
        case loading
        case hasNextPage
        case lastPage
    }

    enum SortType: String {
        case distance = "DISTANCE"
        case popularity = "POPULARITY"
    }

    private let searchCafeUseCase: SearchCafeListUseCaseType
    private let actions: CafeListViewModelActions?
    private var cafesLoadTask: CancellableType? { willSet { cafesLoadTask?.cancel() } }
    // If there is a next page, we can get a cursor from searchCafeUseCase
    private let query = CafePlaceRequestDTO()
    private(set) var nextPageStatus: PageStatus = .loading

    let placeList: Observable<[CafeTableViewCellModel]> = Observable([])
    let error: Observable<String> = Observable("")
    let errorTitle: String = CommonString.error.text

    init(searchCafeUseCase: SearchCafeListUseCaseType,
         actions: CafeListViewModelActions?) {
        self.searchCafeUseCase = searchCafeUseCase
        self.actions = actions
    }

    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ? ErrorString.noInternet.text : ErrorString.failLoadingCafe.text
    }

    private func fetchData() async {
        let task = Task {
            do {
                let value = try await searchCafeUseCase.execute(request: query)
                placeList.value.append(contentsOf: value.cafeList)
                if let cursor = value.cursor {
                    nextPageStatus = .hasNextPage
                    query.cursor = cursor
                } else {
                    nextPageStatus = .lastPage
                    query.cursor = nil
                }
            } catch {
                handle(error: error)
            }
        }
        cafesLoadTask = task
        await task.value
    }
}

extension CafeListViewModel {
    func fetchDataBy(latitudeLongitude: String) async {
        query.ll = latitudeLongitude
        await fetchData()
    }

    func didSelectItem(_ viewModel: CafeTableViewCellModel) {
        actions?.showCafeRoute(viewModel)
    }
    
    func didLoadNextPage() async {
        if nextPageStatus == .lastPage { return }
        await fetchData()
    }

    func didSortList(_ sort: SortType) async {
        query.sort = sort.rawValue
        refreshQuery()
        await fetchData()
    }
    
    func refreshQuery() {
        placeList.value.removeAll()
        nextPageStatus = .loading
        query.cursor = nil
    }
}
