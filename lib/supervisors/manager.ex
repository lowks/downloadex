import Logger
import Supervisor.Spec

defmodule Manager do
    use Supervisor

    @max_part_size 3_000_000 # bytes


    def start_link(receiver, url, range) do
        Supervisor.start_link(__MODULE__, [receiver, url, range])
    end


    def init [receiver, url, range = first..last] do
        info "Starting #{inspect __MODULE__}"
        if (last - first > @max_part_size) do
            info "#{inspect self} Start 2 more receiver children."
            max = first + div(last - first, 2)

            left_id  = Integer.to_string(first)   <> "_" <> Integer.to_string(max)
            right_id = Integer.to_string(max + 1) <> "_" <> Integer.to_string(last)
            children = [
                supervisor(Receiver, [receiver, url, first..max],      [name: :left,  id: left_id]),
                supervisor(Receiver, [receiver, url, (max + 1)..last], [name: :right, id: right_id])
            ]
        else
            info "#{inspect self} Start 1 client child."
            children = [
                worker(Client, [receiver, url, range])
            ]
        end
        supervise(children, [strategy: :one_for_one])
    end

end
