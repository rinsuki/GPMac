//
//  ViewController.swift
//  GPMac
//
//  Created by user on 2019/12/06.
//  Copyright © 2019 rinsuki. All rights reserved.
//

import Cocoa
import WebKit
import SnapKit
import MediaPlayer
import Nuke

class ViewController: NSViewController {

    private var webView: CustomWebView!
    private lazy var remoteCommandCenter = MPRemoteCommandCenter.shared()
    private lazy var nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    var currentAlbumArtUrl: URL?
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "jsLogging")
        config.userContentController.add(self, name: "playingStateChanged")
        config.userContentController.add(self, name: "playingSongChanged")
        let js = try! String(contentsOfFile: Bundle.main.path(forResource: "InjectScript", ofType: "js")!)
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        
        webView = .init(frame: .zero, configuration: config)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Safari/605.1.15"
        let url = URL(string: "https://play.google.com/music/listen")!
        webView.load(.init(url: url))
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
            make.width.greaterThanOrEqualTo(970)
            make.height.greaterThanOrEqualTo(90)
        }
        
        // for Touch bar
        remoteCommandCenter.playCommand.addTarget(self, action: #selector(play))
        remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(pause))
        // for NowPlaying widget / media key
        remoteCommandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(switchPlayOrPause))
        
        remoteCommandCenter.previousTrackCommand.addTarget(self, action: #selector(previousTrack))
        remoteCommandCenter.nextTrackCommand.addTarget(self, action: #selector(nextTrack))
        
        nowPlayingInfoCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: "REALLY GOOOD SONG",
            MPMediaItemPropertyArtist: "GOD",
            MPMediaItemPropertyAlbumTitle: "GIFT FROM GOD",
        ]
        nowPlayingInfoCenter.playbackState = .playing
        webView.touchBar = nil
        webView._wantsMediaPlaybackControlsView = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func switchPlayOrPause() {
        webView.evaluateJavaScript("document.getElementById('player-bar-play-pause').click()", completionHandler: nil)
    }
    
    @objc func play() {
        webView.evaluateJavaScript("window.__gpmac__ && window.__gpmac__.play()", completionHandler: nil)
    }
    
    @objc func pause() {
        webView.evaluateJavaScript("window.__gpmac__ && window.__gpmac__.pause()", completionHandler: nil)
    }
    
    @objc func previousTrack() {
        webView.evaluateJavaScript("window.__gpmac__ && window.__gpmac__.previousTrack()", completionHandler: nil)
    }
    
    @objc func nextTrack() {
        webView.evaluateJavaScript("window.__gpmac__ && window.__gpmac__.nextTrack()", completionHandler: nil)
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "jsLogging":
            print("LOG From JavaScript:", message.body)
        case "playingStateChanged":
            switch message.body as? String {
            case "playing":
                nowPlayingInfoCenter.playbackState = .playing
            case "paused":
                nowPlayingInfoCenter.playbackState = .paused
            case "stopped":
                nowPlayingInfoCenter.playbackState = .stopped
            default:
                nowPlayingInfoCenter.playbackState = .unknown
                print("UNKNOWN PLAYING STATE", message.body)
            }
        case "playingSongChanged":
            guard let body = message.body as? String else { return }
            let decoder = JSONDecoder()
            let state = try! decoder.decode(GPMNowPlayingState.self, from: body.data(using: .utf8)!)
            print(state)

            remoteCommandCenter.previousTrackCommand.isEnabled = state.canSkip.previous
            remoteCommandCenter.nextTrackCommand.isEnabled = state.canSkip.next

            nowPlayingInfoCenter.nowPlayingInfo![MPMediaItemPropertyTitle] = state.title
            nowPlayingInfoCenter.nowPlayingInfo![MPMediaItemPropertyArtist] = state.artist?.text
            nowPlayingInfoCenter.nowPlayingInfo![MPMediaItemPropertyAlbumTitle] = state.album?.text
            if let seek = state.seek, seek.length > 0 {
                nowPlayingInfoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(seek.current) / 1000.0
                nowPlayingInfoCenter.nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = Float(seek.length) / 1000.0
            }
            nowPlayingInfoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyChapterCount] = 3
            if let albumArt = state.albumArt, currentAlbumArtUrl != albumArt {
                currentAlbumArtUrl = albumArt
                // そのままだと90x90の画像が来るのでオリジナルをリクエストする
                let originalUrl = URL(string: albumArt.absoluteString.replacingOccurrences(of: "s90-", with: ""))!
                loadAlbumArt(url: originalUrl)
            }
        default:
            print("UNKNOWN MESSAGE", message.name)
        }
    }
    
    func loadAlbumArt(url: URL) {
        print("load start", url.absoluteString)
        Nuke.ImagePipeline.shared.loadImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let r):
                let image = r.image
                print(image.size)
                self.nowPlayingInfoCenter.nowPlayingInfo![MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size -> NSImage in
                    print(size)
                    return image
                }
            case .failure(let err):
                print(err)
            }
        }
    }
}
