defmodule Bebemayotte.ProdRequette do
  import Ecto.Query, warn: false
  alias Bebemayotte.Produit
  alias Bebemayotte.Repo

  # GET ALL PRODUIT
  def get_all_produit() do
    query =
      from p in Produit,
        where: p.stockstatus == true,
        select: p
    Repo.all(query)
  end

  # GET PRODUIT WITH CATEGORIE
  def get_produit_by_categorie(id_cat) do
    query =
      from p in Produit,
        where: p.id_cat == ^id_cat,
        select: p
    Repo.all(query)
  end

  # GET PRODUIT WITH CATEGORIE AND SOUSCATEGORIE
  def get_produit_by_categorie_and_souscategorie(id_cat, id_souscat) do
    query =
      from p in Produit,
        where: p.id_cat == ^id_cat and p.id_souscat == ^id_souscat,
        select: p
    Repo.all(query)
  end

  # GET PRODUIT BY ID_PRODUIT
  def get_produit_by_id_produit(id_produit) do
    query =
      from p in Produit,
        where: p.id_produit == ^id_produit,
        select: p
    Repo.one(query)
  end

  # GET PRODUIT BY LIST ID PRODUIT FROM PANIER
  def get_produit_from_id_produit_panier(list_id_produit) do
    query =
      from p in Produit,
        where: p.id_produit in ^list_id_produit,
        select: p
    Repo.all(query)
  end

  # SOMME DES PRIX DANS PANIER
  def get_price_in_produit(params) do
    query =
      from p in Produit,
        where: p.id_produit == ^params,
        select: p.price
    Repo.one(query)
  end

  # GET PRODUIT APPARENTES
  def get_produit_apparentes(id_souscat,id) do
    query =
      from p in Produit,
        where: p.id_souscat ==^id_souscat and p.id_produit != ^id,
        select: p,
        limit: 3
    Repo.all(query)
  end

  # COUNT LIGNE
  def count_ligne_produit() do
    query =
      from p in Produit,
        select: count(p.id_produit)
    Repo.one(query)
  end

  # GET 12 PRODUITS
  def get_produit_limit_twelve() do
    query =
      from p in Produit,
        select: p,
        limit: 20,
        order_by: [asc: p.id_produit]
    Repo.all(query)
  end

  # GET 12 PRODUITS FROM ID
  def get_produit_limit_twelve_from_id_next(id_produit) do
    query =
      from p in Produit,
        where: p.id_produit >= ^id_produit,
        select: p,
        limit: 20,
        order_by: [asc: p.id_produit]
    Repo.all(query)
  end

  # GET 12 PRODUITS FROM ID
  def get_produit_limit_twelve_from_id_prev(id_produit) do
    query =
      from p in Produit,
        where: p.id_produit <= ^id_produit,
        select: p,
        limit: 20,
        order_by: [desc: p.id_produit]
    Repo.all(query)
  end

  # CATEGORIE
  # COUNT LIGNE
  def count_ligne_produit_categorie(id_cat) do
    query =
      from p in Produit,
        where: p.id_cat == ^id_cat,
        select: count(p.id_produit)
    Repo.one(query)
  end

  # GET 12 PRODUITS
  def get_produit_limit_twelve_categorie(id_cat) do
    query =
      from p in Produit,
        where: p.id_cat == ^id_cat,
        select: p,
        limit: 20,
        order_by: [asc: p.id_produit]
    Repo.all(query)
  end

  # GET 12 PRODUITS FROM ID
  def get_produit_limit_twelve_from_id_next_categorie(id_produit, id_cat) do
    query =
      from p in Produit,
        where: p.id_produit >= ^id_produit and p.id_cat == ^id_cat,
        select: p,
        limit: 20,
        order_by: [asc: p.id_produit]
    Repo.all(query)
  end

  # GET 12 PRODUITS FROM ID
  def get_produit_limit_twelve_from_id_prev_categorie(id_produit, id_cat) do
    query =
      from p in Produit,
        where: p.id_produit <= ^id_produit and p.id_cat == ^id_cat,
        select: p,
        limit: 20,
        order_by: [desc: p.id_produit]
    Repo.all(query)
  end

  # SOUSCATEGORIE
  # COUNT LIGNE
  def count_ligne_produit_souscategorie(id_souscat) do
    query =
      from p in Produit,
        where: p.id_souscat == ^id_souscat,
        select: count(p.id_produit)
    Repo.one(query)
  end

  # GET 12 PRODUITS
  def get_produit_limit_twelve_souscategorie(id_souscat) do
    query =
      from p in Produit,
        where: p.id_souscat == ^id_souscat,
        select: p,
        limit: 20,
        order_by: [asc: p.id_produit]
    Repo.all(query)
  end

  # GET 12 PRODUITS FROM ID
  def get_produit_limit_twelve_from_id_next_souscategorie(id_produit, id_souscat) do
    query =
      from p in Produit,
        where: p.id_produit >= ^id_produit and p.id_souscat == ^id_souscat,
        select: p,
        limit: 20,
        order_by: [asc: p.id_produit]
    Repo.all(query)
  end

  # GET 12 PRODUITS FROM ID
  def get_produit_limit_twelve_from_id_prev_souscategorie(id_produit, id_souscat) do
    query =
      from p in Produit,
        where: p.id_produit <= ^id_produit and p.id_souscat == ^id_souscat,
        select: p,
        limit: 20,
        order_by: [desc: p.id_produit]
    Repo.all(query)
  end

  # SEARCH
    def get_produit_title_and_id_produit() do
      query =
          from p in Produit,
            select: [p.title, p.id_produit]
      Repo.all(query)
    end

    def get_produit_from_list_id_produit(list_id_produit) do
      query =
        from p in Produit,
          where: p.id_produit in ^list_id_produit,
          select: p,
          limit: 20,
          order_by: [asc: p.id_produit]
      Repo.all(query)
    end

    def get_produit_limit_twelve_from_id_next_search(id_produit, list_id_produit) do
      query =
        from p in Produit,
          where: p.id_produit >= ^id_produit and p.id_produit in ^list_id_produit,
          select: p,
          limit: 20,
          order_by: [asc: p.id_produit]
      Repo.all(query)
    end

    def get_produit_limit_twelve_from_id_prev_search(id_produit, list_id_produit) do
      query =
        from p in Produit,
          where: p.id_produit <= ^id_produit and p.id_produit in ^list_id_produit,
          select: p,
          limit: 20,
          order_by: [desc: p.id_produit]
      Repo.all(query)
    end

    def count_ligne_produit_search(list_id_produit) do
      query =
        from p in Produit,
          where: p.id_produit in ^list_id_produit,
          select: count(p.id_produit)
      Repo.one(query)
    end
end
