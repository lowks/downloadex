defmodule Receiver do
    use GenServer

    # Client API

    def start_link(name \\ :default, parent, url) do
        IO.puts "#{inspect self}: Initializing new GenServer \"#{name}\" with URL #{url}"
        GenServer.start_link(__MODULE__, {parent, url}, [name:   name])
    end

    def init(parent, url) do
        {:ok, {parent, url}}
    end

    def start_download(pid) do
       GenServer.cast(pid, {:start_download})
    end

    # Server Callbacks

    def handle_cast({:start_download}, state = {_, url}) do
        HTTPoison.start
        # file = Path.join("/Users/florian", "h")
        # ibrowse = [save_response_to_file: String.to_char_list(file)]
        # HTTPotion.get url, [], [stream_to: self, ibrowse: ibrowse, timeout: 600000]
        # {:noreply, state}

        ibrowse = [proxy_host: String.to_char_list("localhost"), proxy_port: String.to_char_list("8888")]
        hackney = [proxy: {"127.0.0.1", 8888}]
        headers = HashDict.new
        # headers = Dict.put headers, "Range", "bytes=0-999"
        headers = Dict.put headers, "Connection", "keep-alive"
        headers = Dict.put headers, "If-Unmodified-Since", "Wed, 22 Oct 2014 02:34:24 GMT"
        HTTPoison.head url, headers, [stream_to: self, ibrowse: ibrowse, timeout: 600000, hackney: hackney]
        {:noreply, state}
    end

    def handle_info(headers = %HTTPoison.AsyncHeaders{}, state) do
        IO.puts "Received headers #{inspect headers} for state #{inspect state}!"
        {:noreply, state}
    end

    def handle_info(chunk = %HTTPoison.AsyncChunk{}, state) do
        #IO.puts "Received chunk #{inspect chunk} for state #{inspect state}!"
        {:noreply, state}
    end

    def handle_info(asyncEnd = %HTTPoison.AsyncEnd{}, state) do
        IO.puts "Received end #{inspect asyncEnd} for state #{inspect state}!"
        {:noreply, state}
    end

    def handle_info(msg, state) do
        IO.puts "Received message #{inspect msg} for state #{inspect state}!"
        {:noreply, state}
    end
end
