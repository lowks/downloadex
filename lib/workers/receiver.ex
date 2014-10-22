import Logger

defmodule Receiver do
    use ExActor.Strict


    defstart start_link(parent, url, range) do
        debug "#{inspect self}: Initializing receiver in range #{inspect range} with URL #{url}"
        initial_state %StateData{
            parent: parent,
            url: url,
            range: range,
            manager: Manager.start_link(self, url, range)
        }
    end


    defcast finish_download(frange = ffirst..flast),
        state: state = %StateData{parent: parent, range: range = first..last, progress: progress} do

        new_progress = case progress do
            0 -> progress + flast - ffirst
            _ -> progress + flast - ffirst + 1
        end

        cond do
            new_progress < last - first ->
                info "#{inspect self}: Chunk #{inspect range} not completed yet, missing #{inspect last - first - new_progress} bytes"
            parent ->
                info "#{inspect self}: Chunk #{inspect range} completed"
                Receiver.finish_download(parent, range)
            true ->
                warn "#{inspect self}: No parent found for #{inspect self}, download completed."
        end

        new_state %{state | progress: new_progress}
    end

end
