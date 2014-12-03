defmodule HeaderChecker do
    use ExActor.Strict, export: :HeaderChecker

    import Logger


    defstart start_link(parent, url) do
        info "Starting #{__MODULE__}"
        get_content_length(url)
        initial_state {parent, url}
    end


    defcastp get_content_length(url), export: false do
        filesize = make_head_request(url)
        if (is_integer(filesize)) do
            info "#{__MODULE__}: Total filesize: #{filesize} bytes"
            DownloadEx.set_file_size(url, filesize)
        else
            error "#{__MODULE__}: There was an error when downloading the file."
        end
        noreply
    end


    defp make_head_request(url) do
        HTTPotion.start
        ibrowse = Application.get_env(:downloadex, :ibrowse, [])
        response = HTTPotion.head url, [], [ibrowse: ibrowse]

        cond do
            !HTTPotion.Response.success?(response) ->
                warn "#{__MODULE__}: File download #{url} failed with HTTP status code: #{response.status_code}."
                false
            !Dict.has_key? response.headers, :"Accept-Ranges" ->
                warn "#{__MODULE__}: File download #{url} does not accept range requests."
                false
            !Dict.has_key? response.headers, :"Content-Length" ->
                warn "#{__MODULE__}: File download #{url} did not deliver a response header containing the content length."
                false
            true ->
                String.to_integer(Keyword.get response.headers, :"Content-Length")
        end
    end
end
