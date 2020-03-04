defmodule SprinklerPiUiWeb.ScheduleLive do
  use Phoenix.LiveView
  import SprinklerPiUiWeb.Gettext
  alias SprinklerPiUiWeb.Router.Helpers, as: Routes

  @weekday_list [
    gettext("Mon"),
    gettext("Tue"),
    gettext("Wed"),
    gettext("Thu"),
    gettext("Fri"),
    gettext("Sat"),
    gettext("Sun")
  ]

  def render(assigns) do
    ~L"""
    <div class="schedule-container">
      <div class="schedule-list">
      <%= for {s_id, weekday, hour, minute, duration} <- @schedule do %>
        <div class="schedule-row flex">
          <button class="schedule-button-delete" phx-click="click_delete_row" value="<%= s_id %>">✘</button>
          <span class="schedule-text">
            <%= gettext("%{w} - %{h}:%{m}", w: weekday_to_text(weekday), h: pad_time(hour), m: pad_time(minute)) %>
            <%= gettext("%{d} min", d: round(duration / 60)) %>
          </span>
          <button class="schedule-button-edit" phx-click="click_edit_row" value="<%= s_id %>">✎</button>
        </div>
        <hr />
      <% end %>
      </div>
      <div class="schedule-add">
        <button class="schedule-add__button" phx-click="click_add_schedule">
        <span class="schedule-add__icon">+</span>
        <%= gettext "Add Schedule" %></button>
      </div>
    </div>
    <%= if @add_dialog_show or @edit_dialog_show do render_dialog(assigns) end %>
    """
  end

  def render_dialog(assigns) do
    {id, weekday, hour, minute, duration} = assigns.dialog_data
    weekday_text = Enum.at(@weekday_list, weekday - 1)
    hour_text = pad_time(hour)
    minute_text = pad_time(minute)
    duration_text = gettext("%{d} min", d: duration)

    ~L"""
     <div class="schedule-dialog" tabindex="-1" phx-click="click_dialog_close">
       <div class="schedule-dialog-container" phx-click>
         <h2><%= if @edit_dialog_show do gettext("Edit") else gettext("Add") end %></h2> 
         <div class="schedule-dialog-input">
           <%= render_selection(assigns, title: gettext("Weekday"), event: "weekday", value: weekday_text) %>
           <%= render_selection(assigns, title: gettext("Hour"), event: "hour", value: hour_text) %>
           <%= render_selection(assigns, title: gettext("Minute"), event: "minute", value: minute_text) %>
           <%= render_selection(assigns, title: gettext("Duration"), event: "duration", value: duration_text) %>
         </div>
         <%= if @edit_dialog_show do %>
         <button class="schedule-dialog-confirm" phx-click="click_dialog_confirm"><%= gettext("Confirm") %></button>
         <% else %>
         <button class="schedule-dialog-add" phx-click="click_dialog_add"><%= gettext("Add") %></button>
         <% end %>
       </div>
     </div>
    """
  end

  def render_selection(assigns, opt) do
    ~L"""
    <div class="schedule-selection-container">
      <div class="schedule-selection-title"><%= opt[:title] %></div>
      <button
        phx-click="click_dialog_change" 
        phx-value-increase="<%= opt[:event] %>">+</button>
      <div class="schedule-selection-value"><%= opt[:value] %></div>
      <button 
        phx-click="click_dialog_change" 
        phx-value-decrease="<%= opt[:event] %>">-</button>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "setting")
    %{"schedule" => schedule} = SprinklerPi.Setting.get()

    state = [
      schedule: sort_schedule(schedule),
      dialog_data: {nil, 1, 12, 0, 1},
      add_dialog_show: false,
      edit_dialog_show: false
    ]

    socket = assign(socket, page_title: "Schedule Setting")

    {:ok, assign(socket, state)}
  end

  def handle_event("click_delete_row", %{"value" => s_id}, socket) do
    %{"schedule" => schedule} = SprinklerPi.Setting.get()

    schedule =
      schedule
      |> Enum.filter(fn {el_id, _, _, _, _} -> to_string(el_id) != s_id end)
      |> sort_schedule()

    %{"schedule" => schedule} = SprinklerPi.Setting.set(%{"schedule" => schedule})
    {:noreply, assign(socket, schedule: schedule)}
  end

  def handle_event("click_edit_row", %{"value" => s_id}, socket) do
    data = Enum.find(socket.assigns.schedule, fn {id, _, _, _, _} -> to_string(id) == s_id end)
    duration_seconds = elem(data, 4)
    data = put_elem(data, 4, round(duration_seconds / 60))
    {:noreply, assign(socket, dialog_data: data, add_dialog_show: false, edit_dialog_show: true)}
  end

  def handle_event("click_add_schedule", _, socket) do
    {:noreply,
     assign(socket,
       dialog_data: {nil, 1, 12, 0, 1},
       add_dialog_show: true,
       edit_dialog_show: false
     )}
  end

  def handle_event("click_dialog_close", _, socket) do
    {:noreply, assign(socket, add_dialog_show: false, edit_dialog_show: false)}
  end

  def handle_event("click_dialog_change", %{"increase" => element}, socket) do
    idx =
      case element do
        "weekday" -> 1
        "hour" -> 2
        "minute" -> 3
        "duration" -> 4
      end

    data = socket.assigns.dialog_data
    value = elem(data, idx)
    data = put_elem(data, idx, increase(element, value))
    {:noreply, assign(socket, dialog_data: data)}
  end

  def handle_event("click_dialog_change", %{"decrease" => element}, socket) do
    idx =
      case element do
        "weekday" -> 1
        "hour" -> 2
        "minute" -> 3
        "duration" -> 4
      end

    data = socket.assigns.dialog_data
    value = elem(data, idx)
    data = put_elem(data, idx, decrease(element, value))
    {:noreply, assign(socket, dialog_data: data)}
  end

  def handle_event("click_dialog_confirm", _, socket) do
    edit_id = elem(socket.assigns.dialog_data, 0)

    edited_schedule =
      put_elem(socket.assigns.dialog_data, 4, elem(socket.assigns.dialog_data, 4) * 60)

    %{"schedule" => schedule} = SprinklerPi.Setting.get()

    schedule =
      schedule
      |> Enum.map(fn {el_id, _, _, _, _} = el ->
        if el_id == edit_id, do: edited_schedule, else: el
      end)
      |> sort_schedule()

    %{"schedule" => schedule} = SprinklerPi.Setting.set(%{"schedule" => schedule})

    {:noreply,
     assign(socket, schedule: schedule, add_dialog_show: false, edit_dialog_show: false)}
  end

  def handle_event("click_dialog_add", _, socket) do
    new_schedule =
      socket.assigns.dialog_data
      |> put_elem(0, System.unique_integer())
      |> put_elem(4, elem(socket.assigns.dialog_data, 4) * 60)

    %{"schedule" => schedule} = SprinklerPi.Setting.get()
    schedule = sort_schedule(schedule ++ [new_schedule])

    %{"schedule" => schedule} = SprinklerPi.Setting.set(%{"schedule" => schedule})

    {:noreply,
     assign(socket, schedule: schedule, add_dialog_show: false, edit_dialog_show: false)}
  end

  def handle_info({"setting-change", %{"schedule" => schedule} = setting, _ts}, socket) do
    {:noreply, assign(socket, schedule: schedule, edit_dialog_show: false)}
  end

  defp sort_schedule(schedule),
    do: Enum.sort_by(schedule, fn {_, w, h, m, _} -> w * 1000 + h * 100 + m end)

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

  defp increase("weekday", 7), do: 1
  defp increase("weekday", value), do: value + 1
  defp decrease("weekday", 1), do: 7
  defp decrease("weekday", value), do: value - 1

  defp increase("hour", 23), do: 0
  defp increase("hour", value), do: value + 1
  defp decrease("hour", 0), do: 23
  defp decrease("hour", value), do: value - 1

  defp increase("minute", 59), do: 0
  defp increase("minute", value), do: value + 1
  defp decrease("minute", 0), do: 59
  defp decrease("minute", value), do: value - 1

  defp increase("duration", 120), do: 1
  defp increase("duration", value), do: value + 1
  defp decrease("duration", 1), do: 120
  defp decrease("duration", value), do: value - 1
end
