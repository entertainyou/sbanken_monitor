defmodule SbankenMonitor.Client do
  @moduledoc false

  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.sbanken.no")

  plug(Tesla.Middleware.JSON)

  def new(customer_id) do
    {:ok, result} = SbankenMonitor.AuthClient.get_access_token()
    access_token = Map.fetch!(result.body, "access_token")

    Tesla.client([
      {
        Tesla.Middleware.Headers,
        [{"Authorization", "Bearer #{access_token}"}, {"customerId", customer_id}]
      }
    ])
  end

  def get_accounts(client) do
    get(client, "/bank/api/v1/accounts/")
  end

  def get_account(client, account_id) do
    get(client, "/bank/api/v1/accounts/#{account_id}")
  end

  def get_transactions(client, account_id) do
    get(client, "/bank/api/v1/transactions/#{account_id}")
  end
end
