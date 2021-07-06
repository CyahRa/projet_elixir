defmodule BebemayotteWeb.Live.PanierLive do
  use Phoenix.LiveView
  alias Bebemayotte.CatRequette
  alias Bebemayotte.PanierRequette
  alias Bebemayotte.ProdRequette

  def mount(_params, %{"id_session" => id, "user" => user}, socket) do
    categories = CatRequette.get_all_categorie()
    paniers = PanierRequette.get_all_panier()
    nb_ligne = PanierRequette.line_panier()
    list_id_produit = PanierRequette.get_id_produit_in_panier()
    produits = ProdRequette.get_produit_from_id_produit_panier(list_id_produit)
    somme = list_id_produit |> Enum.map(fn x -> Decimal.to_float(ProdRequette.get_price_in_produit(x)) * PanierRequette.get_quantite_in_panier(x, id) end) |> Enum.sum()
    {
      :ok,
      socket |> assign(categories: categories, search: nil, paniers: paniers,
                       nb_ligne: nb_ligne, produits: produits, somme: somme,
                       id_session: id, user: user),
      layout: {BebemayotteWeb.LayoutView, "layout_live.html"}
    }
  end

  def handle_event("sub_quantite", %{"id" => id, "quantite" => quantite, "session" => session}, socket) do
    id_session = session |> String.to_integer()
    quantite = quantite |> String.to_integer() |> minus()
    params = %{"quantite" => quantite}
    id |> String.to_integer() |> PanierRequette.get_panier_by_id() |> PanierRequette.update_panier_query(params)
    paniers = PanierRequette.get_all_panier()
    list_id_produit = PanierRequette.get_id_produit_in_panier()
    somme = list_id_produit |> Enum.map(fn x -> Decimal.to_float(ProdRequette.get_price_in_produit(x)) * PanierRequette.get_quantite_in_panier(x, id_session) end) |> Enum.sum()
    {:noreply, socket |> assign(paniers: paniers, somme: somme)}
  end

  def handle_event("add_quantite", %{"id" => id, "quantite" => quantite, "session" => session, "max" => max}, socket) do
    id_session = session |> String.to_integer()
    quantite = quantite |> String.to_integer() |> maxus(max |> String.to_integer)
    params = %{"quantite" => quantite}
    id |> String.to_integer() |> PanierRequette.get_panier_by_id() |> PanierRequette.update_panier_query(params)
    paniers = PanierRequette.get_all_panier()
    list_id_produit = PanierRequette.get_id_produit_in_panier()
    somme = list_id_produit |> Enum.map(fn x -> Decimal.to_float(ProdRequette.get_price_in_produit(x)) * PanierRequette.get_quantite_in_panier(x, id_session) end) |> Enum.sum()
    {:noreply, socket |> assign(paniers: paniers, somme: somme)}
  end

  def handle_event("delete_panier", %{"id" => id, "session" => session}, socket) do
    id_session = session |> String.to_integer()
    id |> String.to_integer() |> PanierRequette.get_panier_by_id() |> PanierRequette.delete_panier_query()
    paniers = PanierRequette.get_all_panier()
    list_id_produit = PanierRequette.get_id_produit_in_panier()
    somme = list_id_produit |> Enum.map(fn x -> Decimal.to_float(ProdRequette.get_price_in_produit(x)) * PanierRequette.get_quantite_in_panier(x, id_session) end) |> Enum.sum()
    {:noreply, socket |> assign(paniers: paniers, somme: somme)}
  end

  def render(assigns) do
    BebemayotteWeb.PageView.render("panier.html", assigns)
  end

  defp minus(x) do
    if x > 1, do: x - 1, else: 1
  end

  defp maxus(x, max) do
    if x < max, do: x + 1, else: max
  end
end
