defmodule BottichWeb.Router do
  use BottichWeb, :router

  import BottichWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BottichWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :lv_rate_limit do
    plug RemoteIp
    plug :rate_limit, "public_list_live"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BottichWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/sitenotice", ImpressumController, :impressum
    get "/dataprotection", DatenschutzController, :datenschutz
    get "/about", AboutController, :about
  end

  scope "/", BottichWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user_list,
      on_mount: [{BottichWeb.UserAuth, :ensure_authenticated}] do
      live "/list/:list_id", ListLive
      live "/list", ListOverviewLive
      live "/newlist", ListNewLive
    end
  end

  # public lists
  scope "/public", BottichWeb do
    pipe_through [:browser, :lv_rate_limit]

    live "/list/:list_id", PublicListLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", BottichWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bottich, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BottichWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", BottichWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{BottichWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", BottichWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BottichWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", BottichWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{BottichWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  defp rate_limit(conn, namespace) do
    case Bottich.RateLimit.hit(
           {namespace, conn.remote_ip},
           _scale = :timer.seconds(10),
           _limit = 10
         ) do
      {:allow, _count} ->
        conn

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After
      {:deny, retry_after_ms} ->
        retry_after_seconds = div(retry_after_ms, 1000)

        conn
        |> put_resp_header("retry-after", Integer.to_string(retry_after_seconds))
        |> send_resp(
          429,
          "You are too fast, and you are rate limited. Try again in #{retry_after_seconds} seconds."
        )
        |> halt()
    end
  end
end
