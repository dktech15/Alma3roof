//
//  JsonParsable.swift
//  Eber
//
//  Created by Rohit on 04/08/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//


import Foundation
import Foundation

typealias JSONType = [String: Any]

protocol JSONParsable {
    init?(json: JSONType?)
}
