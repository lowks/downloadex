defmodule ConcatenatorTest do
  use ExUnit.Case


  def cwd!, do: Path.join([System.cwd!, "test", "workers"])


  test "adding duplicate chunks" do
    File.rm Path.join(cwd!, "target1")
    Concatenator.start_link Path.join(cwd!, "target1")
    Concatenator.add_chunk 5..6, Path.join(cwd!, "1.tmp")
    Concatenator.add_chunk 5..6, Path.join(cwd!, "2.tmp")
    assert [Path.join(cwd!, "2.tmp")] == Concatenator.concatenate_and_delete_chunks
    File.rm! Path.join(cwd!, "target1")
  end


  test "adding chunks in reverse" do
    File.rm Path.join(cwd!, "target2")
    Concatenator.start_link Path.join(cwd!, "target2")
    Concatenator.add_chunk 5..6, Path.join(cwd!, "1.tmp")
    Concatenator.add_chunk 3..4, Path.join(cwd!, "2.tmp")
    Concatenator.add_chunk 1..2, Path.join(cwd!, "3.tmp")
    assert [Path.join(cwd!, "3.tmp"), Path.join(cwd!, "2.tmp"), Path.join(cwd!, "1.tmp")] == Concatenator.concatenate_and_delete_chunks
    File.rm! Path.join(cwd!, "target2")
  end

end
