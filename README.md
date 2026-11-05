# launchAgents

My macOS LaunchAgents: small background jobs that launchd runs for my user.
Each one lives in its own folder with its script, its plist (or Homebrew
formula), and any notes.

## The agents

- **[compress-screen-recordings](compress-screen-recordings/)**: shrinks
  screen recordings. It watches the Desktop, and when a new `Screen Recording
  *.mov` from the macOS recorder appears, it re-encodes it with x264 into an
  `.mp4` that is usually 5-10x smaller. It deletes the original only after
  checking the new file is the same length. It runs through a tiny wrapper app
  in `~/Applications`, so macOS privacy protection lets it read the Desktop.
  Installed with Homebrew.

- **[smb-autoreconnect](smb-autoreconnect/)**: keeps network shares mounted and
  in Finder's sidebar. Every 15 seconds it adds any SMB/AFP share you mounted to
  its list, remounts listed shares as soon as their server is reachable (after
  sleep, Wi-Fi changes or Tailscale reconnecting), and puts mounted shares back
  in the sidebar Favorites. The list is `~/.config/smb-autoreconnect/shares`.
  Installed with Homebrew and run by `brew services`.

- **[vm-rex-tunnel](vm-rex-tunnel/)**: tunnels to Rex on my Ubuntu Parallels VM.
  While the VM is running, it keeps an SSH tunnel up that forwards the VM's Rex
  server socket to `127.0.0.1:47391` on the Mac. It doesn't poll. launchd starts
  it when the VM's `parallels.log` changes (the VM starting, resuming or
  stopping), and it exits once the VM is down, so it costs nothing while the VM
  is off. SSH keepalives notice a stopped or suspended VM within about 45 s.

- **[audio-sleep-guard](audio-sleep-guard/)**: stops apps' audio holds from
  keeping the Mac awake. A browser tab with a silent Web Audio stream makes
  `coreaudiod` hold an idle-sleep assertion indefinitely, so the Mac never
  sleeps with the screen off and drains the battery. Once a minute, on battery
  with the display off, this checks whether that audio hold is the only thing
  keeping the Mac awake. If it has been for two checks in a row (about a
  minute), it runs `pmset sleepnow`. It leaves explicit `caffeinate` holds alone
  (Claude Code, long jobs). Sleeps are logged to
  `~/Library/Logs/audio-sleep-guard.log`.

## Install

The Homebrew-packaged agents come from my tap,
[amichaelyu/homebrew-tap](https://github.com/amichaelyu/homebrew-tap), which
builds them from this repo:

```sh
brew trust amichaelyu/tap
brew install amichaelyu/tap/compress-screen-recordings
compress-screen-recordings install-agent

brew install amichaelyu/tap/smb-autoreconnect
brew services start smb-autoreconnect
```

The rest install from a clone of this repo. `install.sh` symlinks each script
into `~/.local/bin`, copies its plist into `~/Library/LaunchAgents`, and loads it:

```sh
./install.sh audio-sleep-guard vm-rex-tunnel
./install.sh --uninstall audio-sleep-guard   # unload and remove
```

## Useful commands

```sh
launchctl print gui/$(id -u)/<label>      # state, run count, last exit code
launchctl kickstart -k gui/$(id -u)/<label>   # restart one now
pmset -g assertions                       # what is keeping the Mac awake
```
