//Testbench
const ATTRIBUTES = {icon: `heizkreis`, iconPosition: `left`};//, signals: `AI1, AI17`};


/*********************Konstanten*********************/
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
const GREEN_HSL = `hsl(120, 74%, 44%)`;
const GREEN_HEX = `#1dc31d`;
const GREEN_RGB = `rgb(29, 195, 29)`;
const COLORS_HEX = [MAGENTA_HEX, CYAN_HEX, PURPLE_HEX, YELLOW_HEX, GREEN_HEX];

const DARKESTGREY_HSL = `hsl(249, 10%, 13%)`;
const DARKERGREY_HSL = `hsl(249, 10%, 18%)`;
const DARKGREY_HSL = `hsl(249, 10%, 23%)`;
const GREY_HSL = `hsl(249, 10%, 28%)`;
const LIGHTGREY_HSL = `hsl(249, 10%, 33%)`;
const LIGHTERGREY_HSL = `hsl(249, 10%, 38%)`;
const LIGHTESTGREY_HSL = `hsl(249, 10%, 43%)`;


const SVG_NS = `http://www.w3.org/2000/svg`;

const GRIDSIZE_AS_PARTS_FROM_WIDTH = 64; //Gesamtbreite in 32 Teile
const ASPECT_RATIO = 16/9;
const SVG_VIEWBOX_WIDTH = 1600;
const SVG_VIEWBOX_HEIGHT = 900;

const STROKE_COLOR = `white`;
const FILL_COLOR = DARKESTGREY_HSL;
const STROKE_WIDTH = .3;

/*********************VanillaDocReady*********************/
window.addEventListener('load', function () {
  document.querySelector(`.divVisu`).appendChild(createBackgroundSVG(1));
  window.reloadLiveDataIntervalId = setInterval(getLiveData, 1000, window.visuLiveData, window.projectNo);
  
  enterVisuEditor(true);
  
}, false);
/*********************GenericFunctions*********************/
function createBackgroundSVG(idx) {
  const svg = document.createElementNS(SVG_NS, `svg`);
  svg.setAttributeNS(null, `viewBox`, `0 0 ${SVG_VIEWBOX_WIDTH} ${SVG_VIEWBOX_HEIGHT}`);
  svg.classList.add(`bgSVG`, `active`);
  svg.setAttribute(`tab-idx`, idx);
  //svg.setAttribute(`active`, true);
  return svg;
}

