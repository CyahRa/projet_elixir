defmodule BebemayotteWeb.CompteController do
  use BebemayotteWeb, :controller
  alias Bebemayotte.CatRequette
  alias Bebemayotte.UserRequette

  # GET PRINCIPAL PAGE
  def compte(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"compte.html", user: user, categories: categories, search: nil)
    end
  end

  # GET COMMAND PAGE
  def commandes(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"commandes.html", user: user, categories: categories, search: nil)
    end
  end

  # GET DOWNLOAD PAGE
  def down(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"down.html", user: user, categories: categories, search: nil)
    end
  end

  # GET DETAIL PAGE
  def detail(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"detail.html", categories: categories, user: user, search: nil)
    end
  end

  # GET ADDRESS PAGE
  def adresse(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"adresse.html", user: user, categories: categories, search: nil)
    end
  end

  # FUNCTION
  defp for_update(char, new_c, bd_c, u) do
    if new_c != "" and new_c != bd_c do
      params = %{
        "#{char}" => new_c
      }
      UserRequette.update_user_query(u, params)
    end
  end

  # UPDATE COMPTE
  def update_account(conn, %{
    "prenom" => prenom,
    "nom" => nom,
    "nom_affiche" => nom_affiche,
    "adresseMessage" => adresseMessage,
    "motdepasse_actuel" => motdepasse_actuel,
    "motdepasse_new" => motdepasse_new,
    "motdepasse_new_confirm" => motdepasse_new_confirm
  }) do

    id = Plug.Conn.get_session(conn, :user_id)
    user = UserRequette.get_user_by_id(id)

    for_update("prenom", prenom, user.prenom, user)
    for_update("nom", nom, user.nom, user)
    for_update("nom_affiche", nom_affiche, user.nom_affiche, user)
    for_update("adresseMessage", adresseMessage, user.adresseMessage, user)

    if motdepasse_actuel != user.motdepasse do
      conn
        |>put_flash(:mdp_error, "Mot de passe éronné!")
        |>redirect(to: "/detail")
    else
      if motdepasse_new == user.motdepasse do
        conn
          |>put_flash(:mdp_error, "Mot de passe semblable à l'ancien!")
          |>redirect(to: "/detail")
      else
        if motdepasse_new != motdepasse_new_confirm do
          conn
            |>put_flash(:mdp_error, "Mot de passe non confirmé, le nouveau!")
            |>redirect(to: "/detail")
        else
          params = %{
            "motdepasse" => motdepasse_new
          }
          UserRequette.update_user_query(user, params)
        end
      end
    end

    conn
      |>put_flash(:info_update, "Mise à jour réussi!")
      |>redirect(to: "/detail")
  end

  # DECONNEXION
  def deconnexion(conn, %{"hidden" => hidden}) do
    IO.puts hidden
    conn
      |>configure_session(drop: true)
      |>redirect(to: "/connexion")
  end

  #------------------------------------------------------------------------------COMMAND-----------------------------------------------------------------------------------

  # SEE MY COMMAND
  def see_command(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"voir.html", user: user, categories: categories, search: nil)
    end
  end

  # PAY COMMAND
  def pay_command(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"payer.html", user: user, categories: categories, search: nil)
    end
  end

  # CONFIDENTIALITY POLITIC
  def politique(conn,_params) do
    categories = CatRequette.get_all_categorie()

    render(conn,"politique.html", categories: categories, search: nil)
  end

  # GET PAGE FACTURATION
  def update_facturation(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"modifier.html", user: user, categories: categories, search: nil)
    end
  end

  # SUBMIT "UPDATE FACTURATION"
  def submit_update_facturation(conn, %{
    "prenom" => prenom,
    "nom" => nom,
    "nom_entreprise" => nom_entreprise,
    "nom_rue" => nom_rue,
    "batiment" => batiment,
    "ville" => ville,
    "codepostal" => codepostal,
    "telephone" => telephone,
    "adresseMessage" => adresseMessage
  }) do
    id = Plug.Conn.get_session(conn, :user_id)
    user = UserRequette.get_user_by_id(id)
    tel = Integer.to_string(telephone)

    for_update("prenom", prenom, user.prenom, user)
    for_update("nom", nom, user.nom, user)
    for_update("nom_entreprise", nom_entreprise, user.nom_entreprise, user)
    for_update("nom_rue", nom_rue, user.nom_rue, user)
    for_update("batiment", batiment, user.batiment, user)
    for_update("ville", ville, user.ville, user)
    for_update("codepostal", codepostal, user.codepostal, user)
    for_update("telephone", tel, user.telephone, user)
    for_update("adresseMessage", adresseMessage, user.adresseMessage, user)

    conn
      |>put_flash(:info_update, "Mise à jour réussi!")
      |>redirect(to: "/update_address/facturation")
  end

  # GET PAGE LIVRAISON
  def update_livraison(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    categories = CatRequette.get_all_categorie()

    if is_nil(id) do
      redirect(conn, to: "/connexion")
    else
      user = UserRequette.get_user_by_id(id)
      render(conn,"modification.html", user: user, categories: categories, search: nil)
    end
  end

  # SUBMIT "UPDATE FACTURATION"
  def submit_update_livraison(conn, %{
    "prenom" => prenom,
    "nom" => nom,
    "nom_entreprise" => nom_entreprise,
    "nom_rue" => nom_rue,
    "batiment" => batiment,
    "ville" => ville,
    "codepostal" => codepostal
  }) do
    id = Plug.Conn.get_session(conn, :user_id)
    user = UserRequette.get_user_by_id(id)

    for_update("prenom", prenom, user.prenom, user)
    for_update("nom", nom, user.nom, user)
    for_update("nom_entreprise", nom_entreprise, user.nom_entreprise, user)
    for_update("nom_rue", nom_rue, user.nom_rue, user)
    for_update("batiment", batiment, user.batiment, user)
    for_update("ville", ville, user.ville, user)
    for_update("codepostal", codepostal, user.codepostal, user)

    conn
      |>put_flash(:info_update, "Mise à jour réussi!")
      |>redirect(to: "/update_address/livraison")
  end

  # ASK EMAIL OR IDENTIFIANT
  def ask_email(conn,_params) do
    categories = CatRequette.get_all_categorie()

    render(conn,"ask_email.html", categories: categories, search: nil)
  end

end
