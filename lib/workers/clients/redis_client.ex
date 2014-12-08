defmodule RedisClient do
    use ExActor.Strict

    import Logger


    defstart start_link(parent, url, range, redis_connection_string) do
        debug "#{inspect self}: Initializing client in range #{inspect range} with URL #{url}"
        __MODULE__.start_download(self)
        initial_state {parent, url, range, redis_connection_string, -1}
    end


    defcast start_download, state: {parent, url, range = first..last, redis_connection_string, _} do
        HTTPotion.start
        debug "#{inspect self} (Client): Start downloading part #{inspect range} to Redis"
        headers = [
            "Range": "bytes=#{first}-#{last}",
            "Connection": "keep-alive"
        ]
        ibrowse = Dict.merge [], Application.get_env(:downloadex, :ibrowse, [])

        %HTTPotion.AsyncResponse{id: async_id} = HTTPotion.get(
            url,
            headers,
            [
                stream_to: self,
                ibrowse:   ibrowse,
                timeout:   600_000
            ]
        )
        new_state {parent, url, range, redis_connection_string, async_id}
    end


    defhandleinfo %HTTPotion.AsyncHeaders{id: id, status_code: status_code},
    state: {_, _, _, _, async_id}, export: false, when: id == async_id do
        unless status_code in 200..299 or status_code in [302, 304] do
            msg = "#{__MODULE__}: Request failed with HTTP status code #{status_code}."
            error(msg)
            raise RuntimeError, message: msg
        end
        noreply
    end


    defhandleinfo %HTTPotion.AsyncChunk{id: id, chunk: chunk},
    state: {_, url, range, redis_connection_string, async_id}, export: false, when: id == async_id do
        RedisWrapper.set(redis_connection_string, url, range, chunk)
        noreply
    end


    defhandleinfo %HTTPotion.AsyncEnd{id: id},
    state: {parent, _, range, _, async_id}, export: false, when: id == async_id do
        Receiver.finish_download(parent, range, inspect range)
        noreply
    end

end
