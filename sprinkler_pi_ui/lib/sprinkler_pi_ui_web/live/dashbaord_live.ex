defmodule SprinklerPiUiWeb.DashboardLive do
  use Phoenix.LiveView
  import SprinklerPiUiWeb.Gettext
  alias SprinklerPiUiWeb.Router.Helpers, as: Routes
  alias SprinklerPi.Control

  def radio_tag(assigns) do
    assigns = Enum.into(assigns, %{})

    ~L"""
    <input type="radio" name="<%= @name %>" value="<%= @value %>"
      <%= if @value == @checked, do: "checked" %>
    />
    """
  end

  def render(assigns) do
    ~L"""
    <div class="card-container">
      <div class="card">
        <div class="card-content scale-transfrom">
        </div>
      </div>
      <div class="card card-half">
        <div class="card-content scale-transform">
        </div>
      </div>
      <div class="card card-half">
        <div class="card-content scale-transform">
        </div>
      </div>
      <div class="card card-half">
        <div class="card-content scale-transform">
        </div>
      </div>
      <div class="card card-half">
        <div class="card-content">
          <section>
            <form phx-change="control">
              <h2><%= gettext "Control" %></h2>
              <label class="toggle-switch">
                <input type="checkbox" name="manual_on" value="manual_on"
                  <%= if @manual_on do %>checked <% end %>>
                <span class="toggle-switch-slider"></span>
              </label>
              <p><%= @manual_on %></p>
            </form>
          </section>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "io-change")
    manual_on = Control.get_state(:io_motor) == "on"
    {:ok, assign(socket, manual_on: manual_on)}
  end

  def handle_event("control", %{"_target" => ["manual_on"]}, socket) do
    motor_state = Control.get_state(:io_motor) == "on"
    Control.set_state(:io_motor, if(motor_state, do: "off", else: "on"))
    Control.set_state(:io_led_red, if(motor_state, do: "off", else: "on"))
    IO.puts(!motor_state)
    {:noreply, assign(socket, manual_on: !motor_state)}
  end

  def handle_info({"io-change", :io_motor, state, timestamp}, socket) do
    {:noreply, assign(socket, manual_on: state == "on")}
  end

  def handle_info({"io-change", _, state, timestamp}, socket) do
    {:noreply, socket}
  end
end
