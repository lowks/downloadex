defmodule FileConcatenatorTest do
  use ExUnit.Case


  def cwd!, do: Path.join([System.cwd!, "test", "workers"])


  test "adding duplicate chunks" do
    file1 = Path.join(cwd!, "1.tmp")
    file2 = Path.join(cwd!, "2.tmp")
    targetFile = Path.join(cwd!, "target")

    FileConcatenator.start_link targetFile

    FileConcatenator.add_chunk 5..6, file1

    File.write!(file2, "12347890", [:exclusive])
    %File.Stat{size: sizeFile2}  = File.stat!(file2)

    FileConcatenator.add_chunk 5..6, file2

    assert [file2] == FileConcatenator.concatenate_and_delete_chunks
    %File.Stat{size: sizeTarget} = File.stat!(targetFile)
    File.rm! targetFile

    assert sizeFile2 == sizeTarget
  end


  test "adding chunks in reverse" do
    FileConcatenator.start_link Path.join(cwd!, "target2")

    File.touch! Path.join(cwd!, "1.tmp")
    FileConcatenator.add_chunk 5..6, Path.join(cwd!, "1.tmp")

    File.touch! Path.join(cwd!, "2.tmp")
    FileConcatenator.add_chunk 3..4, Path.join(cwd!, "2.tmp")

    File.touch! Path.join(cwd!, "3.tmp")
    FileConcatenator.add_chunk 1..2, Path.join(cwd!, "3.tmp")
    assert [
      Path.join(cwd!, "3.tmp"),
      Path.join(cwd!, "2.tmp"),
      Path.join(cwd!, "1.tmp")
    ] == FileConcatenator.concatenate_and_delete_chunks
    File.rm! Path.join(cwd!, "target2")
  end

end
