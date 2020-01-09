//
//  CustomWebView.swift
//  GPMac
//
//  Created by user on 2019/12/07.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Foundation
import WebKit

class CustomWebView: WKWebView {
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        for item in menu.items {
            item.identifier = .init("WKMenuItemIdentifierInspectElement")
            print(item.identifier, item.target, item.action, item.title, item)
        }
    }
    
    override func _requestActiveNowPlayingSessionInfo(_ callback: ((Bool, Bool, String?, Double, Double, Int) -> Void)!) {
        print("unchi")
    }
}
