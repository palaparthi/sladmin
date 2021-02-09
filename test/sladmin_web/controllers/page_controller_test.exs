defmodule SladminWeb.PageControllerTest do
  use SladminWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "<div id=\"SlAdmin\"></div>"
  end
end
