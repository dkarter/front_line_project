defmodule FrontLine.MotionWorker do
  require Logger
  alias ElixirALE.GPIO

  @input_pin Application.get_env(:front_line, :input_pin, 20)
  @output_pin Application.get_env(:front_line, :output_pin, 26)

  def start_link do
    Logger.info "Starting pin #{@output_pin} as output"
    {:ok, output_pid} = GPIO.start_link(@output_pin, :output)

    Logger.info "Starting pin #{@input_pin} as input"
    {:ok, input_pid} = GPIO.start_link(@input_pin, :input)
    spawn_link fn -> listen_forever(input_pid, output_pid) end
    {:ok, self()}
  end

  defp listen_forever(input_pid, output_pid) do
    GPIO.set_int(input_pid, :both)
    listen_loop(output_pid)
  end

  defp listen_loop(output_pid) do
    receive do
      {:gpio_interrupt, pin, :rising} ->
        GPIO.write(output_pid, 1)
        Logger.debug "MotionWorker got :rising signal on #{pin}"

      {:gpio_interrupt, pin, :falling} ->
        GPIO.write(output_pid, 0)
        Logger.debug "MotionWorker got :falling signal on #{pin}"
    end
    listen_loop(output_pid)
  end
end
