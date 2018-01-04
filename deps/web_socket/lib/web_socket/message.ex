defmodule WebSocket.Message do
  defstruct event: nil, data: nil

  def build(event, data) do
    %__MODULE__{
      event: event,
      data: data
    }
  end
end
