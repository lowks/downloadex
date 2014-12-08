defmodule RedisConcatenatorTest do
  use ExUnit.Case


  def cwd!, do: Path.join([System.cwd!, "test", "workers"])


  test "adding duplicate chunks" do
    targetFile = Path.join(cwd!, "10MB.zip")
    url = "http://www.wswd.net/testdownloadfiles/10MB.zip"
    redis_connection_string = "redis://127.0.0.1:6379"

    RedisConcatenator.start_link targetFile, url, redis_connection_string

    RedisWrapper.set(redis_connection_string, url, 5..6, "old")
    RedisWrapper.set(redis_connection_string, url, 5..6, "")

    assert :ok == RedisConcatenator.concatenate_and_delete_chunks
    %File.Stat{size: sizeTarget} = File.stat!(targetFile)
    File.rm! targetFile

    assert 3 == sizeTarget
  end

end
