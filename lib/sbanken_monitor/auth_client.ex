defmodule SbankenMonitor.AuthClient do
  @moduledoc false

  use Tesla

  @client_id Application.get_env(:sbanken_monitor, :client_id)
  @password Application.get_env(:sbanken_monitor, :password)

  plug(Tesla.Middleware.BasicAuth,
    username: encode_uri_component(@client_id),
    password: encode_uri_component(@password)
  )

  plug(Tesla.Middleware.BaseUrl, "https://auth.sbanken.no")

  plug(Tesla.Middleware.FormUrlencoded)
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Logger)

  def encode_uri_component(comp) do
    URI.encode(comp, &URI.char_unreserved?/1)
  end

  def get_access_token() do
    post("/identityserver/connect/token", %{"grant_type" => "client_credentials"})
  end
end
