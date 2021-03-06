defmodule Drab.Channel do
  require Logger
  @moduledoc false

  use Phoenix.Channel

  def join("__drab:" <> broadcast_topic, _, socket) do
    # socket already contains controller and action
    socket_with_topic = socket |> assign(:__broadcast_topic, broadcast_topic)

    {:ok, pid} = Drab.start_link(%Drab{store: %{}, session: %{}, 
      commander: Drab.get_commander(socket)})

    socket_with_pid = assign(socket_with_topic, :__drab_pid, pid)

    {:ok, socket_with_pid}
  end

  def handle_in("execjs", %{"ok" => [sender_encrypted, reply]}, socket) do
    # sender contains PID of the process which sent the query
    # sender is waiting for the result
    send(sender(socket, sender_encrypted), 
      {
        :got_results_from_client, reply
      })

    {:noreply, socket}
  end

  def handle_in("modal", %{"ok" => [sender_encrypted, reply]}, socket) do
    # sends { "button_name", %{"Param" => "value"}}
    send(sender(socket, sender_encrypted), 
      {
        :got_results_from_client, 
        { 
          reply["button_clicked"] |> String.to_existing_atom, 
          reply["params"] |> Map.delete("__drab_modal_hidden_input")
        }
      })

    {:noreply, socket}
  end

  def handle_in("waiter", %{"drab_waiter_token" => waiter_token, "sender" => sender}, socket) do
    {pid, ref} = Drab.Waiter.detokenize_waiter(socket, waiter_token)

    send(pid, {:waiter, ref, sender})

    {:noreply, socket}
  end

  def handle_in("onload", _, socket) do
    verify_and_cast(:onload, [], socket)
  end

  def handle_in("onconnect", _, socket) do
    # for debugging
    GenServer.cast(socket.assigns.__drab_pid, {:update_socket, socket})
    if IEx.started? do
      commander = Drab.get_commander(socket)
      modules = [Drab.Core] ++ commander.__drab__().modules
      p = inspect(socket.assigns.__drab_pid)
      pid_string = Regex.named_captures(~r/#PID<(?<pid>.*)>/, p) |> Map.get("pid")
      Logger.debug """

          Started Drab for #{socket.assigns.__broadcast_topic}, handling events in #{inspect(commander)}
          You may debug Drab functions in IEx by copy/paste the following:
      #{Enum.map(modules, fn module -> "import #{inspect(module)}" end) |> Enum.join("; ")}
      socket = GenServer.call(pid("#{pid_string}"), :get_socket)
      
          Examples:
      socket |> select(:htmls, from: "h4")
      socket |> execjs("alert('hello from IEx!')")
      socket |> alert("Title", "Sure?", buttons: [ok: "Azaliż", cancel: "Poniechaj"])
      """
    end

    verify_and_cast(:onconnect, [], socket)
  end

  def handle_in("event", %{
      "event" => event_name, 
      "payload" => payload, 
      "event_handler_function" => event_handler_function,
      "reply_to" => reply_to
      }, socket) do
    # event is currently not used (0.2.0)
    verify_and_cast(event_name, [payload, event_handler_function, reply_to], socket)
  end   

  defp verify_and_cast(event_name, params, socket) do
    p = [event_name, socket] ++ params
    GenServer.cast(socket.assigns.__drab_pid, List.to_tuple(p))
    {:noreply, socket}
  end

  defp sender(socket, sender_encrypted) do
    Drab.detokenize_pid(socket, sender_encrypted)
  end
end
