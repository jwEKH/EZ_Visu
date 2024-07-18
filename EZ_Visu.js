/*********************Konstanten*********************/
const SVG_NS = `http://www.w3.org/2000/svg`;
//Testbench
const ATTRIBUTES = {icon: `pumpe`};//, iconPosition: `right`, signals: `AI1, AI17`};

/*********************VanillaDocReady*********************/
window.addEventListener('load', function () {
  window.reloadLiveDataIntervalId = setInterval(getLiveData, 1000, window.visuLiveData, window.projectNo);
  
  document.body.addEventListener(`mousedown`, mouseDownEventHandler);
  document.body.addEventListener(`mouseup`, mouseUpEventHandler);
  document.body.addEventListener(`input`, inputEventHandler);
  enterVisuEditor(true);
  
}, false);
/*********************GenericFunctions*********************/
function createSvg(symbole) {
  if (symbole) {
    const svg = document.createElementNS(SVG_NS, `svg`);
    svg.setAttributeNS(null, `viewBox`, `0 0 100 100`);
    if (symbole === `triangle`) {
      const el = document.createElementNS(SVG_NS, `polygon`);
      el.setAttributeNS(null,`stroke`, `red`);
      el.setAttributeNS(null,`fill`, `none`);
      el.setAttributeNS(null,`points`, `10,90 50,10 90,90`);
      svg.appendChild(el);
    }
    if (symbole === `pumpe`) {
      let el = document.createElementNS(SVG_NS, `circle`);
      el.setAttributeNS(null,`stroke`, `red`);
      el.setAttributeNS(null,`fill`, `none`);
      el.setAttributeNS(null, `cx`, `50`);
      el.setAttributeNS(null, `cy`, `50`);
      el.setAttributeNS(null, `r`, `40`);
      svg.appendChild(el);
      
      el = document.createElementNS(SVG_NS, `polyline`);
      el.setAttributeNS(null,`stroke`, `red`);
      el.setAttributeNS(null,`fill`, `none`);
      el.setAttributeNS(null,`points`, `10,50 50,10 90,50`);
      svg.appendChild(el);
    }
    return svg;
  }
}

function createVisuItem(...attributes) {
  //console.log(attributes);
  const visuItem = document.createElement(`div`);
  visuItem.classList.add(`visuItem`);
  
  const divIcon = document.createElement(`div`);
  divIcon.classList.add(`divIcon`);
  visuItem.appendChild(divIcon);
  
  const divSignals = document.createElement(`div`);
  divSignals.classList.add(`divSignals`);
  visuItem.appendChild(divSignals);

  attributes.forEach(attribute => {
    Object.entries(attribute).forEach(([key, value]) => {
      //console.log(`${key} ${value}`);

      //Save everything as attribute for .visu.txt file!
      visuItem.setAttribute(key, value);
      
      if (key.toLowerCase() === `icon`) {
        divIcon.appendChild(createSvg(value));        
      }

      if (key.toLowerCase() === `signals`) {
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
        //el.toggleAttribute(`disabled`);//, (ev.target.value === `drag`)));
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
        //entry.setAttribute(`disabled`, `true`);
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
  if (ev.buttons === 1) {
    const target = (ev.target.type === `text`) ? ev.target : ev.target.closest(`.visuItem`);
    if (target)
      target.setAttribute(`dragging`, `true`);
  }
}

function mouseUpEventHandler(ev) {
  document.querySelectorAll(`[dragging]`).forEach(el => el.removeAttribute(`dragging`));
}

function dragStartEventHandler(ev) {
  //console.log(ev);
  const target = (ev.target.type === `text`) ? ev.target : ev.target.closest(`.visuItem`);
  if (target) {
    target.setAttribute(`dragging`, `true`);
    const targetBox = target.getBoundingClientRect();
    const offsetX = ev.x - targetBox.x;
    const offsetY = ev.y - targetBox.y;
    ev.dataTransfer.clearData();
    ev.dataTransfer.setData(`offsetX`, offsetX);
    ev.dataTransfer.setData(`offsetY`, offsetY);
  }
}

function dragOverEventHandler(ev) {
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  if (draggingItem) {
    if ((ev.target.closest(`.divVisu`) && draggingItem.classList.contains(`visuItem`)) || (!ev.target.closest(`.visuEditElement`) && ev.target.closest(`.visuItem`) && draggingItem.type === `text`)) {
      ev.preventDefault();
      //console.log(ev.target);
      ev.dataTransfer.dropEffect = (ev.ctrlKey || draggingItem.closest(`.visuEditElement`)) ? `copy` : `move`;
    }
  }
}

function dragEndEventHandler(ev) {
  document.querySelectorAll(`[dragging]`).forEach(el => el.removeAttribute(`dragging`));
}

function dropEventHandler(ev) {
  //ev.preventDefault();
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  const target = (draggingItem.type === `text`) ? ev.target/*.closest(`.visuItem`)/*.querySelector(`.divSignals`)*/ : ev.target.closest(`.divVisu`);
  if (target && draggingItem) {
    const dropItem = (ev.dataTransfer.dropEffect === `copy`) ? draggingItem.cloneNode(true) : draggingItem;
    
    if (target.classList.contains(`divVisu`)) {
      const targetBox = target.getBoundingClientRect();
      const offsetX = ev.dataTransfer.getData(`offsetX`);
      const offsetY = ev.dataTransfer.getData(`offsetY`);
      
      dropItem.style.position = `absolute`;
      dropItem.style.left = `${ev.x - targetBox.x - offsetX}px`;
      dropItem.style.top = `${ev.y - targetBox.y - offsetY}px`;
      target.appendChild(dropItem);
    }
    else {
      console.log(target);
      const visuItem = target.closest(`.visuItem`);
      if (visuItem) {
        const divIcon = target.closest(`.divIcon`);
        if (divIcon) {
          const divIconBox = divIcon.getBoundingClientRect();
          divIconBox.xCenter = divIconBox.x + divIconBox.width/2;
          divIconBox.yCenter = divIconBox.y + divIconBox.height/2;
          const deltaX = ev.x - divIconBox.xCenter;
          const deltaY = ev.y - divIconBox.yCenter;
          const maxDelta = Math.max(Math.abs(deltaX), Math.abs(deltaY));
          const iconPosition =  (maxDelta === deltaX) ? `left` :
          (maxDelta === -deltaX) ? `right` :
          (maxDelta === deltaY) ? `top` :
          `bottom`;
          //console.log(divIconBox);
          visuItem.setAttribute(`iconPosition`, iconPosition);        
        }

        const divSignals = visuItem.querySelector(`.divSignals`);
        const insertBeforeNode = (target.closest(`.divSignals`)) ? target : divSignals.firstElementChild;
        divSignals.appendChild(dropItem);
      }
    }
  }

  document.querySelectorAll(`[dragging]`).forEach(el => el.removeAttribute(`dragging`));
}

function inputEventHandler(ev) {
  if (ev.target.type === `text`) {
    //document.querySelectorAll(`.${ev.target.className.replace(` `, `.`)}`).forEach(el => el.)
    console.log(ev.target);
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