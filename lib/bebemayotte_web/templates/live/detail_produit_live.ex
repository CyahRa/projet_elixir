defmodule BebemayotteWeb.Live.DetailProduitLive do
  use Phoenix.LiveView
  alias Bebemayotte.CatRequette
  alias Bebemayotte.SouscatRequette
  alias Bebemayotte.ProdRequette
  alias Bebemayotte.PanierRequette

  def mount(_params, %{"id_session" => id_session, "id_produit" => id_produit, "user" => user}, socket) do
    categories = CatRequette.get_all_categorie()
    produit = ProdRequette.get_produit_by_id_produit(id_produit)
    quantite_init = PanierRequette.find_double_in_panier(id_produit, id_session)
    quantite = produit.stockmax |> Decimal.to_integer() |> quantite_initial(quantite_init, id_session, id_produit)
    categorie_prod = CatRequette.get_categorie_by_id_cat(produit.id_cat)
    souscategorie_prod = SouscatRequette.get_souscategorie_by_id_souscat(produit.id_souscat)
    produits_apparentes = ProdRequette.get_produit_apparentes(produit.id_souscat, id_produit)
    {
      :ok,
      socket |> assign(categories: categories, search: nil, id_session: id_session,
                       produit: produit, categorie_prod: categorie_prod,
                       souscategorie_prod: souscategorie_prod, apparentes: produits_apparentes,
                       quantite: quantite, user: user),
      layout: {BebemayotteWeb.LayoutView, "layout_live.html"}
    }
  end

  def handle_event("sub_quantite", %{"quantite" => quantite}, socket) do
    quantite = quantite |> String.to_integer() |> minus()
    {:noreply, socket |> assign(quantite: quantite)}
  end

  def handle_event("add_quantite", %{"quantite" => quantite, "max" => max}, socket) do
    quantite = quantite |> String.to_integer() |> maxus(max |> String.to_integer())
    {:noreply, socket |> assign(quantite: quantite)}
  end

  def handle_event("add_panier", %{"quantite" => quantite, "produit" => id_produit, "session" => session}, socket) do
    id_user = session |> String.to_integer()
    quantite = quantite |> String.to_integer()
    if PanierRequette.find_double_in_panier(id_produit, id_user) do
      params = %{
        "id_panier" => PanierRequette.get_panier_last_row_id(),
        "id_user" => id_user,
        "id_produit" => id_produit,
        "quantite" => quantite
      }
      PanierRequette.insert_panier(params)
    else
      panier = PanierRequette.get_panier_by_id_produit_id_session(id_produit, id_user)
      params = %{
        "quantite" => quantite
      }
      PanierRequette.update_panier_query(panier, params)
    end
    {:noreply, socket}
  end

  def render(assigns) do
    BebemayotteWeb.PageView.render("detail_produit.html", assigns)
  end

  defp quantite_initial(stockmax, quantite, id_session, id_produit) do
    if quantite do
      if stockmax > 0, do: 1, else: 0
    else
      PanierRequette.get_quantite_in_panier(id_produit, id_session)
    end
  end

  defp minus(x) do
    if x > 1, do: x - 1, else: 1
  end

  defp maxus(x, max) do
    if x < max, do: x + 1, else: max
  end
end
