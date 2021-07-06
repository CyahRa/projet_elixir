defmodule Bebemayotte.PanierRequette do
  import Ecto.Query, warn: false
  alias Bebemayotte.Panier
  alias Bebemayotte.Repo

  # INSERT IN TABLE PANIER
  def insert_panier(params) do
    %Panier{}
      |>Panier.changeset(params)
      |>Repo.insert()
  end

  # GET PANIER
  def get_all_panier() do
    Repo.all(Panier)
  end

  # GET PANIER BY ID
  def get_panier_by_id(id) do
    query =
      from pa in Panier,
        where: pa.id_panier == ^id,
        select: pa
    Repo.one(query)
  end

  # GET ID PRODUIT IN PANIER
  def get_id_produit_in_panier() do
    query =
      from pa in Panier,
        select: pa.id_produit
    Repo.all(query)
  end

  # GET QUANTITE IN PANIER
  def get_quantite_in_panier(id_produit, id_session) do
    query =
      from pa in Panier,
        where: pa.id_produit == ^id_produit and pa.id_user == ^id_session,
        select: pa.quantite
    Repo.one(query)
  end

  # GET PANIER BY ID PRODUIT AND ID SESSION
  def get_panier_by_id_produit_id_session(id_produit, id_session) do
    query =
      from pa in Panier,
        where: pa.id_produit == ^id_produit and pa.id_user == ^id_session,
        select: pa
    Repo.one(query)
  end

  # DELETE PANIER
  def delete_panier_query(panier) do
    Repo.delete(panier)
  end

  # UPDATE PANIER
  def update_panier_query(panier, params) do
    panier
      |>Panier.changeset(params)
      |>Repo.update()
  end

  # NUMBER OF LINE
  def line_panier() do
    query =
      from pa in Panier,
        select: count(pa.id)
    Repo.one(query)
  end

  # LAST ROW ID
  def get_panier_last_row_id() do
    query =
      from p in Panier,
        limit: 1,
        order_by: [desc: p.id_panier],
        select: p.id_panier
    id = Repo.one(query)
    case is_nil(id) do
      true -> 1
      false -> id + 1
    end
  end

  # FIND A DOUBLE
  def find_double_in_panier(id_produit, id_user) do
    query =
      from pa in Panier,
        where: pa.id_produit == ^id_produit and pa.id_user == ^id_user,
        select: pa.id_panier
    id = Repo.one(query)
    if id == nil do
      true
    else
      false
    end
  end
end
