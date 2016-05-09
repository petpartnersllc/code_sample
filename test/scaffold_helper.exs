defmodule ScaffoldHelper do
  @moduledoc """
  This module provides convenience functions, used for setting up and tearing down test cases.

  While the objective of these functions may end up being useful in production, for now they are a little too specific to be particularly useful
  (i.e. They only create files/folders in the root folder)
  """

  @doc """
  Creates a folder under the root folder.
  """
  @spec create_folder(String.t, String.t) :: {:ok, String.t} | {:auth_failure, String.t} | {:error, String.t}
  def create_folder(name, token) do
    case HTTPoison.post!("https://api.box.com/v2.0/folders", Poison.encode!(%{name: "Pet Partners", parent: %{id: 0}}), %{Authentication: "Bearer #{token}"}) do
      %{body: body, status_code: 201} ->
        folder_id = body
                    |> Poison.decode!
                    |> Map.get("id")
        {:ok, folder_id}
      %{status_code: 401} ->
        {:auth_failure, "Failed to upload file.  Authorization token is invalid"}
      %{status_code: status_code, body: body} ->
        {:error, "Failed to create #{name} folder, POST returned #{status_code}: #{Poinson.decode!(body)}"}
    end
  end

  @doc """
  Destroys a Box folder. It will not recursively delete, so it is only usable on empty folders.
  """
  @spec destroy_folder(String.t, String.t) :: {:ok, String.t} | {:auth_failure, String.t} | {:error, String.t}
  def destroy_folder(folder_id, token) do
    case HTTPoison.post!("https://api.box.com/v2.0/folders", Poison.encode!(%{name: "Pet Partners", parent: %{id: 0}}), %{Authentication: "Bearer #{token}"}) do
      %{status_code: 204} ->
        {:ok, "Destroyed folder #{folder_id}"}
      %{status_code: 401} ->
        {:auth_failure, "Failed to upload file.  Authorization token is invalid"}
      %{status_code: status_code, body: body} ->
        {:error, "Destroy folder #{folder_id} failed with response #{status_code}: #{body}"}
    end
  end

  @doc """
  Uploads a file into the root folder.
  """
  @spec upload_file(String.t, String.t) :: {:ok, String.t} | {:auth_failure, String.t} | {:error, String.t}
  def upload_file(filename, token) do
    case HTTPoison.post "https://upload.box.com/api/2.0/files/content", {:multipart, [{"attributes", Poison.encode!(%{name: Path.basename(filename), parent: %{id: "0"}})}, {:file, filename}]}, %{"Authorization" => "Bearer #{token}", "Content-Type" => "multipart/form-data", "Accept" => "*/*"} do
      {:ok, %{status_code: 201, body: body}} ->
        file_id = body
                  |> Poison.decode!
                  |> Map.get("entries")
                  |> hd
                  |> Map.get("id")

        {:ok, file_id}
      {_, %{status_code: 401}} ->
        {:auth_failure, "Failed to upload file.  Authorization token is invalid"}
      {_, %{status_code: 409}} ->
        {:duplicate_file, "Failed to upload file, it already exists."}
      {_, %{status_code: code, body: body}} ->
        {:error, "Failed to upload #{filename}. Received #{code}: #{body}"}
      {_, %{reason: reason}} ->
        {:error, "Failed to upload #{filename}. Received HTTPoison error #{reason}"}
    end
  end

  @doc """
  Uploads a file into the root folder.
  Works the exact same as upload_file, except it raises an exception if the upload fails
  """
  def upload_file!(filename, token) do
    case upload_file(filename, token) do
      {:ok, file_id} ->
        file_id
      {_, error} ->
        raise error
    end
  end

  def get_file_id(filename, token) do
    case HTTPoison.get! "https://api.box.com/2.0/folders/0/items", %{Authorization: "Bearer #{token}"} do
      %{status_code: 200, body: body} ->
        body
        |> Poison.decode!
        |> Map.get("entries")
        |> Enum.find(%{}, fn (x) -> x["name"] == filename end)
        |> Map.get("id")
      %{status_code: status_code, body: body} ->
        {:error, "Failed to retreive root folder contents.  Received #{status_code}: #{body}"}
    end
  end

  def get_file_id!(filename, token) do
    case get_file_id(filename, token) do
      {:ok, file_id} ->
        file_id
      {_, error} ->
        raise error
    end
  end

  @doc """
  Deletes an unlocked file
  """
  @spec delete_file(String.t, String.t) :: {:ok, String.t} | {:auth_failure, String.t} | {:error, String.t}
  def delete_file(file_id, token) do
    case HTTPoison.delete! "https://api.box.com/2.0/files/#{file_id}", %{Authorization: "Bearer #{token}"} do
      %{status_code: 204} ->
        {:ok, "Successfully deleted #{file_id}"}
      %{status_code: 401} ->
        {:auth_failure, "Failed to upload file.  Authorization token is invalid"}
      %{status_code: code, body: body} ->
        {:error, "Failed to delete File ID #{file_id}.  DELETE received #{code}: #{body}"}
    end
  end

  @doc """
  Deletes an unlocked file
  Works the exact same as delete_file, except it raises an exception if the delete fails
  """
  def delete_file!(file_id, token) do
    case delete_file(file_id, token) do
      {:ok, _} ->
        :ok
      {_, error} ->
        raise error
    end
  end
end
