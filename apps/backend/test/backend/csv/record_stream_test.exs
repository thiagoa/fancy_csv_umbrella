defmodule Backend.Csv.RecordStreamTest do
  use ExUnit.Case
  alias Backend.City
  alias Backend.Csv.{RecordStream, Format}

  setup do
    {:ok, format: %Format{headers: ~w(name url)a, type: City}}
  end

  test "streams an empty collection when csv has no data lines", %{format: format} do
    {:ok, file_handler} = StringIO.open("name,url\n")
    {:ok, stream} = RecordStream.create(file_handler, format)

    assert [] == Enum.to_list(stream)
  end

  test "streams records from a csv file", %{format: format} do
    {:ok, file_handler} = StringIO.open """
    name,url
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    New York,http://newyork.org
    """
    {:ok, stream} = RecordStream.create(file_handler, format)

    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = Enum.to_list(stream)
  end

  test "streams the right contents when headers are switched out", %{format: format} do
    {:ok, file_handler} = StringIO.open """
    url,name
    http://madrid.com,Madrid
    http://natal.com.br,Natal
    http://newyork.org,New York
    """
    {:ok, stream} = RecordStream.create(file_handler, format)

    assert [
      %City{name: "Madrid", url: "http://madrid.com"},
      %City{name: "Natal", url: "http://natal.com.br"},
      %City{name: "New York", url: "http://newyork.org"}
    ] = Enum.to_list(stream)
  end

  test "returns invalid_csv when one of the columns is missing", %{format: format} do
    {:ok, file_handler} = StringIO.open """
    name
    Madrid
    Natal
    """

    assert :invalid_csv == RecordStream.create(file_handler, format)
  end

  test "returns invalid_csv when one of the columns has wrong name", %{format: format} do
    {:ok, file_handler} = StringIO.open """
    name,urls
    Madrid,http://madrid.com
    Natal,http://natal.com.br
    """

    assert :invalid_csv == RecordStream.create(file_handler, format)
  end
end
