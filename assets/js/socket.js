import {Socket} from "phoenix";

let socket = new Socket("/socket", {params: {token: window.userToken}});
socket.connect();

const getUser = () => document.cookie.replace('user_id=', '');

export function gameSocket() {
  if (!document.URL.includes('/game')) return;

  let matches = document.URL.match(/.*\/game\/(?<gameId>.*)/);
  if (!matches) return;

  let gameId = matches.groups.gameId;
  if (!gameId) return;

  let channel = socket.channel(`game:${gameId}`, {})

  channel.on("game_started", payload => {
    document.querySelector('.alert-info').classList.add('hidden');
    const successAlert = document.querySelector('.alert-success');
    successAlert.classList.remove('hidden');
    successAlert.classList.add('visible');
    successAlert.innerHTML = payload.message;
    setTimeout(() => successAlert.classList.add('hidden'), 5000);

    if (payload.is_my_turn) {
      document.getElementById('opponent-grid').classList.remove('disabled');
    }
  });

  channel.on("fire_torpedo_water", payload => {
    if (payload.user === getUser()) {
      document.getElementById(`opponent_square_${payload.square}`).classList.add('water');
      document.querySelector(`[data-player="${payload.user}"] #opponent-grid`).classList.add('disabled');
    } else {
      document.getElementById(`my_square_${payload.square}`).classList.add('water');
      document.querySelector(`[data-player="${payload.other_user}"] #opponent-grid`).classList.remove('disabled');
    }
  });

  channel.on("fire_torpedo_hit", payload => {
    if (payload.user === getUser()) {
      document.getElementById(`opponent_square_${payload.square}`).classList.add('hit');
    } else {
      document.getElementById(`my_square_${payload.square}`).classList.add('hit');
    }
  });

  channel.on("fire_torpedo_sunk", payload => {
    if (payload.user === getUser()) {
      JSON.parse(payload.squares).forEach(([square]) => {
        document.getElementById(`opponent_square_${square}`).classList.remove('alive', 'hit');
        document.getElementById(`opponent_square_${square}`).classList.add('sunk');
      });
    } else {
      JSON.parse(payload.squares).forEach(([square]) => {
        document.getElementById(`my_square_${square}`).classList.remove('alive', 'hit');
        document.getElementById(`my_square_${square}`).classList.add('sunk');
      });
    }
  });

  channel.join();

  return channel;
}
