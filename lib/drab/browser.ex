defmodule Drab.Browser do
  import Drab.Core
  @moduledoc """
  Browser related functions.

  Provides information about connected browser, such as local datetime, user agent.
  """

  @doc """
  Returns local browser time as NaiveDateTime. Timezone information is not included.

  Examples:

      iex> Drab.Browser.now(socket)                                                  
      ~N[2017-04-01 15:07:57.027000]
  """
  def now(socket) do
    js = """
    var d = new Date()
    var retval = {
      year: d.getFullYear(),
      month: d.getMonth(),
      day: d.getDay(),
      hour: d.getHours(),
      minute: d.getMinutes(),
      second: d.getSeconds(),
      millisecond: d.getMilliseconds()
    }
    retval
    """
    browser_now = execjs(socket, js)
    {:ok, now} = NaiveDateTime.new(
      browser_now["year"],
      browser_now["month"],
      browser_now["day"],
      browser_now["hour"],
      browser_now["minute"],
      browser_now["second"],
      browser_now["millisecond"] * 1000
      )
    now
  end

  @doc """
  Returns utc offset (the difference between local browser time and UTC time), in seconds.

  Examples:

      iex> Drab.Browser.utc_offset(socket)
      7200 # UTC + 02:00
  """
  def utc_offset(socket) do
    -60 * execjs(socket, "new Date().getTimezoneOffset()")
  end


  # def utc_now(socket) do
  #   browser_utc = execjs(socket, "new Date().toISOString()")
  #   {:ok, now, _offset} = DateTime.from_iso8601(browser_utc)
  #   now
  # end


  @doc """
  Returns browser information (userAgent).

  Examples:

      iex> Drab.Browser.user_agent(socket)
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/537.36 (KHTML, like Gecko) ..."
  """
  def user_agent(socket) do
    execjs(socket, "navigator.userAgent")
  end

  @doc """
  Returns browser language.

  Example:
      iex> Drab.Browser.language(socket)  
      "en-GB"

  """
  def language(socket) do
    execjs(socket, "navigator.language")
  end

  @doc """
  Returns a list of browser supported languages.

  Example:
      iex> Drab.Browser.languages(socket)  
      ["en-US", "en", "pl"]

  """
  def languages(socket) do
    execjs(socket, "navigator.languages")
  end

  @doc """
  Redirects to the given url.

  WARNING: redirection will disconnect the current websocket, so it should be the last function launched in the
  handler.
  """
  def redirect_to(socket, url) do
    execjs(socket, "window.location = '#{url}'")
  end

  @doc """
  Broadcast version of `redirect_to`.

  WARNING: redirection will disconnect the current websocket, so it should be the last function launched in the
  handler.
  """
  def redirect_to!(socket, url) do
    broadcastjs(socket, "window.location = '#{url}'")
  end

  @doc """
  Sends the log to the browser console for debugging.
  """
  def console(socket, log) do
    do_console(socket, log, &Drab.push/4)
    socket
  end

  @doc """
  Broadcasts the log to the browser consoles for debugging/
  """
  def console!(socket, log) do
    do_console(socket, log, &Drab.broadcast/4)
  end

  defp do_console(socket, log, push_or_broadcast_function) do
    push_or_broadcast_function.(socket, self(), "console",  log: log)
  end

end
