import Supervisor.Spec

defmodule DownloadEx do
    use Application


    def start(_type, _args) do
        Supervisor.start_link [], [strategy: :rest_for_one, name: DownloadEx.Root]
    end


    def start_link do
        Supervisor.start_link [], [strategy: :rest_for_one, name: DownloadEx.Root]
    end


    def start_download(url) when is_binary(url) do
        Supervisor.start_child(DownloadEx.Root, worker(HeaderChecker, [self, url], restart: :transient))
    end


    def set_file_size(url, filesize) do
        %URI{path: path} = URI.parse(url)
        target = Path.join(System.cwd!, Path.basename(path))

        redis_connection_string = Application.get_env(:downloadex, :redis_connection_string)
        concatenator = case redis_connection_string do
            nil -> worker(FileConcatenator,  [target], restart: :transient)
            _   -> worker(RedisConcatenator, [target, url, redis_connection_string], restart: :transient)
        end

        {:ok, _} = Supervisor.start_child(DownloadEx.Root, concatenator)
        {:ok, _} = Supervisor.start_child(
            DownloadEx.Root,
            supervisor(Receiver, [nil, url, 0..filesize], restart: :transient)
        )
    end


    def stop_download do
        :ok = Supervisor.terminate_child(DownloadEx.Root, HeaderChecker)
        :ok = Supervisor.terminate_child(DownloadEx.Root, Receiver)
    end
end
