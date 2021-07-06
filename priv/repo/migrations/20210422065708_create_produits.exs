defmodule Bebemayotte.Repo.Migrations.CreateProduits do
  use Ecto.Migration

  def change do
    create table(:produits) do
      add :id_produit, :string
      add :title, :string
      add :photolink, :string
      add :id_cat, :string
      add :id_souscat, :string
      add :stockstatus, :boolean, default: false, null: false
      add :stockmax, :decimal
      add :price, :decimal
      add :id_user, :integer

    end

  end
end
