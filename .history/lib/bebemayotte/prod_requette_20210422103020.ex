defmodule Bebemayotte.ProdRequette do
  import Ecto.Query, warn: false
  alias Bebemayotte.Produit
  alias Bbemayotte.Repo

  # GET ALL PRODUIT
  def get_all_produit() do
    Repo.all(Produit)
  end

end
