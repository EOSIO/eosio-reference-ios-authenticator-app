//
//  DateExtensions.swift
//  Eosio
//
//  Created by Steve McCoole on 10/15/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation

extension Date {

    static func getFormattedTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeString = dateFormatter.string(from: now)
        return timeString
    }

}
