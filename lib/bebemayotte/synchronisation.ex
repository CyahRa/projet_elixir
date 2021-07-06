defmodule Bebemayotte.Synchronisation do
  use Task
  import Ecto.Query, warn: false
  alias Bebemayotte.Produit
  alias Bebemayotte.Categorie
  alias Bebemayotte.Souscategorie

  alias Bebemayotte.Repo
  alias Bebemayotte.EBPRepo

  # alias Bebemayotte.SouscatRequette
  # alias Bebemayotte.CatRequette

  def start_link(_arg) do
    Task.start_link(&synchro/0)
  end

  defp condition(x) do
    if x == 0, do: false, else: true
  end

  defp encodage(x, x_id) do
    if x != nil, do: Base.encode64(x), else: "#{x_id}-0.JPG"
  end
  def export_from_ebp() do
    {:ok, base} = Ecto.Adapters.SQL.query(EBPRepo,"SELECT Id, Caption, FamilyId, SubFamilyId, CostPrice, ItemImage FROM Item")

    for i <- base.rows do
      {:ok, id} = Enum.fetch(i, 0)
      {:ok, caption} = Enum.fetch(i, 1)
      {:ok, familyId} = Enum.fetch(i, 2)
      {:ok, subFamilyId} = Enum.fetch(i, 3)
      {:ok, costprice} = Enum.fetch(i, 4)
      {:ok, tmpImg} = Enum.fetch(i, 5)

      img = encodage(tmpImg, id)

      {:ok, stock} = Ecto.Adapters.SQL.query(EBPRepo,"SELECT ItemId, RealStock FROM StockItem WHERE ItemId= '#{id}'")
      for st <- stock.rows do
        {:ok, stocke} = Enum.fetch(st, 1)
        stocke = Decimal.to_integer(stocke)
        s = condition(stocke)

        params = %{
          "id_produit" => id,
          "title" => caption,
          "photolink" => img,
          "stockstatus" => s,
          "stockmax" => stocke,
          "price" => costprice,
          "id_user" => 1,
          "id_cat" => familyId,
          "id_souscat" => subFamilyId
        }

        id_prod = Repo.one(from p in Produit, where: p.id_produit == ^id, select: p.id_produit)

        if id_prod == nil do
          %Produit{}
            |>Produit.changeset(params)
            |>Repo.insert()
        else
          produit = Repo.one(from p in Produit, where: p.id_produit == ^id_prod, select: p)
          produit
            |>Produit.changeset(params)
            |>Repo.update()
        end
      end
    end
  end

  # CATEGORIE
  def export_categorie() do
    {:ok, categorie} = Ecto.Adapters.SQL.query(EBPRepo,"SELECT Id, Caption FROM ItemFamily")

    for c <- categorie.rows do
      {:ok, familyid} = Enum.fetch(c, 0)
      {:ok, nom} = Enum.fetch(c, 1)

      params = %{
        "id_cat" => familyid,
        "nom_cat" => nom
      }

      id = Repo.one(from c in Categorie, where: c.id_cat == ^familyid, select: c.id_cat)

      if id == nil do
        %Categorie{}
          |> Categorie.changeset(params)
          |> Repo.insert()
      else
        cat = Repo.one(from c in Categorie, where: c.id_cat == ^id, select: c)
        cat
          |> Categorie.changeset(params)
          |> Repo.update()
      end
    end
  end

  # SOUSCATEGORIE
  def export_souscategorie() do
    {:ok, souscategorie} = Ecto.Adapters.SQL.query(EBPRepo,"SELECT Id, Caption, ItemFamilyId FROM ItemSubFamily")

    for sc <- souscategorie.rows do
      {:ok, subfamilyid} = Enum.fetch(sc, 0)
      {:ok, nom} = Enum.fetch(sc, 1)
      {:ok, familyid} = Enum.fetch(sc, 2)

      params = %{
        "id_souscat" => subfamilyid,
        "nom_souscat" => nom,
        "id_cat" => familyid
      }

      id = Repo.one(from sc in Souscategorie, where: sc.id_souscat == ^subfamilyid, select: sc.id_souscat)

      if id == nil do
        %Souscategorie{}
          |> Souscategorie.changeset(params)
          |> Repo.insert()
      else
        souscat = Repo.one(from sc in Souscategorie, where: sc.id_souscat == ^id, select: sc)
        souscat
          |> Souscategorie.changeset(params)
          |> Repo.update()
      end

    end
  end

  # DELETE
  defp query_select(obj, line) do
    case obj do
      Categorie -> "SELECT Id FROM ItemFamily WHERE Id = '#{line}'"
      Souscategorie -> "SELECT Id FROM ItemSubFamily WHERE Id = '#{line}'"
      Produit -> "SELECT Id FROM Item WHERE Id = '#{line}'"
    end
  end

  defp query_id(obj) do
    case obj do
      Categorie -> Repo.all(from c in Categorie, select: c.id_cat)
      Souscategorie -> Repo.all(from sc in Souscategorie, select: sc.id_souscat)
      Produit -> Repo.all(from p in Produit, select: p.id_produit)
    end
  end

  defp query_one(obj, line) do
    case obj do
      Categorie -> Repo.one(from c in Categorie, where: c.id_cat == ^line, select: c)
      Souscategorie -> Repo.one(from sc in Souscategorie, where: sc.id_souscat == ^line, select: sc)
      Produit -> Repo.one(from p in Produit, where: p.id_produit == ^line, select: p)
    end
  end

  def delete_data(obj) do
    lines = query_id(obj)
    for line <- lines do
      obj_delete = query_one(obj,line)
      {:ok, id_prod} = EBPRepo.query(query_select(obj, line))
      if id_prod.num_rows == 0 do
        Repo.delete(obj_delete)
      end
    end
  end

  def synchro() do
    receive do
      after
        60_000 ->
          # delete_data(Produit)
          # delete_data(Categorie)
          # delete_data(Souscategorie)
          # export_from_ebp()
          # export_categorie()
          # export_souscategorie()
          synchro()
    end
  end
end
