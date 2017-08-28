Enum.each IO.stream(:stdio, :line), &IO.write(&1)
