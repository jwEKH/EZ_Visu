//Testbench
const attributes = [];
attributes.push({'rotation': `0`, 'val1': `AAUS(27)`, 'val2': `AA(7)`});


//Vanilla DocReady
window.addEventListener('load', function () {
  const draggableItems = document.querySelectorAll(`[draggable]`);
  draggableItems.forEach(draggableItem => {
    //Cursor Appearance
    draggableItem.addEventListener(`mousedown`, () => {
      draggableItem.setAttribute(`dragging`,`true`);
    });
    draggableItem.addEventListener(`mouseup`, () => {
      draggableItem.removeAttribute(`dragging`);
    });
    draggableItem.addEventListener(`dragend`, () => {
      draggableItem.removeAttribute(`dragging`);
    });
    draggableItem.addEventListener(`dragstart`, (ev) => {
      console.log(ev);
      //const box = ev.target.getBoundingClientRect();
      //console.log(box);
      const parentOfTarget = ev.target.parentElement;
      const originIsDivPool = parentOfTarget.classList.contains(`divPool`);
      const offsetX = (originIsDivPool) ? ev.layerX - parentOfTarget.offsetLeft : ev.layerX;
      const offsetY = (originIsDivPool) ? ev.layerY - parentOfTarget.offsetTop : ev.layerY;
      ev.dataTransfer.setData(`offsetX`, offsetX);
      ev.dataTransfer.setData(`offsetY`, offsetY);
    });
  });

  const dropAllowedAreas = document.querySelectorAll(`.divVisu`);
  dropAllowedAreas.forEach(dropAllowedArea => {
    dropAllowedArea.addEventListener(`dragover`, (ev) => {
      ev.preventDefault();
      const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
      ev.dataTransfer.dropEffect = (ev.ctrlKey | draggingItem.parentElement.classList.contains(`divPool`)) ? `copy` : `move`;
    });
    dropAllowedArea.addEventListener(`drop`, (ev) => {
      //console.log(ev);
      ev.preventDefault();
      const {dataTransfer, layerX, layerY, target} = ev;
      //console.log(target);
      //console.log(dataTransfer);
      //const draggingItem = dataTransfer.getData(`item`);
      const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
      //console.log(dataTransfer.dropEffect);
      if (dataTransfer.dropEffect === `copy`) {
        //dropAllowedArea.appendChild(structuredClone(draggingItem));
        dropAllowedArea.appendChild(draggingItem);
      }
      else {
        dropAllowedArea.appendChild(draggingItem);
      }

      const offsetX = dataTransfer.getData(`offsetX`);
      const offsetY = dataTransfer.getData(`offsetY`);
      //console.log(offsetX, offsetY);
      draggingItem.style.position = `absolute`;
      draggingItem.style.left = `${layerX - offsetX}px`;
      draggingItem.style.top = `${layerY - offsetY}px`;
    });
  });
  
  
  
  
  
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

  /*
  const divIcon = document.createElement(`div`);
  divIcon.classList.add(`divIcon`);
  visuItem.appendChild(divIcon);
  */
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