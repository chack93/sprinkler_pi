import css from "../css/app.scss"
import "phoenix_html"
import {
  Socket
} from "phoenix"
import LiveSocket from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: {
    _csrf_token: csrfToken
  }
});
liveSocket.connect()


// prevent ios safari double-tap zoom
let lastTouchend = 0
document.addEventListener("touchend", e => {
  const now = Date.now()
  if (e.target.tagName !== "BUTTON" && now - lastTouchend < 300)
    e.preventDefault()
  lastTouchend = now
})
