export function createEmptyGrid() {
  let grid = document.getElementById('new-grid');

  if (!grid) {
    return;
  }

  let ships = document.getElementById('ships');

  let colsHeading = document.createElement('tr');

  for (const char of [...' ABCDEFGHIJ']) {
    let td = document.createElement('th');
    td.innerHTML = char;
    colsHeading.appendChild(td)
  }

  grid.appendChild(colsHeading);

  for (let i = 1; i <= 10; i++) {
    let tr = document.createElement('tr');

    for (let j = 1; j <= 10; j++) {
      let td = document.createElement('td');
      let square = `${j}-${i}`
      td.id = `square_${square}`;

      tr.appendChild(td);

      td.addEventListener('click', event => {
        if (event.target.classList[0] === 'occupied') {
          event.target.style.backgroundColor = '#ffffff';
          ships.value = ships.value.replace(`${square} `, '');
        } else {
          ships.value += `${square} `;
          event.target.style.backgroundColor = '#0000ff';
        }

        event.target.classList.toggle('occupied');
      })
    }

    grid.appendChild(tr);

    let rowsHeading = document.createElement('td');
    rowsHeading.className = 'rows-heading';
    rowsHeading.innerHTML = i;
    tr.insertBefore(rowsHeading, document.getElementById(`square_1-${i}`));
  }

  for (const id of ships.value.split(' ').filter(Boolean)) {
    const td = document.getElementById(`square_${id}`);
    td.style.backgroundColor = '#0000ff';
    td.classList.add('occupied');
  }

  grid.append(ships);
}

export function createMyGrid() {
  let grid = document.getElementById('my-grid');

  if (!grid) {
    return;
  }

  let colsHeading = document.createElement('tr');

  for (const char of [...' ABCDEFGHIJ']) {
    let td = document.createElement('th');
    td.innerHTML = char;
    colsHeading.appendChild(td)
  }

  grid.appendChild(colsHeading);

  for (let i = 1; i <= 10; i++) {
    let tr = document.createElement('tr');

    for (let j = 1; j <= 10; j++) {
      let td = document.createElement('td');
      let square = `${j}-${i}`
      td.id = `my_square_${square}`;

      tr.appendChild(td);
    }

    grid.appendChild(tr);

    let rowsHeading = document.createElement('td');
    rowsHeading.className = 'rows-heading';
    rowsHeading.innerHTML = i;
    tr.insertBefore(rowsHeading, document.getElementById(`my_square_1-${i}`));
  }

  for (const square of JSON.parse(grid.dataset.squares)) {
    document.getElementById(`my_square_${square[0]}`).classList.add(square[1]);
  }
}

export function createOpponentGrid(channel) {
  if (!document.URL.includes('/game')) return;

  let matches = document.URL.match(/.*\/game\/(?<gameId>.*)/);
  if (!matches) return;

  let gameId = matches.groups.gameId;
  if (!gameId) return;

  let grid = document.getElementById('opponent-grid');

  if (!grid) {
    return;
  }

  let colsHeading = document.createElement('tr');

  for (const char of [...' ABCDEFGHIJ']) {
    let td = document.createElement('th');
    td.innerHTML = char;
    colsHeading.appendChild(td)
  }

  grid.appendChild(colsHeading);

  for (let i = 1; i <= 10; i++) {
    let tr = document.createElement('tr');

    for (let j = 1; j <= 10; j++) {
      let td = document.createElement('td');
      let square = `${j}-${i}`
      td.id = `opponent_square_${square}`;

      tr.appendChild(td);

      td.addEventListener('click', event => {
        if (grid.classList.contains('disabled')) {
          return;
        }

        if (event.target.classList.contains('water') || event.target.classList.contains('hit') || event.target.classList.contains('sunk')) {
          return;
        }

        const user = document.cookie.replace('user_id=', '');

        channel.push('fire_torpedo', {game_id: gameId, square: square, user: user});
      })
    }

    grid.appendChild(tr);

    let rowsHeading = document.createElement('td');
    rowsHeading.className = 'rows-heading';
    rowsHeading.innerHTML = i;
    tr.insertBefore(rowsHeading, document.getElementById(`opponent_square_1-${i}`));
  }

  for (const square of JSON.parse(grid.dataset.squares)) {
    document.getElementById(`opponent_square_${square[0]}`)?.classList.add(square[1]);
  }
}
