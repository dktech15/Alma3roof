//
//  MapPolyline.swift
//  Eber
//
//  Created by Mayur on 24/01/23.
//  Copyright © 2023 Elluminati. All rights reserved.
//

import Foundation

struct MapPath : Decodable{
    var routes : [Route]?
}

struct Route : Decodable{
    var overview_polyline : OverView?
}

struct OverView : Decodable {
    var points : String?
}
