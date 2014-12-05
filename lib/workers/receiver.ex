defmodule Receiver do
    use ExActor.Strict

    import Logger


    defstart start_link(parent, url, range), do:
        initial_state %StateData{
            parent: parent,
            url: url,
            range: range,
            manager: Manager.start_link(self, url, range)
        }


    defcast update_status(frange = ffirst..flast),
        state: state = %StateData{range: range = first..last, parent: parent, progress: progress} do

        new_progress = progress + flast - ffirst
        new_progress = case progress do
            0 -> new_progress
            _ -> new_progress + 1
        end

        delta = round(IEx.width * (new_progress - progress) / (last - first))
        case parent do
            nil -> IO.write String.ljust("", delta, ?▓)
            _   -> Receiver.update_status(parent, frange)
        end

        new_state %{state | progress: new_progress}
    end


    defcast finish_download(frange = ffirst..flast, file \\ nil),
        state: state = %StateData{parent: parent, range: range = first..last, progress: progress} do

        new_progress = progress + flast - ffirst
        new_progress = case progress do
            0 -> new_progress
            _ -> new_progress + 1
        end

        if file do
            Concatenator.add_chunk(range, file)
        end

        if parent do
            Receiver.update_status(parent, frange)
        end

        cond do
            new_progress < last - first ->
                debug "Missing #{inspect last - first - new_progress} bytes of range #{inspect range}" 
            parent ->
                info "Range #{inspect range} saved to file #{file}."
                Receiver.finish_download(parent, range)
            true ->
                IO.puts ""
                IO.puts "Download completed."
                Concatenator.concatenate_and_delete_chunks
                DownloadEx.stop_download
        end

        new_state %{state | progress: new_progress}
    end

end
