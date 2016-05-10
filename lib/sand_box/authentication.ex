defmodule SandBox.Authentication do
  use GenServer
  @moduledoc """
  This module handles authenitcation tokens along with token refresh.

  It is a little bit fragile, but should suffice for testing the BOX API.
  Requesting tokens before start_link is called and calling start_link multiple times will cause exceptions.
  We'll want to harden this before using it for anything in production.
  """

  @spec start_link(integer) :: {:ok, pid}
  def start_link(cycle \\ 60*60*1000) do
    GenServer.start_link(__MODULE__, cycle, [])
  end

  @doc """
  The init function creates the necessary ETS table for storing the auth token.
  This method is intended for GenServer's consumption, not the end user of this module.
  The user should instead call `SandBox.Authentication.start_link`
  """
  def init(cycle) do
    # Refresh tokan after `cycle` milliseconds.  Should be less than 3621000
    :timer.send_interval(cycle, :refresh_key)
    :ets.new(:box_auth_table, [:named_table])

    update_token()
    {:ok, nil}
  end

  @doc """
  Gets the most recent token from the document store.
  This method must be called after start_link or else the :box_auth_table will not exist in ETS
  """
  @spec get_token() :: String.t
  def get_token() do
    case :ets.lookup(:box_auth_table, :enterprise_token) do
      [] ->
        update_token()
      [enterprise_token: token] ->
        token
    end
  rescue
    ArgumentError -> raise "Lookup failed.  Did you remember to call start_link first?"
  end

  @doc """
  This method should never be called by the end user, unless start_link has been called AND get_token fails.

  While it will not harm the system to call update_token normally, it is a lot of unnecessary communication with the BOX API.
  """
  def update_token() do
    pem_key = JOSE.JWK.from_pem_file(Application.get_env(:sand_box, :box_pem_key))
    {_, encoded} = JOSE.JWK.sign(build_payload, build_header, pem_key)
    assertion = "#{encoded["protected"]}.#{encoded["payload"]}.#{encoded["signature"]}"
    request = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" <>
              "&client_id=" <> Application.get_env(:sand_box, :box_api_key) <>
              "&client_secret=" <> Application.get_env(:sand_box, :box_api_secret) <>
              "&assertion=" <> assertion

    case HTTPoison.post!("https://api.box.com/oauth2/token", request) do
      %{status_code: 200, body: body} ->
        token = body
                |> Poison.decode!
                |> Map.get("access_token")

        :ets.insert(:box_auth_table, {:enterprise_token, token})
      %{status_code: 400, body: body} ->
        resp = Poison.decode!(body)
        raise "Failed to get API key. #{resp["error"]}: #{resp["error_description"]}"
      unexpected_failure ->
        raise unexpected_failure
    end
  end

  defp build_header() do
    Poison.encode! %{"alg" => "RS256",
                    "typ" => "JWT",
                    "kid" => Application.get_env(:sand_box, :box_key_id)}
  end

  defp build_payload() do
    Poison.encode! %{iss: Application.get_env(:sand_box, :box_api_key),
                     sub: Application.get_env(:sand_box, :box_user_id),
                     aud: "https://api.box.com/oauth2/token",
                     box_sub_type: "user",
                     jti: Base.url_encode64(Integer.to_string(:os.system_time), padding: false),
                     exp: :os.system_time(:seconds) + 55}
  end


  # On shutdown message, delete the auth table
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, _) do
    :ets.delete(:box_auth_table)
  end

  def handle_info(:refresh_key, state) do
    update_token()

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}
end
