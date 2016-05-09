Code.require_file "../scaffold_helper.exs", __DIR__

defmodule SandBoxIntegrationTest do
  use ExUnit.Case

  setup_all do
    SandBox.Authentication.start_link
    # Build up "./test/resources/pp_doc.txt" in a platform agnostic way
    test_file = Path.join [".", "test", "resources", "pp_doc.txt"]
    current_token = SandBox.Authentication.get_token

    # If there is an exists version of this file, we want to delete it
    # We'll create a new version to run our tests against after this block
    case ScaffoldHelper.get_file_id("pp_doc.txt", current_token) do
      0 ->
        nil
      file_id ->
        ScaffoldHelper.delete_file!(file_id, current_token)
    end

    pp_file_id = ScaffoldHelper.upload_file!(test_file, current_token)

    on_exit fn -> ScaffoldHelper.delete_file!(pp_file_id, current_token) end

    # Metadata to be passed to the tests
    {:ok, file_id: pp_file_id}
  end

  test "We can add a comment to a file"

  test "We can delete a comment from a file"
end
