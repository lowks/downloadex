defimpl Inspect, for: HTTPoison.AsyncHeaders do
    def inspect(%HTTPoison.AsyncHeaders{id: id, headers: headers}, _) do
        max_key_length = Enum.max(
            Enum.map(
                Dict.to_list(headers),
                fn {k, _} -> String.length(inspect(k)) end
            )
        )
        """
        #HTTPotion.AsyncHeaders<
            #{inspect id}
            #{Enum.reduce(
                Dict.to_list(headers),
                "",
                fn ({a, b}, acc) -> String.rjust(
                    "#{acc}\n    #{String.ljust(inspect(a), max_key_length)} #{inspect(b)}",
                    4)
                end
            )}
        >
        """
    end
end

defimpl Inspect, for: HTTPoison.AsyncChunk do
    def inspect(%HTTPoison.AsyncChunk{id: id, chunk: chunk}, _) do
        """
        #HTTPotion.AsyncChunk<
            #{inspect id}
            "#{String.slice(chunk, 0, 50)}…"
        >
        """
    end
end

defimpl Inspect, for: HTTPoison.AsyncEnd do
    def inspect(%HTTPoison.AsyncEnd{id: id}, _) do
        """
        #HTTPotion.AsyncEnd<#{inspect id}>
        """
    end
end
