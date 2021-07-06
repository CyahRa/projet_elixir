defmodule Bebemayotte.Fonction do
  import Ecto.Query, warn: false
  alias Bebemayotte.Produit
  alias Bebemayotte.Repo

  def fn_(field) do
    if String.contains?(field, "CHAUSSURES"), do: true, else: false
  end
end
