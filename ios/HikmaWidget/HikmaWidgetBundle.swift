//
//  HikmaWidgetBundle.swift
//  HikmaWidget
//
//  Created by Macbook on 03/11/2026.
//

import WidgetKit
import SwiftUI

@main
struct HikmaWidgetBundle: WidgetBundle {
    var body: some Widget {
        HikmaWidget()
        HikmaWidgetControl()
        HikmaWidgetLiveActivity()
    }
}
