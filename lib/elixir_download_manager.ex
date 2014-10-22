import Supervisor.Spec

defmodule ElixirDownloadManager do
    use Application

    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    def start(_type, _args) do
        children = []
        # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
        # for other strategies and supported options
        opts = [strategy: :one_for_one, name: ElixirDownloadManager.Supervisor]
        res = Supervisor.start_link(children, opts)

        initialize_players("http://download.thinkbroadband.com/10MB.zip")
        #initialize_players("http://httpbin.org/bytes/2048")
        start_download
        res
    end

    def initialize_players(url) do
        # delete old child
        Supervisor.terminate_child(ElixirDownloadManager.Supervisor, Manager)
        Supervisor.delete_child(ElixirDownloadManager.Supervisor, Manager)

        # create the new child
        Supervisor.start_child(
            ElixirDownloadManager.Supervisor,
            worker(
                Manager,
                [self, url],
                id: inspect(:random.uniform)
            )
        )
    end

    def start_download do
        Enum.map(
            Supervisor.which_children(ElixirDownloadManager.Supervisor),
            fn {_, pid, _, _} ->  Manager.start_download(pid) end
        )
    end

end
