//
//  Robots.swift
//
//
//  Created by Carson Gross on 4/7/24.
//

import Foundation
import Ignite

/// An example custom robots.txt configuration file, blocking certain paths
/// from Google and Bing, and everything from ChatGPT.
struct Robots: RobotsConfiguration {
    var disallowRules: [DisallowRule]

    init() {
        let paths = [
            "/top/secret/stuff",
            "/wp-admin"
        ]

        disallowRules = [
            DisallowRule(robot: .google, paths: paths),
            DisallowRule(robot: .bing, paths: paths),
            DisallowRule(robot: .chatGPT)
        ]
    }
}
