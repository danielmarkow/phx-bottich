defmodule Bottich.Validators do
  def validate_int_id(id) do
    case Integer.parse(id) do
      {integer, _remainder_of_binary} -> {:ok, integer}
      :error -> {:error}
    end
  end
end
