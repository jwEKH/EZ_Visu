/*********************Konstanten*********************/
const SVG_NS = `http://www.w3.org/2000/svg`;
//Testbench
const ATTRIBUTES = {icon: `triangle`};//, iconPosition: `right`, signals: `AI1, AI17`};

/*********************VanillaDocReady*********************/
window.addEventListener('load', function () {
  window.reloadLiveDataIntervalId = setInterval(getLiveData, 1000, window.visuLiveData, window.projectNo);
  
  document.body.addEventListener(`mousedown`, mouseDownEventHandler);
  document.body.addEventListener(`mouseup`, mouseUpEventHandler);
  enterVisuEditor(true);
  
}, false);
/*********************GenericFunctions*********************/
function createSvgElement(symbole) {
  if (symbole === `triangle`) {
    const el = document.createElementNS(SVG_NS, `polygon`);
    el.setAttributeNS(null,`points`, `10,90 50,10 90,90`);
    el.setAttributeNS(null,`stroke`, `red`);
    el.setAttributeNS(null,`fill`, `none`);
    return el;
  }
}

function createVisuItem(...attributes) {
  //console.log(attributes);
  const visuItem = document.createElement(`div`);
  visuItem.classList.add(`visuItem`);
  
  
  attributes.forEach(attribute => {
    Object.entries(attribute).forEach(([key, value]) => {
      //console.log(`${key} ${value}`);

      //Save everything as attribute for .visu.txt file!
      visuItem.setAttribute(key, value);
      
      if (key.toLowerCase() === `icon`) {
        const divIcon = document.createElement(`div`);
        divIcon.classList.add(`divIcon`);
        visuItem.appendChild(divIcon);
        
        const svg = document.createElementNS(SVG_NS, `svg`);
        svg.setAttributeNS(null, `viewBox`, `0 0 100 100`);
        svg.appendChild(createSvgElement(value));
        divIcon.appendChild(svg);        
      }

      if (key.toLowerCase() === `signals`) {
        const divSignals = document.createElement(`div`);
        divSignals.classList.add(`divSignals`);
        visuItem.appendChild(divSignals); 

        value.split(`,`).forEach(signal => {
          //console.log(signal);
          const inpSignal = document.querySelector(`.${signal.trim()}`);
          
          const clonedSignal = inpSignal.cloneNode();
          divSignals.appendChild(clonedSignal);
          /*
          const input = document.createElement(`input`);
          input.classList.add(`signal`, signal.trim());
          input.type = `text`;
          input.value = signal.trim();
          divSignals.appendChild(input);
          //*/
        });
      }

    });    
  });

  return visuItem
}
/*********************EditorFunctions*********************/
function addDragDropEventHandler() {
  document.body.addEventListener(`dragstart`, dragStartEventHandler);
  document.body.addEventListener(`dragover`, dragOverEventHandler);
  document.body.addEventListener(`dragend`, dragEndEventHandler);
  document.body.addEventListener(`drop`, dropEventHandler);
}

function removeDragDropEventHandler() { 
  document.body.removeEventListener(`dragstart`, dragStartEventHandler);
  document.body.removeEventListener(`dragover`, dragOverEventHandler);
  document.body.removeEventListener(`dragend`, dragEndEventHandler);
  document.body.removeEventListener(`drop`, dropEventHandler);
}

function createSignalTable(visuLiveData) {
  const signalTable = document.createElement(`details`);
  signalTable.classList.add(`signalTable`, `visuEditElement`);
  signalTable.setAttribute(`open`, `true`);
  [`Drag`, `Edit`].forEach(option => {
    const radioBtn = document.createElement(`input`);
    radioBtn.type = `radio`;
    radioBtn.id = `radioBtn${option}`;
    radioBtn.name = `radioGroupSignalTable`;
    radioBtn.value = option.toLowerCase();
    radioBtn.checked = (option === `Drag`);
    radioBtn.addEventListener(`change`, (ev) => {
      const inpSignals = document.querySelectorAll(`.signalTable input[type='text']`);
      //console.log(inpSignals);
      inpSignals.forEach(el => {
        el.toggleAttribute(`disabled`);//, (ev.target.value === `drag`)));
        el.toggleAttribute(`draggable`);//, (ev.target.value === `drag`)));
      });
    });
    const lbl = document.createElement(`label`);
    lbl.setAttribute(`for`, radioBtn.id);
    lbl.innerText = option;
    signalTable.appendChild(radioBtn);
    signalTable.appendChild(lbl);
  });
  const summary = document.createElement(`summary`);
  summary.innerText = `Signale`;
  signalTable.appendChild(summary);
  
  if (visuLiveData) {
    //create table according to liveSignals
  }
  else {
    //create basic table (32 DI, 32 AI, 32 DO, 8 AO, CAN?)
    [`DI`, `AI`, `DO`, `AO`, `CAN`].forEach(signalGroup => {
      const details = document.createElement(`details`);
      details.classList.add(`signalGroup`, `${signalGroup}signals`);
      details.setAttribute(`open`, `true`);
      const summary = document.createElement(`summary`);
      summary.innerText = signalGroup;
      details.appendChild(summary);

      const channels =  (signalGroup === `AO`) ? 8 :
                        (signalGroup === `CAN`) ? 4 :
                        32;
      for (let i=1; i<=channels; i++) {
        const entry = document.createElement(`input`);
        entry.type = `text`;
        entry.classList.add(`${signalGroup}${i}`);
        entry.setAttribute(`disabled`, `true`);
        entry.setAttribute(`draggable`, `true`);
        entry.value = `${signalGroup}${i}`;
        details.appendChild(entry);
      }
      signalTable.appendChild(details);
    });
  }
  return signalTable;
}

