defmodule BottichWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use BottichWeb, :controller` and
  `use BottichWeb, :live_view`.
  """
  use BottichWeb, :html

  embed_templates "layouts/*"
end
