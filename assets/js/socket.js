import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

export function gameSocket() {
  if (!document.URL.includes('/game')) return;

  let matches = document.URL.match(/.*\/game\/(?<gameId>.*)/);
  if (!matches) return;

  let gameId = matches.groups.gameId;
  if (!gameId) return;

  let channel = socket.channel(`game:${gameId}`, {})

  // let chatInput = document.querySelector("#chat-input")
  // let messagesContainer = document.querySelector("#messages")

  // chatInput.addEventListener("keypress", event => {
  //   if(event.keyCode === 13){
  //     channel.push("new_msg", {body: chatInput.value})
  //     chatInput.value = ""
  //   }
  // })

  channel.on("game_started", payload => {
    console.log(payload)
    document.querySelector('.alert-info').classList.add('hidden');
    const successAlert = document.querySelector('.alert-success');
    successAlert.classList.remove('hidden');
    successAlert.classList.add('visible');
    successAlert.innerHTML = payload.message;
    setTimeout(() => successAlert.classList.add('hidden'), 5000);
  })

  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
}
