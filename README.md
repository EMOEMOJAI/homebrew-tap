# EMOEMOJAI Homebrew tap

```sh
brew install emoemojai/tap/sidecarkeeper
brew services start sidecarkeeper
```

| Formula | What it is |
| --- | --- |
| `sidecarkeeper` | [SidecarKeeper](https://github.com/EMOEMOJAI/SidecarKeeper): auto-reconnects Apple Sidecar, so an iPad keeps working as a Mac's second display after sleep, lock or lid close |

The formula builds from the tagged source with the Swift compiler that Homebrew already
requires, so nothing downloaded is a prebuilt binary. A scheduled workflow checks for new
SidecarKeeper releases, and only updates the formula after installing and testing it.

Remove with `brew services stop sidecarkeeper && brew uninstall sidecarkeeper`.
