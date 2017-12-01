defmodule FrontLine.MotionWorker do
  require Logger
  alias ElixirALE.GPIO
  use GenServer

  @input_pin Application.get_env(:front_line, :input_pin, 20)
  @output_pin Application.get_env(:front_line, :output_pin, 26)
  @debounce_time 4_000

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Logger.info "Starting pin #{@output_pin} as output"
    {:ok, output_pid} = GPIO.start_link(@output_pin, :output)

    Logger.info "Starting pin #{@input_pin} as input"
    {:ok, input_pid} = GPIO.start_link(@input_pin, :input)

    GPIO.set_int(input_pid, :both)
    {:ok, %{input_pid: input_pid, output_pid: output_pid}}
  end

  def handle_info({:gpio_interrupt, pin, :rising}, state) do
    if state[:debounce_timer] do
      Process.cancel_timer(state[:debounce_timer])
    else
      GPIO.write(state[:output_pid], 1)
      UiWeb.Endpoint.broadcast("motion:lobby", "motion", %{active: true})
    end

    timer = Process.send_after(self(), :motion_stopped, @debounce_time)
    state = Map.put(state, :debounce_timer, timer)

    {:noreply, state}
  end
  def handle_info({:gpio_interrupt, pin, _}, state), do: {:noreply, state}

  def handle_info(:motion_stopped, state) do
    GPIO.write(state[:output_pid], 0)
    state = Map.delete(state, :debounce_timer)
    UiWeb.Endpoint.broadcast("motion:lobby", "motion", %{active: false})
    {:noreply, state}
  end
end
