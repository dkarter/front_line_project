defmodule FrontLine.CameraWorker do
  use GenServer
  require Logger

  @frame_rate 30
  @frame_interval 1000 / @frame_rate |> trunc()
  @img_width 640

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    Picam.set_size(@img_width, 0)
    Picam.set_hflip(true)

    Process.send_after(self(), :next_frame, @frame_interval)
    {:ok, []}
  end

  def handle_info(:next_frame, state) do
    data = Picam.next_frame() |> Base.encode64()
    UiWeb.Endpoint.broadcast("video:lobby", "next_frame", %{base64_data: data})
    Process.send_after(self(), :next_frame, @frame_interval)
    {:noreply, state}
  end
end
