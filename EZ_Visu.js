/*********************Konstanten*********************/
const SVG_NS = `http://www.w3.org/2000/svg`;

const GRIDSIZE_AS_PARTS_FROM_WIDTH = 32; //Gesamtbreite in 32 Teile
const ASPECT_RATIO = 16/9;

//Testbench
const ATTRIBUTES = {icon: `pumpe`};//, iconPosition: `right`, signals: `AI1, AI17`};

/*********************VanillaDocReady*********************/
window.addEventListener('load', function () {
  document.querySelector(`.divVisu`).appendChild(createBackgroundSVG(1));
  window.reloadLiveDataIntervalId = setInterval(getLiveData, 1000, window.visuLiveData, window.projectNo);
  
  enterVisuEditor(true);
  
}, false);
/*********************GenericFunctions*********************/
function createBackgroundSVG(idx) {
  const svg = document.createElementNS(SVG_NS, `svg`);
  svg.setAttributeNS(null, `viewBox`, `0 0 1600 900`);
  svg.classList.add(`bgSVG`, `bgSVG_${idx}`);
  return svg;
}

function createIconSVG(symbole) {
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
    if (symbole === `path`) {
      let el = document.createElementNS(SVG_NS, `path`);
      el.setAttributeNS(null,`stroke`, `red`);
      el.setAttributeNS(null,`fill`, `none`);
      el.setAttributeNS(null, `d`, `M 10,30
      A 20,20 0,0,1 50,30
      A 20,20 0,0,1 90,30
      Q 90,60 50,90
      Q 10,60 10,30 z`);
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
  visuItem.appendChild(divIcon);
  divIcon.classList.add(`divIcon`);
  
  const divSignals = document.createElement(`div`);
  visuItem.appendChild(divSignals);
  divSignals.classList.add(`divSignals`);
  
  attributes.forEach(attribute => {
    Object.entries(attribute).forEach(([key, value]) => {
      //console.log(`${key} ${value}`);
      
      //Save everything as attribute for .visu.txt file!
      visuItem.setAttribute(key, value);
      
      if (key.toLowerCase() === `icon`) {
        divIcon.appendChild(createIconSVG(value));        
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

  [`Error`, `Freigabe`, `Betriebsart`, `Absenkung`, `Betrieb`].forEach(signal => {
    const div = document.createElement(`div`);
    divIcon.appendChild(div);
    div.classList.add(`div${signal}`);
    div.setAttribute(`NA`, true);
    div.innerText = (signal === `Error`)        ? `⚠`  :
                    (signal === `Freigabe`)     ? `⏺` :
                    (signal === `Betriebsart`)  ? `✋`  :
                    (signal === `Absenkung`)    ? `🌜`  :
                    ``;
                  });
                  

                  return visuItem
                }
/*********************EditorFunctions*********************/
function addEditorEventHandler() {
  document.body.addEventListener(`contextmenu`, contextMenuEventHandler);
  document.body.addEventListener(`mousemove`, mouseMoveEventHandler);
  document.body.addEventListener(`mousedown`, mouseDownEventHandler);
  document.body.addEventListener(`mouseup`, mouseUpEventHandler);
  document.body.addEventListener(`dragstart`, dragStartEventHandler);
  document.body.addEventListener(`dragenter`, dragEnterEventHandler);
  document.body.addEventListener(`dragleave`, dragLeaveEventHandler);
  document.body.addEventListener(`dragover`, dragOverEventHandler);
  document.body.addEventListener(`dragend`, dragEndEventHandler);
  document.body.addEventListener(`drop`, dropEventHandler);
  document.body.addEventListener(`dblclick`, dblClickEventHandler);

  document.body.addEventListener(`input`, inputEventHandler);
}

function removeEditorEventHandler() {
  document.body.removeEventListener(`contextmenu`, contextMenuEventHandler);
  document.body.removeEventListener(`mousemove`, mouseMoveEventHandler);
  document.body.removeEventListener(`mousedown`, mouseDownEventHandler);
  document.body.removeEventListener(`mouseup`, mouseUpEventHandler);
  document.body.removeEventListener(`dragstart`, dragStartEventHandler);
  document.body.removeEventListener(`dragenter`, dragEnterEventHandler);
  document.body.removeEventListener(`dragleave`, dragLeaveEventHandler);
  document.body.removeEventListener(`dragover`, dragOverEventHandler);
  document.body.removeEventListener(`dragend`, dragEndEventHandler);
  document.body.removeEventListener(`drop`, dropEventHandler);
  document.body.removeEventListener(`dblclick`, dblClickEventHandler);

  document.body.removeEventListener(`input`, inputEventHandler);
}

function createSignalTable(visuLiveData) {
  const signalTable = document.createElement(`details`);
  signalTable.classList.add(`signalTable`, `visuEditElement`);
  //signalTable.setAttribute(`open`, `true`);
  [`Drag`, `Edit`].forEach(option => {
    const radioBtn = document.createElement(`input`);
    radioBtn.type = `radio`;
    radioBtn.id = `radioBtn${option}`;
    radioBtn.name = `radioGroupSignalTable`;
    radioBtn.value = option.toLowerCase();
    radioBtn.checked = (option === `Drag`);
    radioBtn.addEventListener(`change`, (ev) => {
      console.log(ev.target.value);
      const inpSignals = document.querySelectorAll(`.signalTable input[type='text']`);
      //console.log(inpSignals);
      inpSignals.forEach(el => {
        el.readOnly = !el.readOnly;//, (ev.target.value === `drag`)));
        el.draggable = !el.draggable;//, (ev.target.value === `drag`)));
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
        details.appendChild(entry);
        entry.type = `text`;
        entry.classList.add(`${signalGroup}${i}`);
        entry.readOnly = true;
        entry.draggable = true;
        entry.value = `${signalGroup}${i}`;
        entry.toggleAttribute(`isBool`, signalGroup.match(/(DI)|(DO)/));
      }
      signalTable.appendChild(details);
    });
  }
  return signalTable;
}

function createVisuItemPool() {
  const visuItemPool = document.createElement(`details`);
  visuItemPool.classList.add(`visuItemPool`, `visuEditElement`);
  //visuItemPool.setAttribute(`open`, `true`);
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
  addEditorEventHandler();
}

function leaveVisuEditor() {
  document.querySelectorAll(`.visuEditElement`).forEach(el => el.setAttribute(`cloaked`, `true`));
  document.querySelectorAll(`[draggable]`).forEach(el => el.removeAttribute(`draggable`));
  removeEditorEventHandler();
}
/*********************EventHandlers*********************/
function contextMenuEventHandler(ev) {
  ev.preventDefault();
}

function mouseMoveEventHandler(ev) {
  //console.log(ev.target);
  const divVisu = ev.target.closest(`.divVisu`);
  if (divVisu) {
    const divVisuBox = divVisu.getBoundingClientRect();
    const xRel = Math.round(GRIDSIZE_AS_PARTS_FROM_WIDTH * (ev.x - divVisuBox.x) / divVisuBox.width) / GRIDSIZE_AS_PARTS_FROM_WIDTH;
    const yRel = Math.round((GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * (ev.y - divVisuBox.y) / divVisuBox.height) / (GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO);
    const activeSVG = divVisu.querySelector(`svg`); //choose active SVG
    const xSvg = xRel * activeSVG.viewBox.baseVal.width;
    const ySvg = yRel * activeSVG.viewBox.baseVal.height;
    
    //console.log(`${xRel}, ${yRel}`);

    let hoverMarker = activeSVG.querySelector(`.hoverMarker`);
    if (!hoverMarker) {
      hoverMarker = document.createElementNS(SVG_NS, `circle`);
      activeSVG.appendChild(hoverMarker);
      hoverMarker.classList.add(`hoverMarker`);
      //hoverMarker.setAttributeNS(null,`stroke`, `red`);
      hoverMarker.setAttributeNS(null,`fill`, `red`);
      hoverMarker.setAttributeNS(null, `r`, `5`);
    }
    
    hoverMarker.setAttributeNS(null, `cx`, `${xSvg}`);
    hoverMarker.setAttributeNS(null, `cy`, `${ySvg}`);

  }
}

function mouseDownEventHandler(ev) {
  if (ev.buttons === 1) {
    const target = (ev.target.type === `text`) ? ev.target : ev.target.closest(`.visuItem`);
    if (target) {
     if (target.draggable)
      target.setAttribute(`dragging`, `true`);
    }
    else if (ev.target.closest(`.divVisu`)) {
      const activeSVG = document.querySelector(`.divVisu svg`);
      const activePath = activeSVG.querySelector(`.activePath`);
      const hoverMarker = activeSVG.querySelector(`.hoverMarker`);
      const startPoint = activeSVG.querySelector(`.startPoint`);
      if (activePath) {
        const pathString = `${activePath.attributes.d.value} L ${hoverMarker.attributes.cx.value}, ${hoverMarker.attributes.cy.value}`;
        activePath.setAttributeNS(null, `d`, pathString);
      }
      else {
        if (startPoint) {
          const pathString = `M ${startPoint.attributes.cx.value}, ${startPoint.attributes.cy.value} L ${hoverMarker.attributes.cx.value}, ${hoverMarker.attributes.cy.value}`

          const activePath = document.createElementNS(SVG_NS, `path`);
          activeSVG.appendChild(activePath);
          activePath.classList.add(`activePath`);
          activePath.setAttributeNS(null,`stroke`, `red`);
          activePath.setAttributeNS(null,`fill`, `none`);
          activePath.setAttributeNS(null, `d`, pathString);

        }
      }
      
        if (startPoint)
          startPoint.remove();
        const newStartPoint = document.querySelector(`.hoverMarker`).cloneNode();
        activeSVG.appendChild(newStartPoint);
        newStartPoint.classList.replace(`hoverMarker`, `startPoint`);
      
      

    }
  }
  else {
    const startPoint = document.querySelector(`.startPoint`);
    if (startPoint)
      startPoint.remove();
    const activePath = document.querySelector(`.activePath`);
    if (activePath)
      activePath.classList.remove(`activePath`);
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

function dragEnterEventHandler(ev) {
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  if (draggingItem.matches(`[isBool]`) && ev.target.matches(`.divError, .divFreigabe, .divBetriebsart, .divAbsenkung, .divBetrieb`)) {
    console.log(ev.target)
    ev.target.removeAttribute(`NA`);
  }
}

function dragLeaveEventHandler(ev) {
  if (!ev.target.matches(`[signal]`) && ev.target.matches(`.divError, .divFreigabe, .divBetriebsart, .divAbsenkung, .divBetrieb`)) {
    ev.target.setAttribute(`NA`, true);
  }

}

function dragOverEventHandler(ev) {
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  if (draggingItem) {
    const visuItemToDivVisu = (ev.target.closest(`.divVisu`) && draggingItem.matches(`.visuItem`));
    const analogSignalToVisuItem = draggingItem.type === `text` && !draggingItem.matches(`[isBool]`) && ev.target.closest(`.visuItem`) && !ev.target.closest(`.visuEditElement`);
    const digitalSignalToVisuItem = draggingItem.matches(`[isBool]`) && ev.target.matches(`.divError, .divFreigabe, .divBetriebsart, .divAbsenkung, .divBetrieb`) && !ev.target.closest(`.visuEditElement`);
    if (visuItemToDivVisu || analogSignalToVisuItem || digitalSignalToVisuItem) {
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
    
    if (target.matches(`.divVisu`)) {
      const targetBox = target.getBoundingClientRect();
      const offsetX = ev.dataTransfer.getData(`offsetX`);
      const offsetY = ev.dataTransfer.getData(`offsetY`);
      
      dropItem.style.position = `absolute`;
      //toDo: gridSnap...
      dropItem.style.left = `${Math.round((ev.x - targetBox.x - offsetX)/targetBox.width*100)}%`;
      dropItem.style.top = `${Math.round((ev.y - targetBox.y - offsetY)/targetBox.height*100)}%`;
      target.appendChild(dropItem);
    }
    else {
      if (draggingItem.matches(`[isBool]`)) {
        console.log(target);
        target.setAttribute(`signal`, draggingItem.value);
        target.title = `${draggingItem.value} (DoubleClick to remove Signal)`;
      }
      else {
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
      }

        const divSignals = visuItem.querySelector(`.divSignals`);
        //const insertBeforeNode = (target.closest(`.divSignals`)) ? target : divSignals.firstElementChild;
        divSignals.appendChild(dropItem);
      }
    }
  }

  document.querySelectorAll(`[dragging]`).forEach(el => el.removeAttribute(`dragging`));
}

function dblClickEventHandler(ev) {
  if (ev.target.matches(`.divError, .divFreigabe, .divBetriebsart, .divAbsenkung, .divBetrieb`)) {
    ev.target.removeAttribute(`signal`);
    ev.target.title = ``;
    ev.target.setAttribute(`NA`, true);
  }
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