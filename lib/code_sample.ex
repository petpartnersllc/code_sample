defmodule CodeSample do
  @spec get_comments!(String.t, String.t) :: integer
  def get_comments!(file_id, token) do
    case HTTPoison.get! "https://api.box.com/2.0/files/#{file_id}/comments", %{Authorization: "Bearer #{token}"} do
      %{status_code: 200, body: body} ->
        body
        |> Poison.decode!
        |> Map.get("entries")
      %{status_code: code, body: body} ->
        raise "Failed to get comments.  Received #{code}: #{body}"
    end
  end
end
