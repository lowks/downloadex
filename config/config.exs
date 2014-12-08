use Mix.Config

config :logger, :console,
  level: :warn,
  format: "$date $time [$level]$levelpad $metadata$message\n",
  metadata: [:user_id]


# Sample configuration with Redis server:
#
# config :downloadex, :redis_connection_string, "redis://127.0.0.1:6379"


# Sample configuration with proxy authentication:
#
# config :downloadex, :ibrowse,
#     [
#         proxy_user: 'XXXXX',
#         proxy_password: 'XXXXX',
#         proxy_host: 'proxy',
#         proxy_port: 8080
#     ]


# Sample configuration with SOCKS5:
#
# config :downloadex, :ibrowse,
#     [
#         socks5_user: 'user4321',
#         socks5_pass: 'pass7654',
#         socks5_host: '127.0.0.1',
#         socks5_port: 5335
#     ]