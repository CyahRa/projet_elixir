defmodule BebemayotteWeb.PageController do
  use BebemayotteWeb, :controller

  alias Phoenix.LiveView
  alias Bebemayotte.CatRequette
  alias Bebemayotte.ProdRequette
  alias Bebemayotte.SouscatRequette
  alias Bebemayotte.PanierRequette
  alias Bebemayotte.UserRequette
  alias Bebemayotte.Email
  alias Bebemayotte.Mailer

  #----------------------------------------------------------PAGE PRODUITS-------------------------------------------------------------------------------------------------------------------
  # GET ACCUEIL
  def index(conn, _params) do
    categories = CatRequette.get_all_categorie()

    render(conn, "index.html", categories: categories, search: nil)
  end

  # GET PAGE PRODUIT
  def produit(conn, _params) do
    id = Plug.Conn.get_session(conn, :user_id)
    if id == nil do
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.ProduitLive, session: %{"id_session" => 1, "user" => nil, "cat" => nil, "souscat" => nil, "search" => nil})
    else
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.ProduitLive, session: %{"id_session" => id, "user" => id, "cat" => nil, "souscat" => nil, "search" => nil})
    end
  end

  # GET PAGE PRODUIT WITH CATEGORIE
  def produit_categorie(conn, %{"cat" => cat}) do
    id = Plug.Conn.get_session(conn, :user_id)
    if id == nil do
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.ProduitLive, session: %{"id_session" => 1, "user" => nil, "cat" => cat, "souscat" => nil, "search" => nil})
    else
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.ProduitLive, session: %{"id_session" => id, "user" => id, "cat" => cat, "souscat" => nil, "search" => nil})
    end
  end

  # GET PAGE PRODUIT WITH SOUS CATEGORIE
  def produit_souscategorie(conn, %{"cat" => cat, "souscat" => souscat}) do
    id = Plug.Conn.get_session(conn, :user_id)
    if id == nil do
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.ProduitLive, session: %{"id_session" => 1, "user" => nil, "cat" => cat, "souscat" => souscat, "search" => nil})
    else
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.ProduitLive, session: %{"id_session" => id, "user" => id, "cat" => cat, "souscat" => souscat, "search" => nil})
    end
  end

  #------------------------------------------------PAGE SESSION------------------------------------------------------------------------------------------------------------------------

  # GET PAGE CONNEXION
  def connexion(conn, _params) do
    categories = CatRequette.get_all_categorie()

    render(conn, "connexion.html", categories: categories, search: nil)
  end

  # SUBMIT CONNEXION
  def submit_connexion(conn, %{"identifiant" => identifiant, "motdepasse" => motdepasse}) do
    case UserRequette.get_user_connexion(identifiant,motdepasse) do
      {:ok, user} ->
         conn
         |> put_session(:info_connexion, "Vous êtes connecté en tant que #{user.prenom}, ")
         |> put_session(:user_id, user.id_user)
         |> configure_session(renew: true)
         |> redirect(to: Routes.compte_path(conn, :compte))
        {:error, :unauthorized} ->
          conn
          |> put_flash(:error_id_mdp, "Identifiant ou adresse e-mail éronné")
          |> redirect(to: Routes.page_path(conn, :connexion))
    end
  end

  # GET PAGE INSCRIPTION
  def inscription(conn, _params) do
    categories = CatRequette.get_all_categorie()

    render(conn, "inscri.html", categories: categories, search: nil)
  end

  # SUBMIT INSCRIPTION
  def submit_inscription(conn, %{"user" => %{
    "prenom" => prenom,
    "nom" => nom,
    "pays" => pays,
    "ville" => ville,
    "telephone" => telephone,
    "codepostal" => codepostal,
    "identifiant" => identifiant,
    "adresseMessage" => adresseMessage,
    "motdepasse" => motdepasse
  }}) do

    last_row_id = UserRequette.get_user_last_row_id()

    user = %{
      "id_user" => last_row_id,
      "nom" => nom,
      "prenom" => prenom,
      "nom_affiche" => "null",
      "nom_rue" => "null",
      "batiment" => "null",
      "pays" => pays,
      "ville" => ville,
      "identifiant" => identifiant,
      "adresseMessage" => adresseMessage,
      "codepostal" => codepostal,
      "telephone" => telephone,
      "motdepasse" => motdepasse,
      "nom_entreprise" => "null"
    }

    recup_id = UserRequette.get_user_identifiant(identifiant)
    recup_adr = UserRequette.get_user_adresse_message(adresseMessage)

    cond do
      recup_id == true and recup_adr == true ->
        conn
        |> put_flash(:error_id_adrMess, "Identifiant et Adresse de Message déja éxistants!")
        |> redirect(to: Routes.page_path(conn, :inscription))

      recup_id == true ->
        conn
        |> put_flash(:error_id, "Identifiant déja éxistant!")
        |> redirect(to: Routes.page_path(conn, :inscription))

      recup_adr == true ->
        conn
        |> put_flash(:error_adrMess, "Adresse de Message déja éxistant!")
        |> redirect(to: Routes.page_path(conn, :inscription))

      recup_adr == false and recup_id == false ->
        UserRequette.insert_user(user)
        conn
        |> put_flash(:info_reussi, "Création de compte terminé! Veuillez vous connectez maitenant!!")
        |> redirect(to: Routes.page_path(conn, :connexion))
    end
  end

  #--------------------------------------------------PAGE CRITIQUE ET PROPOSITION-------------------------------------------------------------------------------------------------------

  # SEND MESSAGE TO EMAIL
  def send_message_contact(conn, %{"nom" => nom, "email" => email, "description" => description}) do

      message = "

          #{description}

                      from:  #{nom}

      "
      Email.new_mail_message(email, message)
        |>Mailer.deliver_later()

      conn
        |>put_flash(:mail_message_env, "Votre message a été bien envoyé!")
        |>redirect(to: "/contact")
  end

  # GET PAGE QUESTION
  def question(conn,_params) do
    categories = CatRequette.get_all_categorie()

    render(conn,"question.html", categories: categories, search: nil)
  end

  #-------------------------------------------------PAGE PANIER--------------------------------------------------------------------------------------------------------------------------

  # ADD PANIER
  def add_panier(conn, %{"id" => id, "cat" => cat, "souscat" => souscat}) do
    id_session = Plug.Conn.get_session(conn, :user_id)

    if id_session == nil do
      if cat == "" do
        conn
          |>put_flash(:error_panier,"Veuillez vous connecter pour ajouter un article au panier!!! <a href=\"/connexion\" class=\"link\">Cliquez ici</a>")
          |>redirect(to: "/produit")
      else
        if souscat == "" do
          conn
            |>put_flash(:error_panier,"Veuillez vous connecter pour ajouter un article au panier!!! <a href=\"/connexion\" class=\"link\">Cliquez ici</a>")
            |>redirect(to: "/produit/#{cat}")
        else
          conn
            |>put_flash(:error_panier,"Veuillez vous connecter pour ajouter un article au panier!!! <a href=\"/connexion\" class=\"link\">Cliquez ici</a>")
            |>redirect(to: "/produit/#{cat}/#{souscat}")
        end
      end
    else
      is_exist = PanierRequette.find_double_in_panier(id, id_session)
      if is_exist do
        last_row_id = PanierRequette.get_panier_last_row_id()
        id_user = id_session
        quantite = 1
        params = %{
          "id_panier" => last_row_id,
          "id_produit" => id,
          "id_user" => id_user,
          "quantite" => quantite
        }
        PanierRequette.insert_panier(params)
        if cat == "" do
          conn
            |>put_flash(:error_panier,"L'article est parfaitement ajouté au panier.")
            |>redirect(to: "/produit")
        else
          if souscat == "" do
            conn
              |>put_flash(:error_panier,"L'article est parfaitement ajouté au panier.")
              |>redirect(to: "/produit/#{cat}")
          else
            conn
              |>put_flash(:error_panier,"L'article est parfaitement ajouté au panier.")
              |>redirect(to: "/produit/#{cat}/#{souscat}")
          end
        end
      else
        if cat == "" do
          conn
            |>put_flash(:error_panier,"L'article est déja dans le panier!!!")
            |>redirect(to: "/produit")
        else
          if souscat == "" do
            conn
              |>put_flash(:error_panier,"L'article est déja dans le panier!!!")
              |>redirect(to: "/produit/#{cat}")
          else
            conn
              |>put_flash(:error_panier,"L'article est déja dans le panier!!!")
              |>redirect(to: "/produit/#{cat}/#{souscat}")
          end
        end
      end
    end

  end

  # DELETE PANIER
  def delete_panier(conn, %{"id" => id}) do
    panier = PanierRequette.get_panier_by_id(id)
    PanierRequette.delete_panier_query(panier)
    redirect(conn, to: Routes.page_path(conn, :panier))
  end

  # UPDATE PANIER
  def update_panier(conn, %{"id" => id, "quantite" => quantite}) do
    panier = PanierRequette.get_panier_by_id(id)
    params = %{
      "quantite" => quantite
    }
    PanierRequette.update_panier_query(panier, params)
    redirect(conn, to: "/panier")
  end

  #-----------------------------------------------------------SEARCH-------------------------------------------------------------------------------------------------
  # SEARCH ALGORITHM
  def search(conn, %{"_csrf_token" => _csrf_token, "search" => search}) do
    id = Plug.Conn.get_session(conn, :user_id)
    if id == nil do
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.ProduitLive, session: %{"id_session" => 1, "user" => nil, "cat" => nil, "souscat" => nil, "search" => search})
    else
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.ProduitLive, session: %{"id_session" => id, "user" => id, "cat" => nil, "souscat" => nil, "search" => search})
    end
  end

  #------------------------------------------------------------LIVEVIEW------------------------------------------------------------------------------------------------

  # GET PANIER
  def panier(conn,_params) do
    id = Plug.Conn.get_session(conn, :user_id)
    if id == nil do
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.PanierLive, session: %{"id_session" => 1, "user" => nil})
    else
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.PanierLive, session: %{"id_session" => id, "user" => id})
    end
    # categories = CatRequette.get_all_categorie()
    # paniers = PanierRequette.get_all_panier()
    # list_id_produit = PanierRequette.get_id_produit_in_panier()
    # somme = ProdRequette.sum_price_in_panier(list_id_produit)
    # produits = ProdRequette.get_produit_from_id_produit_panier(list_id_produit)
    # nombre_line = PanierRequette.line_panier()
    #
    # render(conn,"panier.html", categories: categories, paniers: paniers, produits: produits, somme: somme, nombre_line: nombre_line, search: nil)

  end

  # GET PAGE DETAIL PPRODUIT
  def detail_produit(conn, %{"id" => id}) do
    id_session = Plug.Conn.get_session(conn, :user_id)
    if id_session == nil do
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.DetailProduitLive, session: %{"id_session" => 1, "id_produit" => id, "user" => nil})
    else
      LiveView.Controller.live_render(conn, BebemayotteWeb.Live.DetailProduitLive, session: %{"id_session" => id_session, "id_produit" => id, "user" => id_session})
    end
  end

  # GET PAGE CONTACT
  def contact(conn, _params) do
    # categories = CatRequette.get_all_categorie()
    id = Plug.Conn.get_session(conn, :user_id)
    if id == nil do
      LiveView.Controller.live_render(conn,  BebemayotteWeb.Live.ContactLive, session: %{"user" => nil})
    else
      LiveView.Controller.live_render(conn,  BebemayotteWeb.Live.ContactLive, session: %{"user" => id})
    end
    # render(conn, "contact.html", categories: categories, search: nil)
  end
end
