defmodule SprinklerPiUiWeb.DashboardLive do
  use Phoenix.LiveView
  import SprinklerPiUiWeb.Gettext
  alias SprinklerPiUiWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <div class="card-container dashboard">
      <div class="card">
        <div class="card-content">
          <section>
            <h2><%= gettext "History" %></h2>
            <p>¯\_(ツ)_/¯</p>
          </section>
        </div>
      </div>
      <div class="card card-half">
        <div class="card-content">
          <section>
            <h2><%= gettext "Weather" %></h2>
            <p>¯\_(ツ)_/¯</p>
          </section>
        </div>
      </div>
      <div class="card card-half">
        <div class="card-content">
          <section class="dashboard-status">
            <h2><%= gettext "Status" %></h2>
            <div class="dashboard-status-list">
              <%= if @pump_error == "water-low" do %>
                <div class="dashboard-status-banner error"><%= gettext("Water level low") %></div>
              <% end %>
              <%= if @active_schedule != nil do %>
              <% {id, w, h, m, d} = @active_schedule %> 
              <% w = weekday_to_text(w)  %>
              <% h = pad_time(h) %>
              <% m = pad_time(m) %>
              <% d = round(d / 60) %>
              <div class="dashboard-status-banner">
                <%= gettext("Active schedule:") %><br />
                <%= gettext("%{w} %{h}:%{m} %{d} min", w: w, h: h, m: m, d: d) %>
              </div>
              <% end %>
            </div>
          </section>
        </div>
      </div>
      <div class="card card-half">
        <div class="card-content">
          <section>
            <h2><%= gettext "Schedule" %></h2>
            <button 
              class="dashboard-schedule-button"
              phx-click="click_open_schedule_screen">📅</button>
          </section>
        </div>
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
            <div class="flex dashboard-control-reset">
              <button 
                phx-click="click_manual_override_reset"
                class="<%= if @manual_override == nil do "inactive" end %>" >
              <%= gettext "Reset" %>
              </button>
              <span class="dashboard-control-reset-time"><%= gettext("%{time} sec", time: @manual_override_remaining_time) %></span>
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

    pump_error =
      case SprinklerPi.PumpControl.error() do
        {:error, msg} -> msg
        _ -> ""
      end

    if manual_override != nil do
      Process.send(self(), :manual_override_timer_tick, [])
    end

    socket = assign(socket, page_title: "Dashboard")

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

  def handle_event("click_open_schedule_screen", _, socket) do
    {:noreply,
     live_redirect(
       socket,
       to: Routes.live_path(socket, SprinklerPiUiWeb.ScheduleLive)
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

  def handle_info({"pump-error", {:error, msg}, _ts}, socket) do
    {:noreply, assign(socket, pump_error: msg)}
  end

  def handle_info({"pump-error", _, _ts}, socket) do
    {:noreply, assign(socket, pump_error: "")}
  end

  defp weekday_to_text(weekday) do
    case weekday do
      1 -> "Mon"
      2 -> "Tue"
      3 -> "Wed"
      4 -> "Thr"
      5 -> "Fri"
      6 -> "Sat"
      7 -> "Sun"
      _ -> ""
    end
  end

  defp pad_time(number), do: Integer.to_string(number) |> String.pad_leading(2, "0")
end
