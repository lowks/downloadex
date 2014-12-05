defmodule Client do
    use ExActor.Strict

    import Logger


    defstart start_link(parent, url, range) do
        debug "#{inspect self}: Initializing client in range #{inspect range} with URL #{url}"
        :random.seed(:erlang.now)
        __MODULE__.start_download(self)
        initial_state {parent, url, range, -1, nil}
    end


    defcast start_download, state: {parent, url, range = first..last, _, _} do
        HTTPotion.start
        file = Tempfile.get_name
        debug "#{inspect self} (Client): Start downloading part #{inspect range} to file #{file}"
        headers = [
            "Range": "bytes=#{first}-#{last}",
            "Connection": "keep-alive"
        ]
        ibrowse = Dict.merge [save_response_to_file: String.to_char_list(file)], Application.get_env(:downloadex, :ibrowse, [])

        %HTTPotion.AsyncResponse{id: async_id} = HTTPotion.get(
            url,
            headers,
            [
                stream_to: self,
                ibrowse:   ibrowse,
                timeout:   600_000
            ]
        )
        new_state {parent, url, range, async_id, file}
    end


    defhandleinfo %HTTPotion.AsyncHeaders{id: id, status_code: status_code},
    state: {_, _, _, async_id, _}, export: false, when: id == async_id do
        unless status_code in 200..299 or status_code in [302, 304] do
            msg = "#{__MODULE__}: Request failed with HTTP status code #{status_code}."
            error(msg)
            raise RuntimeError, message: msg
        end
        noreply
    end


    defhandleinfo %HTTPotion.AsyncChunk{id: id},
    state: {_, _, _, async_id, _}, export: false, when: id == async_id do
        noreply
    end


    defhandleinfo %HTTPotion.AsyncEnd{id: id},
    state: {parent, _, range, async_id, file}, export: false, when: id == async_id do
        Receiver.finish_download(parent, range, file)
        noreply
    end

end
