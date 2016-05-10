defmodule AuthenticationIntegrationTest do
  use ExUnit.Case

  test "We can access a token after starting a link" do
    CodeSample.Authentication.start_link
    assert CodeSample.Authentication.get_token =~ ~r/[[:alnum:]]*/
  end

  test "We will raise an exception if requesting a token without starting the link" do
    assert_raise RuntimeError, fn ->
      CodeSample.Authentication.get_token
    end
  end

  test "Authentication will automatically renew tokens after expiry" do
    CodeSample.Authentication.start_link(2500) # Expire after 2.5 seconds
    old_token = CodeSample.Authentication.get_token
    :timer.sleep(3000)

    assert CodeSample.Authentication.get_token != old_token
  end

  test "It will return the same token if it has not yet expired" do
    CodeSample.Authentication.start_link(2500) # Expire after 2.5 seconds
    old_token = CodeSample.Authentication.get_token
    :timer.sleep(100)

    assert CodeSample.Authentication.get_token == old_token
  end
end
