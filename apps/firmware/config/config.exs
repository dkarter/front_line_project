use Mix.Config

config :hello_network, interface: :wlan0

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID"),
    psk: System.get_env("NERVES_NETWORK_PSK"),
    key_mgmt: String.to_atom(key_mgmt),
  ],
  eth0: [
    ipv4_address_method: :dhcp,
  ]

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!, ".ssh/nerves.pub"))
  ]

config :bootloader,
  init: [:nerves_runtime, :nerves_network],
  app: :front_line

config :front_line, input_pin: 20
config :front_line, output_pin: 26

config :ui, UiWeb.Endpoint,
  http: [port: 80],
  url: [host: "localhost", port: 80],
  secret_key_base: "tSOopOR8V7jFykR6+GRnldYYN5UMZvxYSmNa8CiZKEZhctb8m/PYMcvTDgc39Xoe",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Ui.PUbSub, adapter: Phoenix.PubSub.PG2],
  code_reloader: false

