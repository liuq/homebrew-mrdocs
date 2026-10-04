# homebrew-mrdocs

Homebrew formulae for [MrDocs](https://github.com/cppalliance/mrdocs), the C++ reference documentation generator.

| Formula      | What it installs                                              | Platforms                  |
|--------------|---------------------------------------------------------------|----------------------------|
| `mrdocs`     | Built from source against Homebrew's `llvm` (~1 min build)    | macOS, Linux               |
| `mrdocs-bin` | Upstream prebuilt release binaries, no build required         | macOS arm64, Linux x86_64  |

```sh
brew install liuq/mrdocs/mrdocs       # build from source
brew install liuq/mrdocs/mrdocs-bin   # prebuilt binaries
```

The two formulae conflict with each other; install only one.
