// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

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
createOpponentGrid();

gameSocket();

(() => {
  setTimeout(() => {
    document.querySelectorAll('.alert').forEach(alert => {
      if (alert.classList.contains('visible')) return;
      alert.classList.add('hidden');
    });
  }, 5000);
})();
