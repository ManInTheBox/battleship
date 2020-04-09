let grid = document.getElementById('grid');
let ships = document.getElementById('ships');

for (let i = 1; i <= 10; i++) {
  let tr = document.createElement('tr');

  for (let j = 1; j <= 10; j++) {
    let td = document.createElement('td');
    let square = `${i}-${j}`
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
}

grid.append(ships);

export default grid;
