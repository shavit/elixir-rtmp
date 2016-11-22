defmodule VideoChat.Bucket do
  @doc """
  Start a new bucket
  """
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the bucket by a key
  """
  def get(bucket, key) do
    # Agent.get(bucket, &Map.get(&1, key))
    Agent.get(bucket, fn map -> map |> Map.get(key) end)
  end

  @doc """
  Puts the value for the given key in the bucket
  """
  def put(bucket, key, value) do
    # Agent.update(bucket, &Map.put(&1, key, value))
    Agent.update(bucket, fn map -> map |> Map.put(key, value) end)
  end

  @doc """
  Append to the map
  """
  def add(bucket, key, value) do
    current_value = Agent.get(bucket, fn map -> map |> Map.get(key) end)
    bucket
      |> Agent.update(fn map ->
        map |> Map.put(key, (current_value || "") <> value)
      end)
  end
end
