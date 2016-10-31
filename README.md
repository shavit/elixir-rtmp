# VideoChat

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `video_chat` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:video_chat, "~> 0.1.0"}]
    end
    ```

  2. Ensure `video_chat` is started before your application:

    ```elixir
    def application do
      [applications: [:video_chat]]
    end
    ```


Compile and run
````
$ erl
erl> c("server").
erl> server:run().
````

Build
-----

    $ rebar3 compile
