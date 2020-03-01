defmodule SprinklerPiUi.Api.BingWallpaper do
  @api_url 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=de-AT'

  @doc """
  get bing picture of the day
  Response:
  %{
    "url"=> "/th?id=OHR.WallaceFF_ROW3457741856_1920x1080.jpg&rf=LaDigue_1920x1080.jpg&pid=hp",
    "title"=> "",
    "copyright"=> "A Wallace's flying frog glides to the forest floor (\u00a9 Stephen Dalton/Minden Pictures)",
    "image"=> "https://bing.com/th?id=OHR.WallaceFF_ROW3457741856_1920x1080.jpg&rf=LaDigue_1920x1080.jpg&pid=hp",
  }
  """
  def get_pod() do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    try do
      {:ok, {{_, 200, 'OK'}, _headers, body}} = :httpc.request(@api_url)
      {:ok, %{"images" => image_list}} = Jason.decode(to_string(body))
      first_image = Enum.at(image_list, 0)
      Map.merge(first_image, %{"image" => "https://bing.com" <> first_image["url"]})
    rescue
      _ -> %{}
    catch
      _ -> %{}
    end
  end
end
