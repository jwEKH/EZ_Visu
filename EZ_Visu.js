//Testbench
const attributes = [];
attributes.push({'rotation': `0`, 'val1': `AAUS(27)`, 'val2': `AA(7)`});


//Vanilla DocReady
window.addEventListener('load', function () {
  /*
  const divPool = document.querySelector(`.pool`);
  divPool.appendChild(createVisuItem(attributes));

  Array.from(document.querySelector(`svg`).children).forEach(el => {
    el.draggable = `true`;
    el.addEventListener(`click`, (ev) => ev.target.toggleAttribute(`selected`));
    el.addEventListener(`mousedown`, (ev) => {
      console.log(ev);
    });//.target.setAttribute(`dragging`));
    
    /*el.addEventListener(`mousemove`, (ev) => {
      const {target} = ev;
      console.log(ev);
    });
  });
  */
}, false);

function createVisuItem(_attributes) {
  const visuItem = document.createElement(`div`);
  visuItem.classList.add(`visuItem`);

  const divIcon = document.createElement(`div`);
  divIcon.classList.add(`divIcon`);
  visuItem.appendChild(divIcon);

  const divValues = document.createElement(`div`);
  divValues.classList.add(`divValues`);
  visuItem.appendChild(divValues);

  if(_attributes) _attributes.forEach(attribute => {
    Object.entries(attribute).forEach(([key, value]) => {
      visuItem.setAttribute(key, value);

      if (key.startsWith(`val`)) {
        const input = document.createElement(`input`);
        input.classList.add(`val`, key);
        input.type = `text`;
        input.value = value;
        divValues.appendChild(input);
      }

      //console.log(`${key} ${value}`);
    });    
  });
  /*
  Object.entries(animals).forEach(([key, value]) => {
    console.log(`${key}: ${value}`)
  });
  //*/

  return visuItem
}

function drag(ev) {
  ev.dataTransfer.dropEffect = "copy";
  ev.dataTransfer.setData("text/plain", ev.target.id);
}
function allowDrop(ev) {
  ev.preventDefault();
  ev.dataTransfer.dropEffect = "copy";
}
function drop(ev) {
  ev.preventDefault();
  // Get the id of the target and add the moved element to the target's DOM
  const data = ev.dataTransfer.getData("text/plain");
  ev.target.appendChild(document.querySelector(`#${data}`));
}