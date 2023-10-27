//
//  McWidgetBundle.swift
//  McWidget
//
//  Created by Christopher Weinhardt on 2023-10-05.
//

import WidgetKit
import SwiftUI

@main
struct McWidgetBundle: WidgetBundle {
    var body: some Widget {
        McWidget()
        McWidgetLiveActivity()
    }
}
