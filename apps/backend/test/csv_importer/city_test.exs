defmodule Backend.CityTest do
  use DbCase
  alias Backend.{City, Repo}

  test "inserts a valid record" do
    changeset = City.changeset(%City{}, %{name: "Natal", url: "http://natal.com"})

    assert {:ok, _} = Repo.insert(changeset)
  end

  test "does insert when name is missing" do
    changeset = City.changeset(%City{}, %{name: nil, url: "http://natal.com"})

    assert {:error, changeset} = Repo.insert(changeset)
    assert {"can't be blank", _} = changeset.errors[:name]
  end
end
