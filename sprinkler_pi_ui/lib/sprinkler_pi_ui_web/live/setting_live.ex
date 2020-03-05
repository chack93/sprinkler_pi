defmodule SprinklerPiUiWeb.SettingLive do
  use Phoenix.LiveView
  import SprinklerPiUiWeb.Gettext
  alias SprinklerPiUiWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <div class="setting">
      <div class="setting-container">
        <div class="setting-container-inner">
          <div class="setting-row flex">
            <span class="setting-text"><%= gettext("Override timeout") %>: <%= gettext("%{t} seconds", t: @override_timeout_seconds) %></span>
            <button class="setting-button-edit" phx-click="click_edit_row" phx-value-type="override_timeout_seconds">✎</button>
          </div>
          <hr />
          <div class="setting-row flex">
            <span class="setting-text"><%= gettext("Statistic min pump time") %>: <%= gettext("%{t} seconds", t: @filter_min_pump_time_seconds) %></span>
            <button class="setting-button-edit" phx-click="click_edit_row" phx-value-type="filter_min_pump_time_seconds">✎</button>
          </div>
        </div>
      </div>
      <div class="setting-container">
        <section class="setting-container-inner">
          <h2><%= gettext("About") %></h2>
          <p><%= gettext("Sprinkler π was created by %{c}!", c: "Christian") %></p>
          <div class="setting-credit-toon-wrapper">
            <div class="setting-credit-toon can <%= if @run_toon, do: "animate" %>"
              style="animation: <%= if @run_toon, do: "", else: "none" %>"
              tabindex="-1"
              phx-click="run_toon"
              phx-throttle="4000">
              <div class="setting-credit-toon body"></div>
              <div class="setting-credit-toon neck"></div>
              <div class="setting-credit-toon funnel"></div>
              <div class="setting-credit-toon handle"></div>
              <div class="setting-credit-toon water"
              style="animation: <%= if @run_toon, do: "", else: "none" %>">
                <div class="setting-credit-toon water-drop"></div>
                <div class="setting-credit-toon water-drop"></div>
                <div class="setting-credit-toon water-drop"></div>
                <div class="setting-credit-toon water-drop"></div>
                <div class="setting-credit-toon water-drop"></div>
                <div class="setting-credit-toon water-drop"></div>
                <div class="setting-credit-toon water-drop"></div>
                <div class="setting-credit-toon water-drop"></div>
                <div class="setting-credit-toon water-drop"></div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
    <%= if @edit_dialog_show do render_dialog(assigns) end %>
    """
  end

  def render_dialog(assigns) do
    ~L"""
     <div class="setting-dialog" tabindex="-1" phx-click="click_dialog_close">
       <div class="setting-dialog-container" phx-click>
         <h2><%= if @dialog_type == "override_timeout_seconds" do gettext("Override timeout") else gettext("Statistic min pump time") end %></h2> 
         <div class="setting-dialog-input">
           <%= if @dialog_type == "override_timeout_seconds" do %>
           <%= render_selection(assigns, event: "override_timeout_seconds", value: @dialog_data) %>
           <% else %>
           <%= render_selection(assigns, event: "filter_min_pump_time_seconds", value: @dialog_data) %>
           <% end %>
         </div>
         <button class="setting-dialog-confirm" phx-click="click_dialog_confirm"><%= gettext("Confirm") %></button>
       </div>
     </div>
    """
  end

  def render_selection(assigns, opt) do
    ~L"""
    <div class="setting-selection-container">
      <div class="setting-selection-title"><%= opt[:title] %></div>
      <button
        phx-click="click_dialog_change" 
        phx-value-increase="<%= opt[:event] %>">+</button>
      <div class="setting-selection-value"><%= opt[:value] %></div>
      <button 
        phx-click="click_dialog_change" 
        phx-value-decrease="<%= opt[:event] %>">-</button>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "setting")

    %{
      "override_timeout_seconds" => override_timeout_seconds,
      "filter_min_pump_time_seconds" => filter_min_pump_time_seconds
    } = SprinklerPi.Setting.get()

    state = [
      override_timeout_seconds: override_timeout_seconds,
      filter_min_pump_time_seconds: filter_min_pump_time_seconds,
      dialog_data: 0,
      dialog_type: "",
      edit_dialog_show: false,
      run_toon: false
    ]

    socket = assign(socket, page_title: "Setting")

    {:ok, assign(socket, state)}
  end

  def handle_event("click_edit_row", %{"type" => "override_timeout_seconds"}, socket) do
    {:noreply,
     assign(socket,
       dialog_data: socket.assigns.override_timeout_seconds,
       dialog_type: "override_timeout_seconds",
       edit_dialog_show: true
     )}
  end

  def handle_event("click_edit_row", %{"type" => "filter_min_pump_time_seconds"}, socket) do
    {:noreply,
     assign(socket,
       dialog_data: socket.assigns.filter_min_pump_time_seconds,
       dialog_type: "filter_min_pump_time_seconds",
       edit_dialog_show: true
     )}
  end

  def handle_event("click_dialog_close", _, socket) do
    {:noreply, assign(socket, edit_dialog_show: false)}
  end

  def handle_event("click_dialog_change", %{"increase" => "override_timeout_seconds"}, socket) do
    data = socket.assigns.dialog_data
    data = if data > 1800, do: 0, else: data + 15
    {:noreply, assign(socket, dialog_data: data)}
  end

  def handle_event("click_dialog_change", %{"decrease" => "override_timeout_seconds"}, socket) do
    data = socket.assigns.dialog_data
    data = if data <= 0, do: 1800, else: data - 15
    {:noreply, assign(socket, dialog_data: data)}
  end

  def handle_event("click_dialog_change", %{"increase" => "filter_min_pump_time_seconds"}, socket) do
    data = socket.assigns.dialog_data
    data = if data > 60, do: 0, else: data + 1
    {:noreply, assign(socket, dialog_data: data)}
  end

  def handle_event("click_dialog_change", %{"decrease" => "filter_min_pump_time_seconds"}, socket) do
    data = socket.assigns.dialog_data
    data = if data <= 0, do: 60, else: data - 1
    {:noreply, assign(socket, dialog_data: data)}
  end

  def handle_event("click_dialog_confirm", _, socket) do
    %{
      "override_timeout_seconds" => override_timeout_seconds,
      "filter_min_pump_time_seconds" => filter_min_pump_time_seconds
    } =
      if socket.assigns.dialog_type == "override_timeout_seconds" do
        SprinklerPi.Setting.set(%{"override_timeout_seconds" => socket.assigns.dialog_data})
      else
        SprinklerPi.Setting.set(%{"filter_min_pump_time_seconds" => socket.assigns.dialog_data})
      end

    {:noreply,
     assign(socket,
       edit_dialog_show: false,
       override_timeout_seconds: override_timeout_seconds,
       filter_min_pump_time_seconds: filter_min_pump_time_seconds
     )}
  end

  def handle_event("run_toon", _, socket) do
    Process.send_after(self(), :stop_toon, 4000)
    {:noreply, assign(socket, run_toon: true)}
  end

  def handle_info(:stop_toon, socket) do
    {:noreply, assign(socket, run_toon: false)}
  end

  def handle_info({"setting-change", %{"schedule" => schedule} = setting, _ts}, socket) do
    {:noreply, assign(socket, schedule: schedule, edit_dialog_show: false)}
  end
end
