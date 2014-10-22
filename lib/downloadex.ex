import Supervisor.Spec

defmodule DownloadEx do
    use Application

    import Logger


    def start(_type, _args) do
        Task.async(fn -> start_download("http://download.thinkbroadband.com/10MB.zip") end)
        Supervisor.start_link [], [strategy: :rest_for_one, name: DownloadEx.Root]
    end


    def start_download(url) do
        {:ok, _} = Supervisor.start_child(
            DownloadEx.Root,
            worker(HeaderChecker, [self, url], restart: :transient)
        )
    end


    def set_file_size(url, filesize) do
        debug "#{__MODULE__}: start_distributed_nodes"

        # create the new root node of the binary tree
        Supervisor.start_child(DownloadEx.Root, supervisor(Receiver, [nil, url, 0..filesize]))
    end
end
