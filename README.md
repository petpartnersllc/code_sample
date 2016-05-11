# Code Sample
At Pet Partners, we write a lot of code in Elixir.  We're passionate about the language and we also believe one of the best ways to evaluate developers is by looking at code they've written.  Interested in building world class software that's fundamentally changing veterinary medicine?  Join our team!  To get started, follow the directions below and then email us a link to your code repository.  

Don't worry if you aren't intimately familiar with Elixir.  We're open to developers who can quickly pick up at least the basics of the language and are excited about learning more and using it on a daily basis.  If you've worked with Elixir before, this exercise might take you an hour or two to complete.  If you're new to the language, it could be a half day, or the better part of a weekend if you really dive into the language.  It's really up to you.

For the code sample, you'll be using Elixir to interact with the [Box API](https://box-content.readme.io/reference) as the first step in our application process. In addition to file syncing and sharing, [Box](https://www.box.com) allows users to create comments about a file.  At a minimum, we'd like you to write the code and the appropriate associated tests to create, get, update, and delete a comment about a file.  We've created some scaffolding to get you started, including functions to upload and destroy a file on which you can comment, setup and tear down functions for your tests, and a sample test file. If you're looking for a jumping off point, try test/integration/code_sample_integration_test.exs.

# Instructions

1) Fork this repository

2) Signup for a Box developer account

3) Create an app only user in your Box account (keep note of the user ID, you'll need it):
    
    curl https://api.box.com/2.0/users -H "Authorization: Bearer ACCESS_TOKEN" -d '{"name": SOME_NAME, "is_platform_access_only": true}' -X post

4) Write your code and tests to go with it

4) Make sure all tests are passing

5) Email us a link to your repository. 

# Learning Resources
Elixir is a functional language which lives on top of the Erlang Virtual Machine, just as Groovy or Clojure live on top of the Java Virtual Machine.  At Pet Partners, we develop software using Elixir whenever possible.  We recognize that functional programming requires a somewhat different mindset and may not be for everyone.  Accordingly, we've developed this simple programming exercise to determine if a potential candidate is a good match.

## Elixir
[Elixir Website](http://elixir-lang.org) - Install instructions, links, etc..

[exercism.io](http://exercism.io/languages/elixir) - Elixir exercises which may help geting comfortable with the language.

[Elixir School](https://elixirschool.com) - More lessons for learning the language

[HTTPoison](https://github.com/edgurgel/httpoison) - Our go to library for HTTP requests

[Poison](https://github.com/devinus/poison) - A wonderful library for handling JSON.

## Box
[Box Developer Site](https://developers.box.com) - Main developer site for Box.

[Content API](https://box-content.readme.io/reference) - The specific API you'll need to use for this exercise.

## Git
[Github Bootcamp](https://help.github.com/categories/bootcamp/) - Lots of great resources for getting started

[Try Git!](https://try.github.io) - Interact with Git from within your browser.
