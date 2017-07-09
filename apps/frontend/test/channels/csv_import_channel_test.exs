defmodule Frontend.CsvImportChannelTest do
  use Frontend.ChannelCase
  alias Frontend.CityImportChannel

  test "works" do
    {:ok, _, _socket} = socket("", %{})
    |> subscribe_and_join(CityImportChannel, "background_job")
  end
end
