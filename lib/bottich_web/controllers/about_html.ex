defmodule BottichWeb.AboutHTML do
  @moduledoc """
  This module contains pages rendered by AboutController.

  See the `about_html` directory for all templates available.
  """
  use BottichWeb, :html

  embed_templates "about_html/*"
end
