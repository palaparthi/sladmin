defmodule SladminWeb.PageController do
  use SladminWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
