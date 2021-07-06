defmodule BebemayotteWeb.Router do
  use BebemayotteWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BebemayotteWeb do
    pipe_through :browser

      # PAGE CONTROLLER
    get "/", PageController, :index

      # SEARCH
    post "/search", PageController, :search

      # SESSION
    get "/connexion", PageController, :connexion
    post "/connexions", PageController, :submit_connexion
    get "/inscription", PageController, :inscription
    post "/inscriptions", PageController, :submit_inscription

      # CLIENT REACTION
    get "/contact", PageController, :contact
    post "/send_message", PageController, :send_message_contact
    get "/question", PageController, :question

    # PANIER
    get "/panier", PageController, :panier
    get "/add-panier", PageController, :add_panier
    get "/delete-panier", PageController, :delete_panier
    post "/update-panier", PageController, :update_panier


      # PRODUIT
    get "/produit", PageController, :produit
    get "/produit/:cat", PageController, :produit_categorie
    get "/produit/:cat/:souscat", PageController, :produit_souscategorie
    get "/show_produit/:id", PageController, :detail_produit

      # COMPTE CONTROLLER
    get "/account", CompteController, :compte
    get "/commandes", CompteController, :commandes
    get "/download", CompteController, :down
    get "/adresse", CompteController, :adresse
    get "/detail", CompteController, :detail
    post "/update-account", CompteController, :update_account
    delete "/deconnexion", CompteController, :deconnexion
    get "/update_address/facturation", CompteController, :update_facturation
    post "/update_address/facturation/submit", CompteController, :submit_update_facturation
    get "/update_address/livraison", CompteController, :update_livraison
    post "/update_address/livraison/submit", CompteController, :submit_update_livraison

      # COMMAND
    get "/see_command", CompteController, :see_command
    get "/pay_command", CompteController, :pay_command
    get "/politique", CompteController, :politique

      # FORGET PASSWORD
    get "/ask_email", CompteController, :ask_email

  end

  # Other scopes may use custom stacks.
  # scope "/api", BebemayotteWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router

  #   scope "/" do
  #     pipe_through :browser
  #   end
  # end
end
