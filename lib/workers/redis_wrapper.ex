defmodule RedisWrapper do
    use Exredis


    def set(redis_connection_string, url, first.._, chunk) do
        Exredis.start_using_connection_string(redis_connection_string)
            |> query ["ZADD", "downloadex:#{url}", first, chunk]
    end


    def get(redis_connection_string, url) do
        Exredis.start_using_connection_string(redis_connection_string)
            |> query ["ZRANGE", "downloadex:#{url}", 0, -1]
    end


    def delete(redis_connection_string, url) do
        Exredis.start_using_connection_string(redis_connection_string)
            |> query ["DEL", "downloadex:#{url}"]
    end
end