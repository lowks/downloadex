defmodule RedisConcatenator do
    use ExActor.Strict, export: :Concatenator


    defstart start_link(target, url, redis_connection_string),
        when: is_binary(target),
        do: initial_state {target, url, redis_connection_string}


    defcast add_chunk(_, _) do
        noreply
    end


    defcall concatenate_and_delete_chunks, state: {target, url, redis_connection_string} do
        {:ok, f} = File.stream!(target, [:exclusive]) |> Collectable.into
        RedisWrapper.get(redis_connection_string, url) |> Enum.each(fn l -> f.(:ok, {:cont, l}) end)
        f.(:ok, :done)
        IO.puts "Downloaded file was saved to location \"#{target}\"."
        RedisWrapper.delete(redis_connection_string, url)
        reply :ok
    end
end
