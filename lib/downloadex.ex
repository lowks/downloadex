import Supervisor.Spec

defmodule DownloadEx do
    use Application


    def start(_type, args) do
        Task.async(fn -> start_download("http://download.thinkbroadband.com/10MB.zip") end)
        Supervisor.start_link [], [strategy: :rest_for_one, name: DownloadEx.Root]
    end


    def start_link do
        Supervisor.start_link [], [strategy: :rest_for_one, name: DownloadEx.Root]
    end


    def start_download(url) when is_binary(url)  do
        Supervisor.start_child(DownloadEx.Root, worker(HeaderChecker, [self, url], restart: :transient))
    end


    def set_file_size(url, filesize) do
        Supervisor.start_child(DownloadEx.Root, supervisor(Receiver, [nil, url, 0..filesize], restart: :transient))
    end


    def stop_download do
        :ok = Supervisor.terminate_child(DownloadEx.Root, HeaderChecker)
        :ok = Supervisor.terminate_child(DownloadEx.Root, Receiver)
    end
end
