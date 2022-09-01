//
//  BaseViewModel.swift
//  CoffeeMap
//
//  Created by owenkao on 2022/09/01.
//

class BaseViewModel {

    typealias Completion = (_ result: CompletionResult) -> Void

    enum CompletionResult {
        case success
        case failure(CustomError)
    }

}

struct CustomError: Error {

    var message: String = ""

    init(_ message: String) {
        self.message = message
    }

}
