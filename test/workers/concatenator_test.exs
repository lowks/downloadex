defmodule ConcatenatorTest do
  use ExUnit.Case


  def cwd!, do: Path.join([System.cwd!, "test", "workers"])


  test "adding duplicate chunks" do

    file1 = Path.join(cwd!, "1.tmp")
    file2 = Path.join(cwd!, "2.tmp")
    targetFile = Path.join(cwd!, "target")

    Concatenator.start_link targetFile

    Concatenator.add_chunk 5..6, file1

    File.write!(file2, "12347890", [:exclusive])
    %File.Stat{size: sizeFile2}  = File.stat!(file2)

    Concatenator.add_chunk 5..6, file2

    assert [file2] == Concatenator.concatenate_and_delete_chunks
    %File.Stat{size: sizeTarget} = File.stat!(targetFile)
    File.rm! targetFile

    assert sizeFile2 == sizeTarget
  end


  test "adding chunks in reverse" do
    Concatenator.start_link Path.join(cwd!, "target2")

    File.touch! Path.join(cwd!, "1.tmp")
    Concatenator.add_chunk 5..6, Path.join(cwd!, "1.tmp")

    File.touch! Path.join(cwd!, "2.tmp")
    Concatenator.add_chunk 3..4, Path.join(cwd!, "2.tmp")

    File.touch! Path.join(cwd!, "3.tmp")
    Concatenator.add_chunk 1..2, Path.join(cwd!, "3.tmp")
    assert [
      Path.join(cwd!, "3.tmp"),
      Path.join(cwd!, "2.tmp"),
      Path.join(cwd!, "1.tmp")
    ] == Concatenator.concatenate_and_delete_chunks
    File.rm! Path.join(cwd!, "target2")
  end

end
