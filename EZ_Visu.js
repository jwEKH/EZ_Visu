//Testbench
const ATTRIBUTES = {icon: `pumpe`};//, iconPosition: `right`, signals: `AI1, AI17`};


/*********************Konstanten*********************/
const SVG_NS = `http://www.w3.org/2000/svg`;

const GRIDSIZE_AS_PARTS_FROM_WIDTH = 64; //Gesamtbreite in 32 Teile
const ASPECT_RATIO = 16/9;

//Colors here in rgb, because style.color will return rgb-format
const MAGENTA_HSL = `hsl(334, 74%, 44%)`;
const MAGENTA_HEX = `#c31d65`;
const MAGENTA_RGB = `rgb(195, 29, 101)`;
const CYAN_HSL = `hsl(194, 74%, 44%)`;
const CYAN_HEX = `#1d9cc3`;
const CYAN_RGB = `rgb(29, 156, 195)`;
const PURPLE_HSL = `hsl(264, 74%, 44%)`;
const PURPLE_HEX = `#601dc3`;
const PURPLE_RGB = `rgb(96, 29, 195)`;
const YELLOW_HSL = `hsl(50, 74%, 44%)`;
const YELLOW_HEX = `#c3a81d`;
const YELLOW_RGB = `rgb(195, 168, 29)`;
const COLORS_HEX = [MAGENTA_HEX, CYAN_HEX, PURPLE_HEX, YELLOW_HEX];


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
  svg.setAttribute(`active`, true);
  return svg;
}

