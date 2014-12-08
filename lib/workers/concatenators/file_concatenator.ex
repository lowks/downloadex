defmodule FileConcatenator do
    use ExActor.Strict, export: :Concatenator


    defstart start_link(target),
        when: is_binary(target),
        do: initial_state {target, HashDict.new}


    defcast add_chunk(range, file), state: {target, dict} do
        new_state {target, Dict.put(dict, range, file)}
    end


    defcall concatenate_and_delete_chunks, state: {target, dict} do
        ordered_files = Dict.keys(dict) |> Enum.sort |> Enum.map &Dict.get(dict, &1)

        {:ok, f} = File.stream!(target, [:exclusive]) |> Collectable.into
        Stream.map(ordered_files, &File.stream!(&1)) |> Stream.concat |> Stream.each(fn l -> f.(:ok, {:cont, l}) end)
            |> Stream.run
        f.(:ok, :done)
        IO.puts "Downloaded file was saved to location \"#{target}\"."

        ordered_files |> Enum.each &File.rm!(&1)

        reply ordered_files
    end
end
