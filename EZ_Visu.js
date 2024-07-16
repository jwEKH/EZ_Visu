//Testbench
const attributes = [];
attributes.push({'rotation': `0`, 'val1': `AAUS(27)`, 'val2': `AA(7)`});


//Vanilla DocReady
window.addEventListener('load', function () {
  window.reloadLiveDataIntervalId = setInterval(getLiveData, 1000, window.visuLiveData, window.projectNo);
  
  enterVisuEditor(); 
  
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
/*********************EditorFunctions*********************/
function visuItemEventHandler(ev) {
  const {type, target, buttons, layerX, layerY} = ev;
  if (type.match(/(mousedown)/) && buttons === 1) {
    //Cursor Appearance
    ev.target.setAttribute(`dragging`, `true`)
  }
  if (type.match(/(mouseup|dragend)/)) {
    //Cursor Appearance
    target.removeAttribute(`dragging`);
  }
  if (type.match(/(dragstart)/)) {
    const parentOfTarget = target.parentElement;
    const originIsDivPool = parentOfTarget.classList.contains(`divPool`);
    const offsetX = (originIsDivPool) ? layerX - parentOfTarget.offsetLeft : layerX;
    const offsetY = (originIsDivPool) ? layerY - parentOfTarget.offsetTop : layerY;
    ev.dataTransfer.setData(`offsetX`, offsetX);
    ev.dataTransfer.setData(`offsetY`, offsetY);
  }
  
  console.log(ev);
  //el.toggleAttribute(`dragging`)
}

function dropAreaEventHandler(ev) {
  ev.preventDefault();
  const {type, target, dataTransfer, layerX, layerY} = ev;
  if (type.match(/(dragover)/)) {
    const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
    dataTransfer.dropEffect = (ev.ctrlKey | draggingItem.parentElement.classList.contains(`divPool`)) ? `copy` : `move`;
  }
  if (type.match(/(drop)/)) {
    ev.preventDefault();
    const {dataTransfer, layerX, layerY, target} = ev;
    const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
    if (dataTransfer.dropEffect === `copy`) {
      //dropAllowedArea.appendChild(structuredClone(draggingItem));
      this.appendChild(draggingItem);
    }
    else {
      //dropAllowedArea.appendChild(draggingItem);
      this.appendChild(draggingItem);
    }

    const offsetX = dataTransfer.getData(`offsetX`);
    const offsetY = dataTransfer.getData(`offsetY`);
    //console.log(offsetX, offsetY);
    draggingItem.style.position = `absolute`;
    draggingItem.style.left = `${layerX - offsetX}px`;
    draggingItem.style.top = `${layerY - offsetY}px`;
  }
}

function enterVisuEditor() {
  const draggableItems = document.querySelectorAll(`[draggable]`);
  draggableItems.forEach(draggableItem => {
    draggableItem.addEventListener(`mousedown`, visuItemEventHandler);
    draggableItem.addEventListener(`mouseup`, visuItemEventHandler);
    draggableItem.addEventListener(`dragend`, visuItemEventHandler);
    draggableItem.addEventListener(`dragstart`, visuItemEventHandler);
  });

  const dropAllowedAreas = document.querySelectorAll(`.divVisu`);
  dropAllowedAreas.forEach(dropAllowedArea => {
    dropAllowedArea.addEventListener(`dragover`, dropAreaEventHandler);
    dropAllowedArea.addEventListener(`drop`, dropAreaEventHandler);
  });
}






/*********************ComFunctions*********************/
function getLiveData(visuLiveData, projectNo) {
  visuLiveData = (!projectNo) ? undefined : fetchData();
  console.log(`getLiveData: ${visuLiveData}`);
  if (!visuLiveData) {
    console.log(`stopped reloadLiveDataInterval!`);
    clearInterval(window.reloadLiveDataIntervalId);
  }
}

function fetchData() {
  console.log(`fetchData`);
}