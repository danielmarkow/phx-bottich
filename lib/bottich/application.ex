defmodule Bottich.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BottichWeb.Telemetry,
      Bottich.Repo,
      {DNSCluster, query: Application.get_env(:bottich, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Bottich.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Bottich.Finch},
      # Start a worker by calling: Bottich.Worker.start_link(arg)
      # {Bottich.Worker, arg},
      # Start to serve requests, typically the last entry
      BottichWeb.Endpoint,
      Bottich.RateLimit
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bottich.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BottichWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
