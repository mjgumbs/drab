## 0.2.1
Introduced Drab Session: the way to access (read-only) the Plug Session map in event handlers.

Changes:
* `use Drab.Endpoint` instead of `socket Drab.config.socket, Drab.Socket` in endpoint.ex
* session access for specified session keys

Fixes:
* security (#2): checks token on each event call


## 0.2.0 (2017-01-22)
This version cames with refactored modules and client JS library. It is now modular, so you don't need
to use jQuery and DOM if you don't have to.

Changes:
* extracted Drab core; split the JS templates between modules
* jQuery not required in Drab.Core
* moved Drab.Query.execjs and broadcastjs to Drab.Core.execjs and broadcastjs
* moved Drab.Call.console to Drab.Core.console (and console!)
* renamed Drab.Call to Drab.Modal
* renamed Drab.Templates to Drab.Template
* JS: Drab is global, Drab.launch_event() is available

## 0.1.1

Changes:
* added more jQuery methods, like width, position, etc
* cycling
    update(:text, set: ["One", "Two", "Three"], on: "#thebutton")
    update(:class, set: ["btn-success", "btn-danger"], on: "#save_button")
* toggling class
    update(:class, toggle: "btn-success", on: "#btn")

Fixes:
* atom leaking issue (#1)