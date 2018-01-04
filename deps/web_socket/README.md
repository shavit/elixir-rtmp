# WebSocket
[![Build Status](https://img.shields.io/travis/slogsdon/plug-web-socket.svg?style=flat)](https://travis-ci.org/slogsdon/plug-web-socket)
[![Coverage Status](https://img.shields.io/coveralls/slogsdon/plug-web-socket.svg?style=flat)](https://coveralls.io/r/slogsdon/plug-web-socket)
[![Hex.pm Version](http://img.shields.io/hexpm/v/web_socket.svg?style=flat)](https://hex.pm/packages/web_socket)

An exploration into a stand-alone library for
Plug applications to easily adopt WebSockets.

## Viewing the examples

Run these:

```
$ git clone https://github.com/slogsdon/plug-web-socket
$ cd plug-web-socket
$ mix deps.get
$ iex -S mix run run_examples.exs
```

Go here: <http://localhost:4000>.

You will be presented with a list of possible
examples/tests that use a WebSocket connection.

## Integrating with Plug

If you're looking to try this in your own test
application, do something like this:

```elixir
defmodule MyApp.Router do
  use Plug.Router
  use WebSocket

  # WebSocket routes
  #      route     controller/handler     function & name
  socket "/topic", MyApp.TopicController, :handle
  socket "/echo",  MyApp.EchoController,  :echo

  # Rest of your router's plugs and routes
  # ...

  def run(opts \\ []) do
    dispatch = dispatch_table(opts)
    Plug.Adapters.Cowboy.http __MODULE__, opts, [dispatch: dispatch]
  end
end
```

For the time being, there is a `run/1` function
generated for your router that starts a HTTP/WS
listener. Not sure if this will stay or get
reduced to helper functions that aid in the
creation of a similar function. Most likely the
latter will win out to help compose functionality.
The big part that it plays is the building of a
dispatch table to pass as an option to Cowboy that
has an entry for each of your socket routes and a
catch all for HTTP requests.

### Add the necessary bits to a module

From the topic example:

```elixir
defmodule MyApp.TopicController do
  def handle(:init, state) do
    {:ok, state}
  end
  def handle(:terminate, _state) do
    :ok
  end
  def handle("topic:" <> letter, state, data) do
    payload = %{awesome: "blah #{letter}",
                orig: data}
    {:reply, {:text, payload}, state}
  end
end
```

Currently, the function name needs to be unique
across all controllers/handlers as its used for
the Events layer.

### Broadcast from elsewhere

Need to send data out from elsewhere in your app?

```elixir
# Build your message
topic = "my_event"
data  = %{foo: "awesome"}
mes   = WebSocket.Message.build(topic, data)
json  = Poison.encode!(mes)

# Pick your destination (from your routes)
name = :handle

# Send away!
WebSockets.broadcast!(name, json)
```

This needs to be nicer, but this is still in
progress.

## License

WebSocket is released under the MIT License.

See [LICENSE](https://github.com/slogsdon/plug-web-socket/blob/master/LICENSE) for details.
