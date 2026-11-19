# smb-autoreconnect

Keeps network shares mounted and in Finder's sidebar. Finder hides a favorite
whenever its volume is unmounted (off network, Tailscale down, sleep). Every 15
seconds a LaunchAgent:

- adds any SMB/AFP share you mount yourself to its list,
- remounts each listed share as soon as its server is reachable,
- adds each mounted share to the sidebar Favorites if it isn't there.

## Install

```sh
brew trust amichaelyu/tap   # Homebrew won't load third-party tap formulae until trusted
brew install amichaelyu/tap/smb-autoreconnect
brew services start smb-autoreconnect
```

Then connect to each share once in Finder (Go > Connect to Server) and tick
"Remember this password". It's picked up from there.

The list is `~/.config/smb-autoreconnect/shares`, one URL per line
(`smb://user@host/share`, `#` starts a comment). To stop tracking a share,
prefix its line with `!`; deleting the line doesn't work while it's mounted,
since it would be re-added.

Runs are skipped while the Mac is in a DarkWake (Power Nap / maintenance wake
during sleep), and each mount gives up after 30 seconds
(`SMB_AUTORECONNECT_MOUNT_TIMEOUT`), so sleeping mid-mount can't wedge the agent.

The log is at `$(brew --prefix)/var/log/smb-autoreconnect.log`.
