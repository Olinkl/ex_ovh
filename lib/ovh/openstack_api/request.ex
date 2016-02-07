defmodule ExOvh.Ovh.Openstack.Request do
  alias ExOvh.Ovh.Auth
  alias LoggingUtils
  alias ExOvh.Ovh.Defaults
  alias ExOvh.Ovh.Cache

  ############################
  # Public
  ############################


  @spec request(query :: ExOvh.Client.raw_query_t)
               :: {:ok, map} | {:error, map}
  def request({method, uri, params} = query), do: request(ExOvh, {method, uri, params} = query)


  @spec request(client :: atom, query :: ExOvh.Client.query_t)
               :: {:ok, ExOvh.Client.response_t} | {:error, ExOvh.Client.response_t}
  def request(client, {method, uri, params} = query) do
    config = config(client)
    {method, uri, options} = Auth.prep_request(client, query)
    resp = HTTPotion.request(method, uri, options)
    resp =
    %{
      body: resp.body |> Poison.decode!(),
      headers: resp.headers,
      status_code: resp.status_code
    }
    if resp.status_code >= 100 and resp.status_code < 300 do
     {:ok, resp}
    else
     {:error, resp}
    end
  end


  ############################
  # Private
  ############################


  defp config(), do: Cache.get_config(ExOvh)
  defp config(client), do: Cache.get_config(client)
  defp endpoint(config), do: Defaults.endpoints()[config[:endpoint]]
  defp api_version(config), do: config[:api_version]


end

