ExUnit.start

Application.ensure_all_started :wallaby
Application.put_env :wallaby, :base_url, Frontend.Endpoint.url
