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
        <div class="card-content"></div>
      </div>
      <div class="card card-half">
        <div class="card-content"></div>
      </div>
      <div class="card card-half">
        <div class="card-content"></div>
      </div>
      <div class="card card-half">
        <div class="card-content"></div>
      </div>
      <div class="card card-half">
        <div class="card-content">
          <section>
            <h2><%= gettext "Control" %></h2>
            <label class="toggle-switch">
              <input
                phx-click="click_manual_override"
                id="manual_override"
                type="checkbox"
                name="manual_override"
                value="true"
                <%= if @pump_active do "checked" end %>>
              <span class="toggle-switch-slider"></span>
            </label>
            <hr />
            <div class="flex" style="padding: 0 0.5rem;">
              <button 
               style="z-index: 1;"
                phx-click="click_manual_override_reset"
                class="<%= if @manual_override == nil do "inactive" end %>" >
              <%= gettext "Reset" %>
              </button>
              <span style="font-size: 1.25rem; padding-top: 2px;"><%= gettext("%{time} sec", time: @manual_override_remaining_time) %></span>
            </div>
          </section>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "schedule")
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "pump-control")
    {manual_override, manual_override_start} = SprinklerPi.Schedule.get_override()
    active_schedule = SprinklerPi.Schedule.active()
    pump_active = SprinklerPi.PumpControl.active?()
    pump_error = SprinklerPi.PumpControl.error()

    if manual_override != nil do
      Process.send(self(), :manual_override_timer_tick, [])
    end

    {:ok,
     assign(socket,
       active_schedule: active_schedule,
       pump_active: pump_active,
       pump_error: pump_error,
       manual_override: manual_override,
       manual_override_start: manual_override_start,
       manual_override_remaining_time: 0
     )}
  end

  def handle_event("click_manual_override", %{"value" => "true"}, socket) do
    SprinklerPi.Schedule.set_override(true)
    {:noreply, socket}
  end

  def handle_event("click_manual_override", _, socket) do
    SprinklerPi.Schedule.set_override(false)
    {:noreply, socket}
  end

  def handle_event("click_manual_override_reset", _, socket) do
    if SprinklerPi.Schedule.get_override() != nil do
      SprinklerPi.Schedule.set_override(nil)
    end

    {:noreply, socket}
  end

  def handle_info({"schedule-activate", active, _ts}, socket) do
    {:noreply, assign(socket, active_schedule: active)}
  end

  def handle_info({"manual-override", manual_override, manual_override_start, _ts}, socket) do
    Process.send(self(), :manual_override_timer_tick, [])

    {:noreply,
     assign(socket, manual_override: manual_override, manual_override_start: manual_override_start)}
  end

  def handle_info(:manual_override_timer_tick, socket) do
    %{"override_timeout_seconds" => manual_override_timeout} = SprinklerPi.Setting.get()

    remaining =
      if socket.assigns.manual_override_start != nil do
        end_time =
          DateTime.add(socket.assigns.manual_override_start, manual_override_timeout, :second)

        DateTime.diff(end_time, DateTime.utc_now())
      else
        0
      end

    if socket.assigns.manual_override != nil and remaining > 0 do
      Process.send_after(self(), :manual_override_timer_tick, 1000)
    end

    {:noreply, assign(socket, manual_override_remaining_time: remaining)}
  end

  def handle_info({"pump-change", state, _ts}, socket) do
    {:noreply, assign(socket, pump_active: state)}
  end

  def handle_info({"pump-error", pump_error, _ts}, socket) do
    {:noreply, assign(socket, pump_error: pump_error)}
  end
end
