(() => {
    if (!location.href.startsWith("https://play.google.com/music/listen")) return
    function sendLogToNative(...obj) {
        console.log(...obj)
        window.webkit.messageHandlers.jsLogging.postMessage(obj.toString())
    }
    function loopWhileReturnNull(f, maxCount = -1) {
        return new Promise((resolve, reject) => {
            var count = 0
            const timer = setInterval(() => {
                count++
                try {
                    const ret = f()
                    if (ret != null) {
                        clearInterval(timer)
                        resolve(ret)
                    }
                    if (maxCount > 0 && count >= maxCount) {
                        reject("time out")
                    }
                } catch(e) {
                    clearInterval(timer)
                    reject(e)
                }
            }, 100)
        })
    }
    window.__gpmac__refreshInformation = (playerSongInfo = document.getElementById("playerSongInfo")) => {
        if (playerSongInfo == null) return
        if (playerSongInfo.style.display === "none") {
            webkit.messageHandlers.playingStateChanged.postMessage("stopped")
            return
        }
        const nowPlayingTitle = document.getElementById("currently-playing-title")
        const nowPlayingArtist = document.getElementById("player-artist")
        const nowPlayingAlbum = document.getElementById("player-album")
        const nowPlayingAlbumArt = document.getElementById("playerBarArt")
        const nowPlayingSeekBar = document.getElementById("material-player-progress")
        const playOrPauseButton = document.getElementById("player-bar-play-pause")
        const rewindButton = document.getElementById("player-bar-rewind")
        const forwardButton = document.getElementById("player-bar-forward")
        webkit.messageHandlers.playingSongChanged.postMessage(JSON.stringify({
            title: nowPlayingTitle && nowPlayingTitle.title,
            artist: nowPlayingArtist && {
                id: nowPlayingArtist.getAttribute("data-id"),
                text: nowPlayingArtist.textContent,
            },
            album: nowPlayingAlbum && {
                id: nowPlayingAlbum.getAttribute("data-id"),
                text: nowPlayingAlbum.textContent,
            },
            albumArt: nowPlayingAlbumArt && nowPlayingAlbumArt.src,
            seek: {
                current: parseInt(nowPlayingSeekBar.getAttribute("value"), 10),
                length: parseInt(nowPlayingSeekBar.getAttribute("aria-valuemax"), 10),
            },
            canSkip: {
                previous: !rewindButton.disabled,
                next: !forwardButton.disabled,
            }
        }))
        if (playOrPauseButton) webkit.messageHandlers.playingStateChanged.postMessage(playOrPauseButton.className === "" ? "paused" : "playing")
    }
    window.__gpmac__ = {
        play() {
            const playOrPauseButton = document.getElementById("player-bar-play-pause")
            if (playOrPauseButton && playOrPauseButton.className === "") playOrPauseButton.click()
        },
        pause() {
            const playOrPauseButton = document.getElementById("player-bar-play-pause")
            if (playOrPauseButton && playOrPauseButton.className === "playing") playOrPauseButton.click()
        },
        previousTrack() {
            const rewindButton = document.getElementById("player-bar-rewind")
            if (rewindButton && !rewindButton.disabled) rewindButton.click()
        },
        nextTrack() {
            const forwardButton = document.getElementById("player-bar-forward")
            if (forwardButton && !forwardButton.disabled) forwardButton.click()
        }
    }
    addEventListener("DOMContentLoaded", async () => {
        try {
            const playerSongInfo = await loopWhileReturnNull(() => document.getElementById("playerSongInfo"))
            sendLogToNative("playerSongInfo", playerSongInfo)
            const playerSongInfoObserver = new MutationObserver((records, observer) => {
                window.__gpmac__refreshInformation(playerSongInfo)
            })
            playerSongInfoObserver.observe(playerSongInfo, {
                childList: true,
                attributes: true,
                attributeFilter: ["style"],
            })
        } catch(e) {
            sendLogToNative("failed in DOMContentLoaded", e)
        }
    })
})()