function createIcon(symbol) {
  if (symbol) {
    const icon =  (symbol === `kessel`) ? document.createElement(`div`) : 
                  (symbol === `button`) ? document.createElement(`input`) : 
                  document.createElementNS(SVG_NS, `svg`);
    if (icon.tagName === `INPUT`) {
      icon.type = `button`;
    }
    else {
      icon.classList.add(`icon`);
      if (icon.tagName === `svg`) {
        const viewBoxHeight = (symbol === `waermetauscher`) ? 25 : 13;
        icon.setAttributeNS(null, `viewBox`, `-0.5 -0.5 13 ${viewBoxHeight}`);
      }
    }
    const el = (icon.matches(`.icon`)) ? document.createElementNS(SVG_NS, `path`) : undefined;
    if (el) {
      icon.appendChild(el);
      const strokeColor = (symbol === `aggregat`) ? CYAN_HEX : STROKE_COLOR;
      el.setAttributeNS(null,`stroke`, strokeColor);
      const strokeWidth = (symbol === `aggregat`) ? 2.5 * STROKE_WIDTH : STROKE_WIDTH;
      el.setAttributeNS(null, `stroke-width`, strokeWidth);
      const fillColor = (symbol.match(/(temperatur)|(aggregat)|(schalter)/)) ? `none` : FILL_COLOR;
      el.setAttributeNS(null,`fill`, fillColor);
      
      const d = (symbol === `temperatur`) ? `M0 12 8 4M5 1 11 7` :
                (symbol === `heizkreis`) ? `M0 6a1 1 0 0112 0A1 1 0 010 6M1 6A1 1 0 0011 6 1 1 0 001 6 1 1 0 0011 6 1 1 0 001 6` :
                (symbol === `pumpe`) ? `M2 6 6 2l4 4A1 1 0 012 6a1 1 0 018 0` : //`M2 6 6 2 10 6A1 1 0 012 6 1 1 0 0110 6M4 6A1 1 0 008 6 1 1 0 004 6L6 6 6 4` :
                (symbol === `mischer`) ? `M8 6a1 1 0 014 0A1 1 0 018 6H6L1 9V3L6 6l3 5H3L9 1H3L6 6` : //`M8 6a1 1 0 013 0A1 1 0 018 6H6L2 8V4L6 6l2 4H4L8 2H4L6 6` : //`M6 6 3 0 9 0 3 12 9 12 6 6 0 3 0 9 6 6 9 6A1 1 0 0012 6 1 1 0 009 6` :
                (symbol === `ventil`) ? `M8 6a1 1 0 014 0A1 1 0 018 6H6l3 5H3L9 1H3L6 6` : //`M9 6a1 1 0 013 0A1 1 0 019 6H6l3 6H3L9 0H3L6 6` :
                (symbol === `aggregat`) ? `m2 9Q1 8 1 6T2 3m8 6q1-1 1-3T10 3M1 6H11` :
                (symbol === `puffer`) ? `` : //`M 0 12 C 0 5.4 5.4 0 12 0` :
                (symbol === `waermetauscher`) ? `M 0 24 L 12 0 L 12 24 L 0 24 L 0 0 L 12 0` :
                (symbol === `heizpatrone`) ? `M0 3V9H6V3H0M6 8h5c1 0 1-1 0-1 1 0 1-1 0-1 1 0 1-1 0-1 1 0 1-1 0-1H6M6 5h5M6 6h5M6 7h5` :
                (symbol === `luefter`) ? `m2 9a1 1 0 008-6A1 1 0 002 9L3 2M9 2l1 7` : //M2 9A1 1 0 0010 3 1 1 0 002 9L3 2M9 2 10 9M6 6C6 4 5 2 3 2 3 4 4 6 6 6 8 6 9 8 9 10 7 10 6 8 6 6
                (symbol === `lueftungsklappe`) ? `M5 6A1 1 0 007 6 1 1 0 005 6M6 1 6 5M6 7 6 11` :
                (symbol === `gassensor`) ? `M 1 3 L 11 3 L 11 9 L 1 9 L 1 3 M 3 3 L 3 4 M 5 3 L 5 4 M 7 3 L 7 4 M 9 3 L 9 4 M 3 9 L 3 8 M 5 9 L 5 8 M 7 9 L 7 8 M 9 9 L 9 8` :
                (symbol === `schalter`) ? `M0 6 2 6 11 4M10 4 10 6 12 6` : //M0 6 2 6 9 0M10 4 10 6 12 6M2 6 11 4
                (symbol === `zaehler`) ? `M1 3v7H11V3H1M2 4V7h8V4H2` :
                ``;

      el.setAttributeNS(null, `d`, d);
    }

    
    if (symbol === `kessel`) {
      icon.classList.add(`flame`);
      [`red`, `orange`, `yellow`, `white`, `blue`].forEach(color => {        
        const div = document.createElement(`div`);
        div.classList.add(`flameLayer`, color);
        icon.appendChild(div);
      });
    }
    if (symbol === `button`) {
      icon.value = `LinkButton;0`;
    }
    
    if (symbol === `path`) {
      [`icon`, `signal`].forEach(elType => {      
        const el = document.createElementNS(SVG_NS, `path`);
        icon.appendChild(el);
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
    return icon;
  }
}

function createVisuItem(...attributes) {
  //console.log(attributes);
  const visuItem = document.createElement(`div`);
  visuItem.classList.add(`visuItem`);
  
  const divIcon = document.createElement(`div`);
  divIcon.classList.add(`divIcon`);
  
  const divSignals = document.createElement(`div`);
  divSignals.classList.add(`divSignals`);
  
  //default attributes:
  visuItem.setAttribute(`iconPosition`, `left`);
  
  let icon;
  attributes.forEach(attribute => {
    Object.entries(attribute).forEach(([key, value]) => {
      //console.log(`${key} ${value}`);
      
      //Save everything as attribute for .visu.txt file!
      visuItem.setAttribute(key, value);
      
      if (key.toLowerCase() === `icon`) {
        const target = (value === `button`) ? divSignals : divIcon ;
        target.appendChild(createIcon(value));       
        icon = value;
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
  
  if (icon !== `puffer`) {
    visuItem.appendChild(divIcon);
    visuItem.appendChild(divSignals);
  }
  
  
  if (icon !== `temperatur`) {
    const divIconSignals = [`Error`, `Freigabe`, `Betriebsart`, `Absenkung`];
    if (icon !== `button`) {
      divIconSignals.push(`Betrieb`);
      divIconSignals.reverse();
    }
    divIconSignals.forEach(signal => {
      const div = document.createElement(`div`);
      const parent = (!icon || (signal !== `Betrieb` &&  icon.match(/(aggregat)|(kessel)|(puffer)/))) ? visuItem : divIcon;
      parent.appendChild(div);
      div.classList.add(`div${signal}`, `divIconSignal`);
      div.toggleAttribute(`NA`, true);
      div.innerText = (signal === `Error`)        ? `⚠`  :
                      (signal === `Freigabe`)     ? `⏺` :
                      (signal === `Betriebsart`)  ? `✋`  :
                      (signal === `Absenkung`)    ? `🌜`  :
                      `0`;
    });
  }

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

  document.querySelector(`.visuTabs`).addEventListener(`click`, visuTabsClickEventHandler);
  
  document.querySelectorAll(`.btnUnDo, .btnReDo`).forEach(btn => btn.addEventListener(`click`, unDoReDoEventHandler));
  document.querySelector(`.btnSave`).addEventListener(`click`, saveBtnHandler);
  document.querySelector(`#openLocaleFile`).addEventListener(`input`, openLocalFileEventHandler);
  document.querySelector(`[type=color]`).addEventListener(`input`, colorInputEventHandler);

  document.querySelector(`.signalTable`).addEventListener(`input`, signalTableInputEventHandler);
  document.querySelectorAll(`.cbSignalTableColumnVisibility`).forEach(cb => cb.addEventListener(`change`, signalTableColumnVisibilityHandler));
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

  document.querySelector(`.visuTabs`).removeEventListener(`click`, visuTabsClickEventHandler);
}

function calcSvgCoordinates(ev) {
  //console.log(ev);
  const activeSvg = document.querySelector(`svg.active`);
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

    const activeSvg = document.querySelector(`svg.active`);
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
    const color = (selectionArea.partialSelection) ? YELLOW_HEX : GREEN_HEX;
    selectionArea.setAttributeNS(null,`fill`, color);

    selectionAreaHandler();
  }
}

function drawModeClickEventHandler(ev) {
  const activeSvg = document.querySelector(`svg.active`);
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
  const activeSvg = document.querySelector(`svg.active`);
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
    btn.addEventListener(`click`, unDoReDoEventHandler);
  });
  updateUnDoReDoStack(`reset`);

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

function initSignalTable(visuLiveData) {
  const signalTableBody = document.querySelector(`.signalTable tbody`);
  if (visuLiveData) {
    //create table according to liveSignals
  }
  else {
    //create basic table (32 DI, 32 AI, 32 DO, 8 AO, CAN?)
    [`DI`, `AI`, `DO`, `AO`, `CAN`].forEach(signalGroup => {
      const channels =  (signalGroup === `AO`) ? 8 :
                        (signalGroup === `CAN`) ? 4 :
                        32;
      for (let i=1; i<=channels; i++) {
        const tr = document.createElement(`tr`);
        signalTableBody.appendChild(tr);
        [`UsageCount`, `RtosTerm`, `SignalId`, `Tooltip`, `DecPlace`, `Unit`, `Style`, `TrueTxt`, `FalseTxt`].forEach(col => {
          const td = document.createElement(`td`);
          tr.appendChild(td);
          if (col === `UsageCount`) {
            td.innerText = 0;
            td.classList.add(`${signalGroup}${i}count`);
          }
          else if (col.match(/(Rtos)|(SignalId)|(Tooltip)|(Txt)/)) {
            const input = document.createElement(`input`);
            td.appendChild(input);
            input.classList.add(`txt${col}`);
            input.type = `text`;
            if (col === `SignalId`) {
              input.value = `${signalGroup}${i}`;
              input.setAttribute(`signalId`, `${signalGroup}${i}`);
              input.readOnly = true;
              input.draggable = true;
              if (!signalGroup.match(/(DI)|(DO)/)) {
                input.setAttribute(`decPlace`, 1);
                input.setAttribute(`unit`, `°C`);
              }
            }
            else if (col.match(/(Txt)/)) {
              input.setAttribute(`list`, `favBoolTxtList`);
            }
          }
          else {
            const select = document.createElement(`select`);
            td.appendChild(select);
            select.classList.add(`sel${col}`);

            if (col === `DecPlace`) {
              [0, 1, 2, 3, 4].forEach(decPlace => {
                const option = document.createElement(`option`);
                select.appendChild(option);
                option.innerText = decPlace;
                option.value = decPlace;
                option.selected = (decPlace === 1 && !signalGroup.match(/(DI)|(DO)/));
              });
            }

            if (col === `Unit`) {
              [``, `°C`, `bar`, `V`, `kW`, `m³/h`, `mWS`, `%`, `kWh`, `Bh`, `m³`, `°Cø`, `mV`, `UPM`, `s`, `mbar`, `A`, `Hz`, `l/h`, `l`].forEach(unit => {
                const option = document.createElement(`option`);
                select.appendChild(option);
                option.innerText = unit;
                option.value = unit;
                option.selected = (unit === `°C` && !signalGroup.match(/(DI)|(DO)/));
              });
            }

            if (col === `Style`) {
              [``, `sollwert`, `grenzwert`].forEach(style => {
                const option = document.createElement(`option`);
                select.appendChild(option);
                option.innerText = style;
                option.value = style;
                option.setAttribute(`stil`, style);
              });
            }



          }




          
        });


        /*
        tr.type = `text`;
        tr.classList.add(`${signalGroup}${i}`);
        tr.readOnly = true;
        tr.draggable = true;
        tr.value = `${signalGroup}${i}`;
        tr.toggleAttribute(`isBool`, signalGroup.match(/(DI)|(DO)/));
        */
      }
    });
  }

  [`RtosTerm`, `SignalParameters`].forEach(colName => {
    const cb = document.querySelector(`#cbShow${colName}`);
    const col = document.querySelector(`.col${colName}`);
    col.style.visibility = (cb.checked) ? `` : `collapse`;
  });



}

function createSignalTableOLD(visuLiveData) {
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
      const inpSignals = document.querySelectorAll(`.signalTable input[type=text]`);
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
  [`temperatur`, `heizkreis`, `pumpe`, `mischer`, `ventil`, `aggregat`, `kessel`, `puffer`, `waermetauscher`, `heizpatrone`, `luefter`, `lueftungsklappe`, `button`, `gassensor`, `schalter`, `zaehler`].forEach(el => {
    visuItemPool.appendChild(createVisuItem({icon: el}));
  });
  
  return visuItemPool;
}

function enterVisuEditor(initialCall) {
  if (initialCall) {
    //document.body.appendChild(createSignalTable());
    initSignalTable();
    document.body.appendChild(createVisuItemPool());
    //document.body.appendChild(createEditorTools());
    document.querySelector(`#selStrokeDasharray`).style.color = document.querySelector(`.colorPicker`).value;
    updateUnDoReDoStack(`reset`);
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
  const elClassNames = [`divVisu`, `visuTabs`];
  elClassNames.forEach(className => {
    const el = document.querySelector(`.${className}`);
    if (reset) {
      el.unDoReDoStack = {idx: 0, stack: [el.innerHTML]};
    }
    else {
      const {unDoReDoStack} = el;
      unDoReDoStack.stack.length = ++unDoReDoStack.idx;
      unDoReDoStack.stack.push(el.innerHTML);
    }
  });
  updateUsedCount();
}
/*********************EventHandlers*********************/
function visuTabsClickEventHandler(ev) {
  //console.log(ev.target);
  const tabIdx = ev.target.getAttribute(`tab-idx`);
  if (tabIdx) {
    switchVisuTab(tabIdx);
  }
  else {
    addVisuTab();
  }
}

function addVisuTab() {
  const visuTabs = document.querySelector(`.visuTabs`);
  
  document.querySelector(`.bgSVG.active`).classList.remove(`active`);
  const divVisu = document.querySelector(`.divVisu`);
  divVisu.appendChild(createBackgroundSVG(visuTabs.childElementCount));

  const activeTab = visuTabs.querySelector(`.visuTab.active`);
  const newTab = activeTab.cloneNode();
  activeTab.classList.remove(`active`);
  newTab.setAttribute(`tab-idx`, visuTabs.childElementCount);
  newTab.innerText = `Tab${visuTabs.childElementCount}`;
  visuTabs.insertBefore(newTab, visuTabs.querySelector(`.addTab`));

  updateUnDoReDoStack();
}

function switchVisuTab(tabIdx) {
  const targetElements = document.querySelectorAll(`[tab-idx="${tabIdx}"]`);
  if (targetElements.length) {
    document.querySelectorAll(`.active`).forEach(el => el.classList.remove(`active`));
    targetElements.forEach(el => el.classList.add(`active`));
  }

  updateUnDoReDoStack();
}

function divVisuContextMenuEventHandler(ev) {
  ev.preventDefault();

  if (!cancelCurrentSelection()) {
    drawModeClickEventHandler(ev); //drawing only starts when no selection was active
  }

  /*
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
  */
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
      //target.setAttribute(`selected`, `true`);
    }
  }
}

function divVisuClickEventHandler(ev) {
  //console.log(ev);
  let actionExecuted = false;
  
  if (ev.target.type === `button`) {
    ev.target.type = `text`; //convert button to text element
    ev.target.fallbackVal = ev.target.value; //perceive current Text for cancelAction 
    ev.target.addEventListener(`blur`, linkBtnBlurHandler);
    actionExecuted = true;
  }
  
  const selectionArea = document.querySelector(`.selectionArea`);
  if (!actionExecuted & !selectionArea) {
    actionExecuted |= removeDivIconSignal(ev);
  }

  const visuItem = ev.target.closest(`.visuItem`);

  if (!actionExecuted & visuItem) {
    //cancelCurrentSelection();
    visuItem.setAttribute(`selected`, `true`);
  }
  else {
    actionExecuted |= cancelCurrentDrawing();
    //console.log({actionExecuted});
    if (!actionExecuted) {
      selectModeClickEventHandler(ev);  //selection only starts when no other action was executed
    }
  }
  
  
  /*
  if (!cancelCurrentSelection()) {
    drawModeClickEventHandler(ev); //drawing only starts when no selection was active
  }
  */  
}

function linkBtnBlurHandler(ev) {
  //console.log(ev);
  ev.target.type = `button`;
  ev.target.removeEventListener(`blur`, linkBtnBlurHandler);
  
  if (ev.type === `keydown`) {
    if(ev.key === `Escape`) {
      ev.target.value = ev.target.fallbackVal; //cancelAction => fallbackVal
    }
    document.activeElement.blur();
  }
  else {
    selectModeClickEventHandler(ev); //call Handler if not keyDown (Esc | Enter) to prevent selection starting on click
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
    ev.target.removeAttribute(`signalId`);
    ev.target.removeAttribute(`title`);
    ev.target.setAttribute(`NA`, true);
    updateUsedCount();
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
  const draggingItems = document.querySelectorAll(`[dragging]`);
  if (draggingItems.length === 1 & draggingItems[0].matches(`.txtSignalId`)) {    
    if (ev.target.matches(`.divError, .divFreigabe, .divBetriebsart, .divAbsenkung, .divBetrieb`)) {
      ev.target.removeAttribute(`NA`);
    }
  }
}

function divVisuDragLeaveEventHandler(ev) {
  //console.log(ev);
  const target = (ev.target.nodeName === `#text`) ? ev.target.parentNode : ev.target; //workaround needed bc pressing Esc while dragover .divIconSignal leads to error...
  if (!target.matches(`[signalId]`) && target.matches(`.divIconSignal`)) {
    target.toggleAttribute(`NA`, true);
  }
}

function divVisuDragOverEventHandler(ev) {
  const draggingItem = document.querySelector(`[dragging]`);  //forEach when more than 1 item...
  if (draggingItem) {
    const visuItem = ev.target.closest(`.visuItem`);
    const visuItemToDivVisu = (ev.target.closest(`.divVisu`) && draggingItem.matches(`.visuItem`));
    const signalToVisuItem = draggingItem.type === `text` && visuItem && !ev.target.closest(`.visuEditElement`);
    if (visuItemToDivVisu || signalToVisuItem) {
      ev.preventDefault();
      ev.dataTransfer.dropEffect = (ev.ctrlKey || draggingItem.closest(`.visuEditElement`)) ? `copy` : `move`;
    }
    if (signalToVisuItem) {
      //console.log(ev.target);
      //setTimeout(setIconPosition, 1000, ev);
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
      if (target.closest(`.divIconSignal`)) {
        Array.from(draggingItem.attributes).forEach(attr => {
          if (attr.name.match(/(signalId)|(decPlace)|(unit)|(trueTxt)|(falseTxt)/i)) {
            target.setAttribute(attr.name, attr.value);
          }
        });
        target.title = `${draggingItem.value} (click to remove Signal)`;
        dropItem.remove();
      }
      else {
        const visuItem = target.closest(`.visuItem`);
        const divSignals = visuItem.querySelector(`.divSignals`);
        divSignals.appendChild(dropItem);
      }
    }
    updateUnDoReDoStack();
  }

  removeAllDraggingAttributes();
}

function dblClickEventHandler(ev) {
  const visuItem = ev.target.closest(`.visuItem`);
  const btn = (visuItem) ? visuItem.querySelector(`[type=button]`) : null;
  if (btn) {
    const current = btn.getAttribute(`writing`);
    if (current === `downward`) {
      btn.removeAttribute(`writing`);
    }
    else if (current === `upward`) {
      btn.setAttribute(`writing`, `downward`);
    }
    else if (!current) {
      btn.setAttribute(`writing`, `upward`);
    }
  }
  const svg = (visuItem) ? visuItem.querySelector(`svg`) : null;
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
  if (document.activeElement.matches(`.visuItem[icon=button] input`)) {
    if (key.match((/(escape)|(enter)/))) {
      linkBtnBlurHandler(ev);
    }
  }
  if (!document.activeElement.matches(`.visuItem[icon=button] input`)) {
    const auxKeys = ev.altKey | ev.ctrlKey | ev.shiftKey;
    if (!auxKeys) {
      if (key === `c`) {
        document.querySelector(`.colorPicker`).click();
      }
      if (key === `g`) {
        document.querySelector(`#cbGridSnap`).click();
      }
      if (key === `o`) {
        document.querySelector(`#cbOrthoMode`).click();
      }
      if (key === `s`) {
        document.querySelector(`.signalPool`).toggleAttribute(`open`);
      }
      if (key === `v`) {
        document.querySelector(`.visuItemPool`).toggleAttribute(`open`);
      }
      if (key === `escape`) {
        cancelCurrentDrawing();
        cancelCurrentSelection();
      }
      if (key.match(/(delete)|(backspace)/)) {
        if (document.activeElement.matches(`.divVisu [readonly]`)) {
          document.activeElement.remove();
        }
        document.querySelectorAll(`[selected]`).forEach(el => el.remove());
        
        updateUnDoReDoStack();
      }
      if (key.match(/[1-9]/)) {
        switchVisuTab(key);
      }
      if (key === `+`) {
        addVisuTab();
      }
    }
    else if (ev.ctrlKey) {
      if (key === `a`) {
        ev.preventDefault();
        document.querySelectorAll(`.visuItem, svg.active *`).forEach(el => el.setAttribute(`selected`, true));
      }
      if (key === `y`)
      document.querySelector(`.btnReDo`).click();
      if (key === `z`)
      document.querySelector(`.btnUnDo`).click();
    }
  
    const activeSvg = document.querySelector(`svg.active`);
    if (activeSvg) {
      if (key.startsWith(`arrow`)) {
        ev.preventDefault();
        if (ev.altKey) {          
          //resize Puffer
          resizePufferEventHandler(ev);

          //set IconPosition
          const iconPosition = (key.includes(`left`)) ? `right` :
                               (key.includes(`right`)) ? `left` :
                               (key.includes(`up`)) ? `bottom` :
                               (key.includes(`down`)) ? `top` :
                               ``;
          document.querySelectorAll(`[selected]`).forEach(el => {
            setIconPosition(el, iconPosition);
          });
        }
        else {
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
        }
        updateUnDoReDoStack();
      }
    }
  }
}

function unDoReDoEventHandler(ev) {
  document.querySelectorAll(`.divVisu, .visuTabs`).forEach(el => {
    const {unDoReDoStack} = el;
    if (ev.target.matches(`.btnUnDo`)) {
      unDoReDoStack.idx = Math.max(0, unDoReDoStack.idx - 1);
    }
    else {
      unDoReDoStack.idx = Math.min(unDoReDoStack.stack.length - 1, unDoReDoStack.idx + 1);
    }
    el.innerHTML = unDoReDoStack.stack.at(unDoReDoStack.idx); //todo...
    console.log(`${unDoReDoStack.idx} of ${unDoReDoStack.stack.length - 1}`);
    el.querySelectorAll(`[type=text]`).forEach(txtEl => txtEl.value = txtEl.getAttribute(`signalId`));
  });
  cancelCurrentDrawing();
  updateUsedCount();
}

function openLocalFileEventHandler(ev) {
  const reader = new FileReader();
  reader.readAsText(ev.target.files[0]);
  reader.addEventListener(`load`, () => {
    const divVisu = document.querySelector(`.divVisu`);
    divVisu.innerHTML = reader.result;
    divVisu.querySelectorAll(`[type=text]`).forEach(txtEl => txtEl.value = txtEl.className);
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

function signalTableInputEventHandler(ev) {
  const {target} = ev;
  const tr = target.closest(`tr`);
  const txtSignalId = tr.querySelector(`.txtSignalId`);
  document.querySelectorAll(`[signalId = ${txtSignalId.value}]`).forEach(el => {
    if (!el.matches(`.divIconSignal`)) {
      if (target.matches(`.txtTooltip`)) {
        if (target.value.trim().length) {
          el.setAttribute(`title`, target.value);
        }
        else {
          el.removeAttribute(`title`);
        }
      }
      if (target.matches(`.selDecPlace`)) {
        if (target.value.trim().length) {
          el.setAttribute(`decPlace`, target.value);
        }
        else {
          el.removeAttribute(`decPlace`);
        }
      }
      if (target.matches(`.selUnit`)) {
        if (target.value.trim().length) {
          el.setAttribute(`unit`, target.value);
        }
        else {
          el.removeAttribute(`unit`);
        }
      }
      if (target.matches(`.selStyle`)) {
        if (target.value.trim().length) {
          target.setAttribute(`stil`, target.value);
          el.setAttribute(`stil`, target.value);
        }
        else {
          target.removeAttribute(`stil`);
          el.removeAttribute(`stil`);
        }
      }
    }
    if (target.matches(`.txtTrueTxt`)) {
      if (target.value.trim().length) {
        el.setAttribute(`trueTxt`, target.value);
      }
      else {
        el.removeAttribute(`trueTxt`);
      }
    }
    if (target.matches(`.txtFalseTxt`)) {
      if (target.value.trim().length) {
        el.setAttribute(`falseTxt`, target.value);
      }
      else {
        el.removeAttribute(`falseTxt`);
      }
    }
  });
  //console.log(ev);
}

function signalTableColumnVisibilityHandler(ev) {
  const col = document.querySelector(`.col${ev.target.id.match(/(RtosTerm)|(SignalParameters)/).at(0)}`);
  col.style.visibility = (ev.target.checked) ? `` : `collapse`;

  const signalTableWidth = document.querySelector(`.signalTable`).getBoundingClientRect().width;
  const signalPool = document.querySelector(`.signalPool`);
  signalPool.style.width = `${signalTableWidth}px`;
}


function updateUsedCount() {
  const divVisu = document.querySelector(`.divVisu`)
  document.querySelectorAll(`.txtSignalId`).forEach(signalId => {
    document.querySelector(`.${signalId.value}count`).innerText = divVisu.querySelectorAll(`[signalId=${signalId.value}]`).length;
  });
}

function resizePufferEventHandler(ev) {
  if (ev.altKey && ev.key.match(/(ArrowUp)|(ArrowDown)/)) {
    ev.preventDefault();
    const pufferWidthInGridSteps = 4; //width is nailed to 4 gridsteps
    const resizeGridSteps = (ev.key.match(/(ArrowUp)/)) ? 1 : -1;
    document.querySelectorAll(`[selected][icon=puffer]`).forEach(puffer => {
      const pufferBox = puffer.getBoundingClientRect();
      const currentAspectRatio = pufferBox.width / pufferBox.height;

      const currentHeightInGridSteps = Math.round(pufferWidthInGridSteps / currentAspectRatio);

      puffer.style.aspectRatio = pufferWidthInGridSteps / Math.max(1, currentHeightInGridSteps - resizeGridSteps);      
    });
  }
}

function setIconPosition(visuItem, iconPosition) {
  if (visuItem.getAttribute(`iconPosition`) !== iconPosition.toLowerCase()) {
    //console.log(visuItem.getAttribute(`iconPosition`));
    const divIcon = visuItem.querySelector(`.divIcon`);
    if (visuItem.matches(`:not([icon = kessel], [icon = aggregat])`) && divIcon) {
      const divIconBox = divIcon.getBoundingClientRect();
      const divVisuBox = document.querySelector(`.divVisu`).getBoundingClientRect();

      const top = (iconPosition === `bottom`) ? undefined : `${100 * (divIconBox.y - divVisuBox.y) / divVisuBox.height}%`;
      const left = (iconPosition === `right`) ? undefined : `${100 * (divIconBox.x - divVisuBox.x) / divVisuBox.width}%`;
      const bottom = (iconPosition === `bottom`) ? `${100 - 100 * ((divIconBox.y - divVisuBox.y) + divIconBox.height) / divVisuBox.height}%` : undefined;
      const right = (iconPosition === `right`) ? `${100 - 100 * ((divIconBox.x - divVisuBox.x) + divIconBox.width) / divVisuBox.width}%` : undefined;
      
      visuItem.setAttribute(`iconPosition`, iconPosition);
      visuItem.removeAttribute(`style`);
      visuItem.style.position = `absolute`;
      visuItem.style.top = top;
      visuItem.style.left = left;
      visuItem.style.bottom = bottom;
      visuItem.style.right = right;
    }
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

/*********************AuxFunctions*********************/
function constrain(val, min, max) {
  return Math.min(max, Math.max(min, val));
}

function cosDeg(deg) {
  const pi = Math.PI;
  return Math.cos(deg/180*pi);
}
function sinDeg(deg) {
  const pi = Math.PI;
  return Math.sin(deg/180*pi);
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


function l(...data) {
  console.log(data);
}