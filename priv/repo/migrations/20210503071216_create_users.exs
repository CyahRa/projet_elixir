defmodule Bebemayotte.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :id_user, :integer
      add :nom, :string
      add :prenom, :string
      add :nom_affiche, :string
      add :nom_rue, :string
      add :batiment, :string
      add :pays, :string
      add :ville, :string
      add :identifiant, :string
      add :adresseMessage, :string
      add :codepostal, :string
      add :telephone, :string
      add :motdepasse, :string
      add :nom_entreprise, :string


    end

    create unique_index(:users, [:id_user])
    create unique_index(:users, [:telephone])
  end
end
