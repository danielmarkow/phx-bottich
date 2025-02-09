defmodule BottichWeb.ImpressumHTML do
  @moduledoc """
  This module contains pages rendered by ImpressumController.

  See the `impressum_html` directory for all templates available.
  """
  use BottichWeb, :html

  embed_templates "impressum_html/*"
end
