// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/live", Socket);

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

import { createEmptyGrid, createMyGrid, createOpponentGrid } from "./grid"
import { gameSocket } from "./socket"

createEmptyGrid();
createMyGrid();

const channel = gameSocket();

createOpponentGrid(channel);

(() => {
  setTimeout(() => {
    document.querySelectorAll('.alert').forEach(alert => {
      if (alert.classList.contains('visible')) return;
      alert.classList.add('hidden');
    });
  }, 5000);
})();
