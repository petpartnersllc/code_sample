Code.require_file "../scaffold_helper.exs", __DIR__

defmodule SandBoxIntegrationTest do
  use ExUnit.Case

  setup_all do
    # Build up "./test/resources/pp_doc.txt" in a platform agnostic way
    test_file = Path.join [".", "test", "resources", "pp_doc.txt"]
    current_key = SandBox.Authentication.get_key

    pp_file_id = ScaffoldHelper.upload_file!(test_file, current_key)

    on_exit fn -> ScaffoldHelper.delete_file!(pp_file_id, current_key) end

    # Metadata to be passed to the tests
    {:ok, file_id: pp_file_id}
  end

  test "We can add a comment to a file"

  test "We can delete a comment from a file"
end
