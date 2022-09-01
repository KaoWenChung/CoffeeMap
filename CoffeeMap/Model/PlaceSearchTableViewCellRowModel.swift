//
//  PlaceSearchCellModel.swift
//  CoffeeMap
//
//  Created by owenkao on 2022/09/01.
//

struct PlaceSearchTableViewCellRowModel: BaseCellRowModel {
    var cellID: String { return "PlaceSearchTableViewCell" }
    
    var cellAction: ((BaseCellRowModel) -> ())?
    
    let name: String
    let address: String
    let distance: String?
    
    init(_ dataModel: GetPlaceResultModel) {
        name = dataModel.name ?? ""
        if let location = dataModel.location,
           let address = location.formattedAddress,
           !address.isEmpty {
            self.address = address
        } else {
            address = "-"
        }
        if let distance = dataModel.distance {
            self.distance = distance.description + " meters"
        } else {
            distance = nil
        }
    }
}
