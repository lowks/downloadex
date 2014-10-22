defimpl Inspect, for: HTTPotion.AsyncHeaders do
    def inspect(%HTTPotion.AsyncHeaders{id: id, status_code: status_code, headers: headers}, _) do
        headers = ["HTTP status code": status_code] ++ headers
        headers = ["ID": inspect id] ++ headers
        max_key_length = Enum.max(
            Enum.map(
                Dict.to_list(headers),
                fn {k, _} -> String.length(inspect(k)) end
            )
        )
        """
        #HTTPotion.AsyncHeaders<#{Enum.reduce(
            Dict.to_list(headers),
            "",
            fn ({a, b}, acc) -> String.rjust(
                "#{acc}\n    #{String.ljust(inspect(a), max_key_length)} #{b}",
                4)
            end
        )}
        >
        """
    end
end

defimpl Inspect, for: HTTPotion.AsyncChunk do
    def inspect(%HTTPotion.AsyncChunk{id: id, chunk: chunk}, _) do
        """
        #HTTPotion.AsyncChunk<
            #{inspect id}
            "#{String.slice(chunk, 0, 100)}…"
        >
        """
    end
end

defimpl Inspect, for: HTTPotion.AsyncEnd do
    def inspect(%HTTPotion.AsyncEnd{id: id}, _) do
        """
        #HTTPotion.AsyncEnd<#{inspect id}>
        """
    end
end
