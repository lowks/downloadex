DownloadEx
=====================

A fault-tolerant download manager in Elixir that can download a single file in parallel.


### Installation

1. Clone the repository with `git clone git@github.com:my-flow/downloadex.git`.
2. Install the required dependencies with `mix deps.get`.
3. Start Elixir's interactive shell with `iex -S mix`.


### Start downloading a file
```
iex(1)> DownloadEx.start_download("http://www.wswd.net/testdownloadfiles/10MB.zip")
```

## Redis Settings
If you want to use Redis to serve chunks, add the connection settings to `config/config.exs`:
```
config :downloadex, :redis_connection_string, "redis://127.0.0.1:6379"
```

## Proxy Settings
Find sample configurations in `config/config.exs` that show how to set up proxy authentication and SOCKS5.


## Copyright & License

Copyright (c) 2014 [Florian J. Breunig](http://www.my-flow.com)

Licensed under MIT, see LICENSE file.