function createVisuItemPool() {
  const visuItemPool = document.createElement(`details`);
  visuItemPool.classList.add(`visuItemPool`, `visuEditElement`);
  visuItemPool.setAttribute(`open`, `true`);
  const summary = document.createElement(`summary`);
  summary.innerText = `visuItems`;
  visuItemPool.appendChild(summary);
  visuItemPool.appendChild(createVisuItem(ATTRIBUTES));
  return visuItemPool;
}

function enterVisuEditor(initialCall) {
  if (initialCall) {
    document.body.appendChild(createSignalTable());
    document.body.appendChild(createVisuItemPool());
  }
  else {
    document.querySelectorAll(`.visuEditElement`).forEach(el => el.removeAttribute(`cloaked`));
  }

  document.querySelectorAll(`.visuItem`).forEach(el => el.setAttribute(`draggable`, `true`));
  addDragDropEventHandler();
}

function leaveVisuEditor() {
  document.querySelectorAll(`.visuEditElement`).forEach(el => el.setAttribute(`cloaked`, `true`));
  document.querySelectorAll(`[draggable]`).forEach(el => el.removeAttribute(`draggable`));
  removeDragDropEventHandler();
}
/*********************EventHandlers*********************/
function mouseDownEventHandler(ev) {
  const visuItem = ev.target.closest(`.visuItem`);
  if (visuItem && ev.buttons === 1)
    visuItem.setAttribute(`dragging`, `true`)
}

function mouseUpEventHandler(ev) {
  const visuItem = ev.target.closest(`.visuItem`);
  if (visuItem)
    visuItem.removeAttribute(`dragging`);
}

function dragStartEventHandler(ev) {
  const visuItem = ev.target.closest(`.visuItem`);
  if (visuItem) {
    const visuItemBox = visuItem.getBoundingClientRect();
    const offsetX = ev.x - visuItemBox.x;
    const offsetY = ev.y - visuItemBox.y;
    ev.dataTransfer.setData(`offsetX`, offsetX);
    ev.dataTransfer.setData(`offsetY`, offsetY);
  }
}

function dragOverEventHandler(ev) {
  ev.preventDefault();
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  if (draggingItem)
    ev.dataTransfer.dropEffect = (ev.ctrlKey || draggingItem.closest(`.visuItemPool`)) ? `copy` : `move`;
}

function dragEndEventHandler(ev) {
  const visuItem = ev.target.closest(`.visuItem`);
  if (visuItem)
    visuItem.removeAttribute(`dragging`);
}

function dropEventHandler(ev) {
  ev.preventDefault();
  const divVisu = ev.target.closest(`.divVisu`);
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  
  if (divVisu && draggingItem) {
    const dropItem = (ev.dataTransfer.dropEffect === `copy`) ? draggingItem.cloneNode(true) : draggingItem;
    dropItem.removeAttribute(`dragging`);
    divVisu.appendChild(dropItem);
    
    const divVisuBox = divVisu.getBoundingClientRect();
    const offsetX = ev.dataTransfer.getData(`offsetX`);
    const offsetY = ev.dataTransfer.getData(`offsetY`);
    
    dropItem.style.position = `absolute`;
    dropItem.style.left = `${ev.x - divVisuBox.x - offsetX}px`;
    dropItem.style.top = `${ev.y - divVisuBox.y - offsetY}px`;
  }
}

function visuItemEventHandler(ev) {
  //console.log(ev);
  const visuItem = ev.target.closest(`.visuItem`);
  
  //console.log(visuItem);
  if (ev.type.match(/(mousedown)/) && ev.buttons === 1) {
    //Cursor Appearance
    visuItem.setAttribute(`dragging`, `true`)
  }
  if (ev.type.match(/(mouseup|dragend)/)) {
    //Cursor Appearance
    visuItem.removeAttribute(`dragging`);
  }
  
}

function dropAreaEventHandler(ev) {
  ev.preventDefault();
  //console.log(ev);
  const divVisu = ev.target.closest(`.divVisu`);
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  if (ev.type.match(/(dragover)/)) {
    ev.dataTransfer.dropEffect = (ev.ctrlKey || draggingItem.closest(`.visuItemPool`)) ? `copy` : `move`;
  }
  if (ev.type.match(/(drop)/)) {
    const dropItem = (ev.dataTransfer.dropEffect === `copy`) ? draggingItem.cloneNode(true) : draggingItem;
    divVisu.appendChild(dropItem);
    
    const divVisuBox = divVisu.getBoundingClientRect();
    const offsetX = ev.dataTransfer.getData(`offsetX`);
    const offsetY = ev.dataTransfer.getData(`offsetY`);
    //console.log(offsetX, offsetY);
    dropItem.style.position = `absolute`;
    dropItem.style.left = `${ev.x - divVisuBox.x - offsetX}px`;
    dropItem.style.top = `${ev.y - divVisuBox.y - offsetY}px`;
  }
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