# compress-screen-recordings

macOS screen recordings (⌘⇧5) are huge: the built-in recorder captures at full
Retina resolution with Apple's real-time hardware encoder at a high bitrate. This
watches the Desktop and re-encodes each new recording with x264, which is usually
5-10x smaller with no visible difference (a 79 s recording went from 279 MB to 29 MB).

## Install

```sh
brew trust amichaelyu/tap   # Homebrew won't load third-party tap formulae until trusted
brew install amichaelyu/tap/compress-screen-recordings
compress-screen-recordings install-agent
```

macOS then asks to let "Compress Screen Recordings" access your Desktop. Click
Allow. From then on, every new screen recording on the Desktop becomes an `.mp4`
with the same name, and the original `.mov` is deleted.

To remove it, run `compress-screen-recordings uninstall-agent` before
`brew uninstall compress-screen-recordings`.

## What it touches

Only files on the Desktop that are **both** named `Screen Recording *.mov` **and**
tagged `com.apple.quicktime.author = ReplayKitRecording`, which the macOS recorder
writes into every recording. Other videos are left alone, even with a matching name.

The original is deleted only after the `.mp4` is checked to be the same length. If
ffmpeg fails or the length is off, the original is kept and the failure is logged
in `~/Library/Logs/compress-screen-recordings.log`.

## How it works

`install-agent` sets up a LaunchAgent that runs whenever the Desktop changes. A
LaunchAgent can't run the script directly: macOS privacy protection (TCC) blocks a
bare `zsh` started by launchd from reading the Desktop and can't even ask you. So
`install-agent` also builds a tiny AppleScript app in `~/Applications` that runs
the script. macOS asks once for that app, and everything it starts (`zsh`,
`ffmpeg`, `rm`) inherits the permission. It grants access to the Desktop only, not
Full Disk Access.

| Path | What |
| --- | --- |
| `~/Library/LaunchAgents/io.github.amichaelyu.compress-screen-recordings.plist` | The LaunchAgent |
| `~/Applications/Compress Screen Recordings.app` | The wrapper app that holds the Desktop permission |
| `~/Library/Logs/compress-screen-recordings.log` | What was compressed or skipped |

Run `compress-screen-recordings run` to process the Desktop by hand.
