//
//  WKWebViewPrivate.h
//  GPMac
//
//  Created by user on 2019/12/07.
//  Copyright © 2019 rinsuki. All rights reserved.
//

#import <WebKit/WebKit.h>

#ifndef WKWebViewPrivate_h
#define WKWebViewPrivate_h

@interface WKWebView (WKPrivate)
@property (nonatomic, readwrite, setter=_setWantsMediaPlaybackControlsView:) BOOL _wantsMediaPlaybackControlsView;


- (void)_requestActiveNowPlayingSessionInfo:(void(^)(BOOL, BOOL, NSString*, double, double, NSInteger))callback;

@end

#endif /* WKWebViewPrivate_h */
