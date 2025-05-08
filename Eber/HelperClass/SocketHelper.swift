//
//  SocketHelper.swift
//  Eber
//
//  Created by Elluminati on 13.03.19.
//  Copyright © 2019 Elluminati. All rights reserved.
//

import Foundation
import SocketIO

class SocketHelper:NSObject {

    let manager = SocketManager(socketURL: URL(string:WebService.BASE_URL)!, config: [.log(false), .compress])

    var socket:SocketIOClient? = nil
    let tripDetailNotify:String = "trip_detail_notify"
    let applePay:String = "applepay_" // 'applepay_" + user_id + '
    let joinTrip:String = "join_trip"
    let paytabs:String = "paytabs_"
    static let shared = SocketHelper()

    override init() {
        super.init()
    }

    deinit {
        printE("\(self) \(#function)")
    }

    func connectSocket() {
        socket = manager.defaultSocket

        socket?.on(clientEvent: .connect) { (data, ack) in
            printE("Socket Connection Connected")
            NotificationCenter.default.post(name: .socketConnected, object: nil)
        }

        socket?.on(clientEvent: .error) { (data, ack) in
            print("Socket Connection Error = \(data.description) and ack = \(ack.description)")
            self.disConnectSocket()
        }

        socket?.on(clientEvent: .pong) { (data, ack) in
            printE("Socket Connection Pong \(data) Ack \(ack)")
        }
        socket?.connect()
    }

    func disConnectSocket() {
        if self.socket?.status == .connected {
            print("Socket Connection disconnected")
            self.socket?.disconnect()
        }
    }
    
    func isConnected() -> Bool {
        if self.socket?.status == .connected {
            return true
        }
        return false
    }
}
