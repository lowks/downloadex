import Logger

defmodule Receiver do
    use ExActor.Strict


    defstart start_link(parent, url, range), do:
        initial_state %StateData{
            parent: parent,
            url: url,
            range: range,
            manager: Manager.start_link(self, url, range)
        }


    defcast finish_download(frange = ffirst..flast),
        state: state = %StateData{parent: parent, range: range = first..last, progress: progress} do

        new_progress = progress + flast - ffirst
        new_progress = case progress do
            0 -> new_progress
            _ -> new_progress + 1
        end

        cond do
            new_progress < last - first ->
                debug "Missing #{inspect last - first - new_progress} bytes of range #{inspect range}"
            parent ->
                info "Range #{inspect range} completed."
                Receiver.finish_download(parent, range)
            true ->
                IO.puts "Download completed."
                DownloadEx.stop_download
        end

        new_state %{state | progress: new_progress}
    end

end