function createIconSVG(symbole) {
  if (symbole) {
    const svg = document.createElementNS(SVG_NS, `svg`);
    svg.setAttributeNS(null, `viewBox`, `0 0 100 100`);
    if (symbole === `triangle`) {
      const el = document.createElementNS(SVG_NS, `polygon`);
      svg.appendChild(el);
      el.setAttributeNS(null,`stroke`, `red`);
      el.setAttributeNS(null,`fill`, `none`);
      el.setAttributeNS(null,`points`, `10,90 50,10 90,90`);
    }
    if (symbole === `pumpe`) {
      let el = document.createElementNS(SVG_NS, `circle`);
      svg.appendChild(el);
      el.setAttributeNS(null,`stroke`, `red`);
      el.setAttributeNS(null,`fill`, `grey`);
      el.setAttributeNS(null, `cx`, `50`);
      el.setAttributeNS(null, `cy`, `50`);
      el.setAttributeNS(null, `r`, `40`);
      
      el = document.createElementNS(SVG_NS, `polyline`);
      svg.appendChild(el);
      el.setAttributeNS(null,`stroke`, `red`);
      el.setAttributeNS(null,`fill`, `none`);
      el.setAttributeNS(null,`points`, `10,50 50,10 90,50`);
    }
    if (symbole === `path`) {
      [`icon`, `signal`].forEach(elType => {      
        const el = document.createElementNS(SVG_NS, `path`);
        svg.appendChild(el);
        el.setAttributeNS(null,`stroke`, `red`);
        el.setAttributeNS(null,`fill`, `grey`);
        const d = (elType === `icon`) ? `M 10,50 A 40 40 180 0 0 90 50 L 50,10 L 10,50 A 40 40 180 0 1 90 50` :
                                        `M 50,30 A 15 15 180 0 0 50 70 A 15 15 180 0 0 50 30`;
        el.setAttributeNS(null, `d`, d);
      
      
        /*                              
        let animation = document.createElementNS(SVG_NS, `animateTransform`);
        el.appendChild(animation);
        animation.setAttributeNS(null, `attributeName`, `transform`);
        animation.setAttributeNS(null, `type`, `rotate`);
        animation.setAttributeNS(null, `repeatCount`, `indefinite`);
        animation.setAttributeNS(null, `begin`, `0s`);
        animation.setAttributeNS(null, `dur`, `2s`);
        animation.setAttributeNS(null, `from`, `0 50 50`);
        animation.setAttributeNS(null, `to`, `360 50 50`);
        */
      });
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
  document.body.addEventListener(`mousedown`, mouseDownEventHandler);
  document.body.addEventListener(`mouseup`, mouseUpEventHandler);
  document.body.addEventListener(`dragstart`, dragStartEventHandler);
  document.body.addEventListener(`dragend`, dragEndEventHandler);
  
  document.body.addEventListener(`keydown`, keyDownEventHandler);
  document.body.addEventListener(`dblclick`, dblClickEventHandler);
  
  const divVisu = document.querySelector(`.divVisu`);
  divVisu.addEventListener(`mousemove`, divVisuMouseMoveEventHandler);
  divVisu.addEventListener(`dragenter`, divVisuDragEnterEventHandler);
  divVisu.addEventListener(`dragleave`, divVisuDragLeaveEventHandler);
  divVisu.addEventListener(`dragover`, divVisuDragOverEventHandler);
  divVisu.addEventListener(`drop`, divVisuDropEventHandler);
  divVisu.addEventListener(`click`, divVisuClickEventHandler);
  divVisu.addEventListener(`contextmenu`, divVisuContextMenuEventHandler);

  document.querySelectorAll(`.btnUnDo, .btnReDo`).forEach(btn => btn.addEventListener(`click`, unDoReDoEventListener));
  document.querySelector(`.btnSave`).addEventListener(`click`, saveBtnHandler);
  document.querySelector(`#openLocaleFile`).addEventListener(`input`, openLocalFileEventHandler);
  document.querySelector(`[type=color]`).addEventListener(`input`, colorInputEventHandler);
}

function removeEditorEventHandler() {
  document.body.removeEventListener(`mousedown`, mouseDownEventHandler);
  document.body.removeEventListener(`mouseup`, mouseUpEventHandler);
  document.body.removeEventListener(`dragstart`, dragStartEventHandler);
  document.body.removeEventListener(`dragend`, dragEndEventHandler);
  
  document.body.removeEventListener(`keydown`, keyDownEventHandler);
  document.body.removeEventListener(`dblclick`, dblClickEventHandler);

  const divVisu = document.querySelector(`.divVisu`);
  divVisu.removeEventListener(`mousemove`, divVisuMouseMoveEventHandler);
  divVisu.removeEventListener(`dragenter`, divVisuDragEnterEventHandler);
  divVisu.removeEventListener(`dragleave`, divVisuDragLeaveEventHandler);
  divVisu.removeEventListener(`dragover`, divVisuDragOverEventHandler);
  divVisu.removeEventListener(`drop`, divVisuDropEventHandler);
  divVisu.removeEventListener(`click`, divVisuClickEventHandler);
  divVisu.removeEventListener(`contextmenu`, divVisuContextMenuEventHandler);

  
}

function calcSvgCoordinates(ev) {
  //console.log(ev);
  const activeSvg = document.querySelector(`svg[active]`);
  const activeSvgBox = activeSvg.getBoundingClientRect();
  let xSvg = (ev.x - activeSvgBox.x) / activeSvgBox.width * activeSvg.viewBox.baseVal.width;
  let ySvg = (ev.y - activeSvgBox.y) / activeSvgBox.height *  activeSvg.viewBox.baseVal.height;

  
  const hoverLine = activeSvg.querySelector(`.hoverLine`);
  if (hoverLine && document.querySelector(`#cbOrthoMode`).checked) {
    const dX = Math.abs(xSvg - hoverLine.getAttribute(`x1`));
    const dY = Math.abs(ySvg - hoverLine.getAttribute(`y1`));
    (dY === Math.max(dX, dY)) ? xSvg = hoverLine.getAttribute(`x1`) : ySvg = hoverLine.getAttribute(`y1`);
  }
  const selectionEvent = (document.querySelector(`.selectionArea`) || ev.type === `contextmenu`)
  if (!selectionEvent && document.querySelector(`#cbGridSnap`).checked) {
    xSvg = Math.round(GRIDSIZE_AS_PARTS_FROM_WIDTH * (xSvg / activeSvg.viewBox.baseVal.width)) / GRIDSIZE_AS_PARTS_FROM_WIDTH * activeSvg.viewBox.baseVal.width;
    ySvg = Math.round((GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * (ySvg / activeSvg.viewBox.baseVal.height)) / (GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * activeSvg.viewBox.baseVal.height;
  }

  return {xSvg: xSvg, ySvg: ySvg}
}

function selectionAreaHandler() {
  //console.log(`selectionAreaHandler`);
  const selectionArea = document.querySelector(`.selectionArea`);
  const selectionAreaBox = selectionArea.getBoundingClientRect();
  const {x, y, width, height} = selectionAreaBox;
  const divVisu = document.querySelector(`.divVisu`);
  divVisu.querySelectorAll(`line, .visuItem`).forEach(el => {
    elBox = el.getBoundingClientRect();
    //if (el.matches(`.visuItem`)) console.log(elBox, selectionAreaBox);

    const match = (selectionArea.partialSelection) ? 
                  (!(x > elBox.x+elBox.width || y > elBox.y+elBox.height || width+x < elBox.x || height+y < elBox.y)) :
                  (x <= elBox.x) && (width+x >= elBox.width+elBox.x) && (y <= elBox.y) && (height+y >= elBox.height+elBox.y);
    el.toggleAttribute(`selected`, match);
  });
}


function drawModeHoverEventHandler(ev) {
  const selectionArea = document.querySelector(`.selectionArea`);
  if (!selectionArea) {
    const svgCoordinates = calcSvgCoordinates(ev);

    const activeSvg = document.querySelector(`svg[active]`);
    let hoverMarker = activeSvg.querySelector(`.hoverMarker`);
    if (!hoverMarker) {
      hoverMarker = document.createElementNS(SVG_NS, `circle`);
      activeSvg.appendChild(hoverMarker);
      hoverMarker.classList.add(`hoverMarker`);
      hoverMarker.setAttributeNS(null, `r`, `5`);
    }
    
    const color = document.querySelector(`.colorPicker`).value;
    hoverMarker.setAttributeNS(null,`stroke`, color);
    hoverMarker.setAttributeNS(null,`fill`, color);
    hoverMarker.setAttributeNS(null,`opacity`, (document.querySelector(`#cbShowMarker`).checked) ? 1 : 0);
    hoverMarker.setAttributeNS(null, `cx`, `${svgCoordinates.xSvg}`);
    hoverMarker.setAttributeNS(null, `cy`, `${svgCoordinates.ySvg}`);
    
    const hoverLine = activeSvg.querySelector(`.hoverLine`);
    if (hoverLine) {
      hoverLine.setAttributeNS(null, `x2`, `${svgCoordinates.xSvg}`);
      hoverLine.setAttributeNS(null, `y2`, `${svgCoordinates.ySvg}`);
      hoverLine.setAttributeNS(null,`stroke`, color);
      const StrokeDasharray = document.querySelector(`#selStrokeDasharray`).value;
      hoverLine.setAttributeNS(null, `stroke-dasharray`, StrokeDasharray);
      const strokeWidth = document.querySelector(`.strokeWidth`).value;
      hoverLine.setAttributeNS(null,`stroke-width`, strokeWidth);
    }
  }
}

function selectModeHoverEventHandler(ev) {
  const selectionArea = document.querySelector(`.selectionArea`);
  if (selectionArea) {
    const svgCoordinates = calcSvgCoordinates(ev);
    const points = `${selectionArea.svgCoordinates.xSvg},${selectionArea.svgCoordinates.ySvg} ${selectionArea.svgCoordinates.xSvg},${svgCoordinates.ySvg} ${svgCoordinates.xSvg},${svgCoordinates.ySvg} ${svgCoordinates.xSvg},${selectionArea.svgCoordinates.ySvg}`;
    selectionArea.setAttributeNS(null,`points`, points);
    selectionArea.partialSelection = (svgCoordinates.xSvg >= selectionArea.svgCoordinates.xSvg /*&& svgCoordinates.ySvg >= selectionArea.svgCoordinates.ySvg*/) ? false : true;
    const color = (selectionArea.partialSelection) ? YELLOW_HEX : CYAN_HEX;
    selectionArea.setAttributeNS(null,`fill`, color);

    selectionAreaHandler();
  }
}

function drawModeClickEventHandler(ev) {
  const activeSvg = document.querySelector(`svg[active]`);
  const hoverLine = activeSvg.querySelector(`.hoverLine`);
  if (hoverLine) {
    const x1 = hoverLine.getAttribute(`x1`);
    const y1 = hoverLine.getAttribute(`y1`);
    const x2 = hoverLine.getAttribute(`x2`);
    const y2 = hoverLine.getAttribute(`y2`);
    const isValidHoverLine = !(x1 === null | y1 === null | x2 === null | y2 === null | (x1 === x2 & y1 === y2));
    if (isValidHoverLine) {  
      const newLine = hoverLine.cloneNode();
      activeSvg.appendChild(newLine);
      newLine.removeAttributeNS(null,`opacity`);
      newLine.classList.remove(`hoverLine`);
      
      hoverLine.setAttributeNS(null,`x1`, x2);
      hoverLine.setAttributeNS(null,`y1`, y2);

      updateUnDoReDoStack();
    }
  }
  else {
    const hoverMarker = activeSvg.querySelector(`.hoverMarker`);
    if (hoverMarker) {
      const hoverLine = document.createElementNS(SVG_NS, `line`);
      activeSvg.appendChild(hoverLine);
      hoverLine.classList.add(`hoverLine`);
      hoverLine.setAttributeNS(null,`opacity`, `0.4`);
      hoverLine.setAttributeNS(null,`x1`, hoverMarker.getAttribute(`cx`));
      hoverLine.setAttributeNS(null,`y1`, hoverMarker.getAttribute(`cy`));
    }
  }
}


function selectModeClickEventHandler(ev) {
  //console.log(ev.target);
  const activeSvg = document.querySelector(`svg[active]`);
  const svgCoordinates = calcSvgCoordinates(ev);
  const selectionArea = activeSvg.querySelector(`.selectionArea`);
  if (selectionArea) {
    //selectionArea.setAttributeNS(null,`width`, 100);
    //selectionArea.setAttributeNS(null,`height`, 100);
    selectionArea.remove();
  }
  else {
    //console.log(`else`);
    const selectionArea = document.createElementNS(SVG_NS, `polygon`);
    activeSvg.appendChild(selectionArea);
    selectionArea.classList.add(`selectionArea`);
    selectionArea.setAttributeNS(null,`opacity`, `0.1`);
    selectionArea.svgCoordinates = svgCoordinates;
    //selectionArea.setAttributeNS(null,`points`, `${svgCoordinates.xSvg},${svgCoordinates.ySvg}`);
  }
}

function createEditorTools() {
  const fsEditorTools = document.createElement(`fieldset`);
  const legendTools = document.createElement(`legend`);
  fsEditorTools.appendChild(legendTools);
  legendTools.innerText = `Editor Tools`;

  const inputFile = document.createElement(`input`);
  fsEditorTools.appendChild(inputFile);
  inputFile.type = `file`;
  inputFile.accept = `.txt`;
  inputFile.classList.add(`inputFile`);
  inputFile.addEventListener(`input`, openLocalFileEventHandler);
    

  [`Save`, `Open`].forEach(el => {
    const btn = document.createElement(`input`);
    fsEditorTools.appendChild(btn);
    btn.type = `button`;
    btn.classList.add(`btn${el}`);
    btn.value = el;
    btn.title = (el === `Save`) ? `[Strg + s]` : `[Strg + o]`;
    btn.addEventListener(`click`, saveBtnHandler);
  });

  [`UnDo`, `ReDo`].forEach(el => {
    const btn = document.createElement(`input`);
    fsEditorTools.appendChild(btn);
    btn.type = `button`;
    btn.classList.add(`btn${el}`);
    btn.value = (el === `UnDo`) ? `↶` : `↷`;
    btn.title = (el === `UnDo`) ? `[Strg + z]` : `[Strg + y]`;
    btn.addEventListener(`click`, unDoReDoEventListener);
  });
  updateUnDoReDoStack(true);

  const colorPicker = document.createElement(`input`);
  fsEditorTools.appendChild(colorPicker);
  colorPicker.classList.add(`colorPicker`);
  colorPicker.type = `color`;
  colorPicker.value = MAGENTA_HEX;
  colorPicker.title = `[c]`;
  colorPicker.addEventListener(`input`, (ev) => {
    document.querySelector(`#selStrokeDasharray`).style.color = ev.target.value;
  });
  colorPicker.setAttribute(`list`, `presetColors`);
  const presetColors = document.createElement(`datalist`);
  colorPicker.appendChild(presetColors);
  presetColors.id = `presetColors`;
  COLORS_HEX.forEach(color => {
    const option = document.createElement(`option`);
    presetColors.appendChild(option);
    option.value = color;
  });

  const lblStrokeDasharray = document.createElement(`label`);
  fsEditorTools.appendChild(lblStrokeDasharray);
  lblStrokeDasharray.setAttribute(`for`, `selStrokeDasharray`);
  lblStrokeDasharray.innerText = `strokeDasharray:`;
  const selStrokeDasharray = document.createElement(`select`);
  fsEditorTools.appendChild(selStrokeDasharray);
  selStrokeDasharray.id = `selStrokeDasharray`;
  selStrokeDasharray.style.color = colorPicker.value;
  [0, 5].forEach(value => {
    const option = document.createElement(`option`);
    selStrokeDasharray.appendChild(option);
    option.value = value;
    option.innerText = (value) ? `⚋` : `⚊`;
  });

  const strokeWidth = document.createElement(`input`);
  fsEditorTools.appendChild(strokeWidth);
  strokeWidth.classList.add(`strokeWidth`);
  strokeWidth.type = `number`;
  strokeWidth.value = 1;
  strokeWidth.min = 1;

  [`OrthoMode`, `GridSnap`, `ShowMarker`].forEach(option => {
    const cb = document.createElement(`input`);
    fsEditorTools.appendChild(cb);
    cb.type = `checkbox`;
    cb.checked = true;
    cb.id = `cb${option}`;
    cb.title =  (option === `OrthoMode`) ? `[o]` :
                (option === `GridSnap`) ? `[g]` :
                `[m]`;
    const lbl = document.createElement(`label`);
    fsEditorTools.appendChild(lbl);
    lbl.setAttribute(`for`, cb.id);
    lbl.innerText = option;
    lbl.title = (option === `OrthoMode`) ? `[o]` : `[g]`;
  });

  /*
  const fsMode = document.createElement(`fieldset`);
  fsEditorTools.appendChild(fsMode);
  const legendMode = document.createElement(`legend`);
  fsMode.appendChild(legendMode);
  legendMode.innerText = `Editor Mode`;
  [`Draw`, `Select`].forEach(option => {
    const rb = document.createElement(`input`);
    fsMode.appendChild(rb);
    rb.type = `radio`;
    //rb.checked = (option === `Draw`);
    rb.value = option.toLowerCase();
    rb.id = `rb${option}`;
    rb.name = `rgMode`;
    rb.title = (option === `Draw`) ? `[d]` : `[s]`;
    rb.addEventListener(`input`, inputEventHandler);
    const lbl = document.createElement(`label`);
    fsMode.appendChild(lbl);
    lbl.setAttribute(`for`, rb.id);
    lbl.innerText = option;
    lbl.title = (option === `Draw`) ? `[d]` : `[s]`;

    if (option === `Draw`)
      rb.click(); //init
  });
  */

  return fsEditorTools;
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
    //document.body.appendChild(createEditorTools());
    document.querySelector(`#selStrokeDasharray`).style.color = document.querySelector(`.colorPicker`).value;
    updateUnDoReDoStack(true);
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

function updateUnDoReDoStack(reset) {
  //cancelCurrentDrawing();
  //cancelCurrentSelection();
  const divVisu = document.querySelector(`.divVisu`);
  if (reset) {
    divVisu.unDoReDoStack = {idx: 0, stack: [divVisu.innerHTML]};
  }
  else {
    const {unDoReDoStack} = divVisu;
    unDoReDoStack.stack.length = ++unDoReDoStack.idx;
    unDoReDoStack.stack.push(divVisu.innerHTML);
  }
}
/*********************EventHandlers*********************/
function divVisuContextMenuEventHandler(ev) {
  ev.preventDefault();

  let actionExecuted = false;
  actionExecuted |= cancelCurrentDrawing();
  //console.log({actionExecuted});
  const selectionArea = document.querySelector(`.selectionArea`);
  if (!selectionArea) {
    actionExecuted |= removeDivIconSignal(ev);
  }
  if (!actionExecuted) {
    selectModeClickEventHandler(ev);  //selection only starts when no other action was executed
  }
}

function divVisuMouseMoveEventHandler(ev) {  
  drawModeHoverEventHandler(ev);
  selectModeHoverEventHandler(ev);
}

function mouseDownEventHandler(ev) {
  if (ev.buttons === 1) {
    const target = (ev.target.matches(`[draggable]`)) ? ev.target : ev.target.closest(`.visuItem[draggable]`);
    if (target) {
      target.setAttribute(`dragging`, `true`);
    }
  }
}

function divVisuClickEventHandler(ev) {
  //console.log(ev);
  if (!cancelCurrentSelection()) {
    drawModeClickEventHandler(ev); //drawing only starts when no selection was active
  }

  
}

function cancelCurrentDrawing() {
  const hoverMarker = document.querySelector(`.hoverMarker`);
  if (hoverMarker)
    hoverMarker.remove();
  const hoverLine = document.querySelector(`.hoverLine`);
  if (hoverLine) {
    hoverLine.remove();
    return true; //feedback that drawing was active
  }
  return false; //feedback that drawing was NOT active
}

function cancelCurrentSelection() {
  document.querySelectorAll(`[selected]`).forEach(el => el.removeAttribute(`selected`));
  const selectionArea = document.querySelector(`.selectionArea`);
  if (selectionArea) {
    selectionArea.remove();
    return true; //feedback that selection was active
  }
  return false; //feedback that selection was NOT active
}

function removeDivIconSignal(ev) {
  if (ev.target.matches(`.divError, .divFreigabe, .divBetriebsart, .divAbsenkung, .divBetrieb`)) {
    ev.target.removeAttribute(`signal`);
    ev.target.removeAttribute(`title`);
    ev.target.setAttribute(`NA`, true);
    return true; //feedback that removeAction was executed
  }
  return false; //feedback that removeAction was NOT executed
}

function removeAllDraggingAttributes() {
  document.querySelectorAll(`[dragging]`).forEach(el => el.removeAttribute(`dragging`));
}

function mouseUpEventHandler(ev) {
  removeAllDraggingAttributes();
}

function dragStartEventHandler(ev) {
  //console.log(ev);
  const target = (ev.target.matches(`[draggable]`)) ? ev.target : ev.target.closest(`.visuItem[draggable]`);
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

function divVisuDragEnterEventHandler(ev) {
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  if (draggingItem.matches(`[isBool]`) && ev.target.matches(`.divError, .divFreigabe, .divBetriebsart, .divAbsenkung, .divBetrieb`)) {
    //console.log(ev.target)
    ev.target.removeAttribute(`NA`);
  }
}

function divVisuDragLeaveEventHandler(ev) {
  if (!ev.target.matches(`[signal]`) && ev.target.matches(`.divError, .divFreigabe, .divBetriebsart, .divAbsenkung, .divBetrieb`)) {
    ev.target.setAttribute(`NA`, true);
  }
}

function divVisuDragOverEventHandler(ev) {
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
  removeAllDraggingAttributes();
}

function divVisuDropEventHandler(ev) {
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
      const xRel = (ev.x - targetBox.x - offsetX)/targetBox.width;
      const yRel = (ev.y - targetBox.y - offsetY)/targetBox.height;
      const gridSnapActive = document.querySelector(`#cbGridSnap`).checked;
      dropItem.style.left = (gridSnapActive) ? `${Math.round(GRIDSIZE_AS_PARTS_FROM_WIDTH * xRel) / GRIDSIZE_AS_PARTS_FROM_WIDTH * 100}%` : `${xRel*100}%`;
      dropItem.style.top = (gridSnapActive) ? `${Math.round((GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * yRel) / (GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * 100}%` : `${yRel*100}%`;
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
        const divIcon = visuItem.querySelector(`.divIcon`); 
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
        //const insertBeforeNode = (target.closest(`.divSignals`)) ? target : divSignals.firstElementChild;
        divSignals.appendChild(dropItem);
      }
    }
    updateUnDoReDoStack();
  }

  removeAllDraggingAttributes();
}

function dblClickEventHandler(ev) {
  const divIcon = ev.target.closest(`.divIcon`);
  const svg = (divIcon) ? divIcon.querySelector(`svg`) : null;
  if (svg) {
    const rotation = parseInt(svg.getAttribute(`rotation`));
    if (rotation < 270) {
      svg.setAttribute(`rotation`, rotation + 90);
    }
    else if (rotation >= 270) {
      svg.removeAttribute(`rotation`);
    }
    else {
      svg.setAttribute(`rotation`, 90);
    }
    cancelCurrentDrawing(); //workaround for (drawing)-clickEventTriggers on dblClick as well!
    if (svg.matches(`.divVisu *`)) {
      updateUnDoReDoStack();
    }
  }
}

function keyDownEventHandler(ev) {
  //console.log(ev.key);
  const key = ev.key.toLowerCase();
  const auxKeys = ev.altKey | ev.ctrlKey | ev.shiftKey;
  if (!auxKeys) {
    if (key === `c`)
      document.querySelector(`.colorPicker`).click();
    if (key === `d`)
      document.querySelector(`#rbDraw`).click();
    if (key === `g`)
      document.querySelector(`#cbGridSnap`).click();
    if (key === `o`)
      document.querySelector(`#cbOrthoMode`).click();
    if (key === `s`)
      document.querySelector(`#rbSelect`).click();
    if (key === `escape`) {
      cancelCurrentDrawing();
      cancelCurrentSelection();
    }
    if (key.match(/(delete)|(backspace)/)) {
      document.querySelectorAll(`[selected]`).forEach(el => el.remove());
      updateUnDoReDoStack();
    }
  }
  else if (ev.ctrlKey) {
    if (key === `a`) {
      ev.preventDefault();
      document.querySelectorAll(`.visuItem, svg[active] *`).forEach(el => el.setAttribute(`selected`, true));
    }
    if (key === `y`)
      document.querySelector(`.btnReDo`).click();
    if (key === `z`)
      document.querySelector(`.btnUnDo`).click();
  }

  const activeSvg = document.querySelector(`svg[active]`);
  if (activeSvg) {
    if (key.startsWith(`arrow`)) {
      ev.preventDefault();
      const stepWidthSvg = (document.querySelector(`#cbGridSnap`).checked) ? activeSvg.viewBox.baseVal.width / GRIDSIZE_AS_PARTS_FROM_WIDTH : 10; //todo...
      //const stepWidthRel = stepWidthSvg / activeSvg.viewBox.baseVal.width;
      const dxSvg = (key.includes(`left`)) ? -stepWidthSvg :
                    (key.includes(`right`)) ? stepWidthSvg :
                    0;
      const dxRel = dxSvg / activeSvg.viewBox.baseVal.width;
      const dySvg = (key.includes(`up`)) ? -stepWidthSvg :
                    (key.includes(`down`)) ? stepWidthSvg :
                    0;
      const dyRel = dySvg / activeSvg.viewBox.baseVal.height;

      document.querySelectorAll(`[selected]`).forEach(el => {
        if (el.matches(`svg *`)) {
          if (dxSvg) {
            el.setAttribute(`x1`, dxSvg + parseFloat(el.getAttribute(`x1`)));
            el.setAttribute(`x2`, dxSvg + parseFloat(el.getAttribute(`x2`)));
          }
          if (dySvg) {
            el.setAttribute(`y1`, dySvg + parseFloat(el.getAttribute(`y1`)));
            el.setAttribute(`y2`, dySvg + parseFloat(el.getAttribute(`y2`)));
          }
        }
        else if (el.matches(`.visuItem`)) {
          if (dxRel) {
            console.log(`match`);
            el.style.left = `${parseFloat(el.style.left) + 100 * dxRel}%`;
          }
          if (dyRel) {
            el.style.top = `${parseFloat(el.style.top) + 100 * dyRel}%`;
          }
        }
      });
      updateUnDoReDoStack();
    }
  }
}

function unDoReDoEventListener(ev) {
  const divVisu = document.querySelector(`.divVisu`);
  if (divVisu) {
    const {unDoReDoStack} = divVisu;
    if (ev.target.matches(`.btnUnDo`)) {
      unDoReDoStack.idx = Math.max(0, unDoReDoStack.idx - 1);
    }
    else {
      unDoReDoStack.idx = Math.min(unDoReDoStack.stack.length - 1, unDoReDoStack.idx + 1);
    }
    divVisu.innerHTML = unDoReDoStack.stack.at(unDoReDoStack.idx); //todo...
    console.log(`${unDoReDoStack.idx} of ${unDoReDoStack.stack.length - 1}`);
  }
}

function openLocalFileEventHandler(ev) {
  const reader = new FileReader();
  reader.readAsText(ev.target.files[0]);
  reader.addEventListener(`load`, () => {
    document.querySelector(`.divVisu`).innerHTML = reader.result;
    updateUnDoReDoStack();
    console.log(reader.result);
  });
}

function colorInputEventHandler(ev) {
  document.querySelector(`#selStrokeDasharray`).style.color = ev.target.value;
}

function saveBtnHandler() {
  cancelCurrentSelection();
  cancelCurrentDrawing();
  saveVisu();
  //saveSvg(document.querySelector(`svg`), `test.svg`);
}

function saveVisu() {
  const data = document.querySelector(`.divVisu`).innerHTML;
  
  console.log(data);

  
  
  const blob = new Blob([data], {type:"text/html;charset=utf-8"});
  const url = URL.createObjectURL(blob);
  const downloadLink = document.createElement("a");
  document.body.appendChild(downloadLink);
  downloadLink.href = url;
  downloadLink.download = `test.txt`;
  downloadLink.click();
  document.body.removeChild(downloadLink);
}

function saveSvg(svgEl, name) {
  svgEl.setAttribute("xmlns", "http://www.w3.org/2000/svg");
  const svgData = svgEl.outerHTML;
  const preface = '<?xml version="1.0" standalone="no"?>\r\n';
  const svgBlob = new Blob([preface, svgData], {type:"image/svg+xml;charset=utf-8"});
  const svgUrl = URL.createObjectURL(svgBlob);
  const downloadLink = document.createElement("a");
  downloadLink.href = svgUrl;
  downloadLink.download = name;
  document.body.appendChild(downloadLink);
  downloadLink.click();
  document.body.removeChild(downloadLink);
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

/*********************AuxFunctions*********************/
function constrain(val, min, max) {
  return Math.min(max, Math.max(min, val));
}

function eventIsWithin(ev, cssSelector) { //necessary bc fn.closest() fails 4 svg ancestors bc they don't have parents...
  if (ev.isTrusted) { //don't check for untrusted events, like using fn.click(), but return false! 
    const {x, y, width, height} = document.querySelector(cssSelector).getBoundingClientRect();
    return ev.x >= x && ev.x <= x+width && ev.y >= y && ev.y <= y+height
  }
  else {
    return false;
  }
}


function l(data) {
  console.log(data);
}