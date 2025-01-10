//Doc ready?! Datum für ZählerModal?!
$(function () {
    $('#datetimepicker1').datepicker({
        locale: 'de',
        format: 'dd.mm.yyyy',
        autoclose: true,
        clearBtn: true,
        endDate: '-1d',
        datesDisabled: '+1d',
        todayHighlight: true,

    });
});

//StartVisu
function addEventListenersVisu() {
    //resizeVisuWindow
    window.addEventListener('resize', function() {
        clearTimeout(window.timerResize);
        window.timerResize = setTimeout(resizeHandler, 200);
    });
    window.addEventListener('beforeunload', closeVisuWindowHandler);
    //window.addEventListener('unload', testFunction);
    //window.addEventListener('pagehide', testfunct);
    const visuArea = document.querySelector('.visuArea');
    visuArea.addEventListener('click', visuClickHandler);

    //document.addEventListener('keydown', visuKeydownHandler);
}

//ModalHandling
function closeModal() {
    var modal = document.getElementById('stoerungModal');
    var span = document.getElementById("closeModal");
    span.onclick = function () {
        modal.style.display = "none";
    }
}
//ModalHandling
function closeModalZaehler() {
    var modal = document.getElementById('modalZaehler');
    modal.style.display = "none";
}
//ModalHandling
function closeModalById(id) {
    var modal = document.getElementById(id);
    modal.style.display = "none";
}

//EventHandler (Keyboard) //FUNKTIONIERT NICHT WIE ERWARTET: REFRESH (F5) FUNKTIONIERT NICHT WENN EVENTHANDLER INEINANDER VERSCHACHTELT!
/*function visuKeydownHandler(event) {
    const visuArea = document.querySelector('.visuArea');
    const {mode} = visuArea;
    const watchModeActive = (!mode || mode == 'watch');
    clearTimeout(timerAutoCloseWindow);
    if (watchModeActive) timerAutoCloseWindow = setTimeout("window.close()", AUTO_CLOSE_WINDOW_TIMEOUT_MS);
    if (isAdmin()) visuEditKeydownHandler(event);
}*/

//EventHandler (Mouse)
function visuClickHandler(event) {
    const visuArea = document.querySelector('.visuArea');
    const {mode} = visuArea;
    const watchModeActive = (!mode || mode == 'watch');
    
    clearTimeout(timerAutoCloseWindow);
    if (watchModeActive) timerAutoCloseWindow = setTimeout("window.close()", AUTO_CLOSE_WINDOW_TIMEOUT_MS);

    visuItemClickHandler(event);

    if (mode == 'drag') visuEditClickHandler(event);
}

function visuItemClickHandler(event) {
    //console.log(event);
    //if (!event) return event;
    const {target, screenX} = event;
    //if (!target) return target;
    const {classList} = target;
    //console.log(classList);
    const visuArea = document.querySelector('.visuArea');
    const watchModeActive = (!visuArea.mode || visuArea.mode == 'watch');

    const visuItem = getAncestorByClassNames(target, 'visuItem');
    if (!watchModeActive || !visuItem) return;
    const {vti, id} = visuItem;
    const {MSR, idx, link} = vti;
    //console.log(visuItem, vti);
    //console.log(link, isNaN(link));
    if (classList.contains(`btnIcon`)) {
        const visuMasterWindow = (window.pngIdx === 0) ? window : window.opener;        
        //Prüfung, ob pngIdx schon geöffnet ist...schließen auch berükksichtigen
        const requestedVisuWindow = visuMasterWindow.windowStack.find(el => el.pngIdx === link);
        //console.log(requestedVisuWindow);
        if (requestedVisuWindow) {
            requestedVisuWindow.focus(); //doesn't bring mainWindow to front by default; FF: change 'dom.disable_window_flip: true' in about:config; see: https://stackoverflow.com/questions/3311293/javascript-bring-window-to-front-if-already-open-in-window-open
            //if (requestedVisuWindow.pngIdx == 0) window.close(); //workaround: close callerWindow...
        }
        else {
            const url = (link === `STÖRUNG`) ? `...störung` : (link === `ZÄHLER`) ? `...zähler` : `/VisuItemStyle.aspx?Id=${window.VISU_ID}`;
            const target = ``;
            const features = (link === `STÖRUNG`) ? `...störung` : (link === `ZÄHLER`) ? `...zähler` : `left=${screenX + 15} width=1300, height=840, location = yes,scrollbars = yes`;
            const visuSubWindow = visuMasterWindow.open(url, target, features);
            
            visuSubWindow.pngIdx = link;
            if (!isNaN(link)) visuSubWindow.vldiArray = visuMasterWindow.vldiArray;
            visuMasterWindow.windowStack.push(visuSubWindow);
        }
    }
    else {
        if (classList.contains('pStoerung')) {
            openStoerung(event);
        }
        else if (link) {
            //const rtosID = `${MSR}${idx.toString().padStart(5 - MSR.length, ' ')}`;
            //const rtosURL = `http://${IPE}/JSONADD/PUT?V008=Qz${rtosID}`;
            //alert(rtosURL);
            
            console.log(openFaceplate(visuItem));
        }
    }
}

function closeVisuWindowHandler(options) {
    const OPTIONS = (typeof options === `string`) ? options.toUpperCase() : ``;

    if (OPTIONS.includes(`ALL`) || OPTIONS.includes(`SUB`) || window.pngIdx === 0) {
        window.windowStack.forEach(win => {
            if (win.pngIdx !== 0) {
                //masterWindow wird nicht explizit geschlossen!
                win.close();
            }
            if (OPTIONS.includes(`ALL`)) window.close(); 
            window.windowStack = [window];
        });
    }
    else {
        window.opener.windowStack = window.opener.windowStack.filter(win => {
            return win.pngIdx !== window.pngIdx;
        });
    }
}

function openStoerung(event) {
    if (!event) return event;
    const {target} = event;
    if (!target) return target;
    
    target.classList.remove('blink');
    window.open(`/VisuWindows.aspx`, '', 'width=1300, height=840, location = yes,scrollbars = yes');
    //alert(`anstehende Störungen ${target.id}: ...to do!`);
}

function resizeHandler() {
    initVisuCanvases();
    //const visuItems = document.querySelectorAll('.visuItem.bottom, .visuItem.right');
    //visuItems.forEach(el => divValueMarginHandler(el));
}

window.onclick = function (event) {
    var modals = Array.from(document.getElementsByClassName("modalVisuBg"));
    modals.forEach(function (el) {
        if (el == event.target) {
            if (el.id.includes('fp')) closeFaceplate();
            if (el.id.includes('Pin')) closePinModal();
        }
    });
}

function btnGroupHandler(target) {
    if (target.classList.contains('pressed')) return target;
    document.getElementsByName(target.name).forEach(el => el.classList.toggle(`pressed`, el === target));
    return target;
}

function btnToggleHandler(target, force) {
    if (!target) return target;
    
    if (target.disabled) return target.className.includes('pressed');
    return target.classList.toggle('pressed', force);
}

function verifyIDs() {
    //returns true if succesful! (only unique IDs)
    const btnVerifyIDs = document.querySelector('.btnVerifyIDs');
    //if (btnVerifyIDs.disabled) return true;

    const caughtItems = visuItemsWithMultipleIDsHighlightHandler();
    //console.log({caughtItems});
    if (caughtItems.length) {
        const caughtIDs = Array.from(caughtItems).flatMap(el => el.id);
        alert(`multiple IDs: ${caughtIDs}`);
        return false;
    }
    else {
        //console.log('alle IDs unique!');
        btnVerifyIDs.disabled = true;
    }
    return true;
}

function hideAllItemsEventHandler(event) {
    const {target} = event;
    if (!target) return;
    hideAllItemsTargetHandler(target);
}

function hideAllItemsTargetHandler(target) {
    if (!target) return;
    const btnIsPressed = target.classList.toggle('pressed');
    const visuItems = document.querySelectorAll('.visuItem');
    visuItems.forEach(el => el.classList.toggle('hidden', btnIsPressed));
}

function showPNGsEventHandler(event) {
    const {target} = event;
    if (!target) return;
    showPNGsTargetHandler(target);
}

function showPNGsTargetHandler(target) {
    if (!target) return;
    const btnIsPressed = target.classList.toggle('pressed');
    const pngs = document.querySelectorAll('.png');
    pngs.forEach(el => el.classList.toggle('cloaked', !btnIsPressed));
}

function visuItemsWithMultipleIDsHighlightHandler() {
    const visuItems = document.querySelectorAll('.visuItem');
    //console.log({visuItems});
    visuItems.forEach(el => el.classList.toggle('errorHighlighter', (itemCountById(el.id) > 1)));
    return document.querySelectorAll('.visuItem.errorHighlighter');
}


/*$(document).keydown(function (event) {
    if (!activeTabID) return undefined;
    //Fernbedienung aktiv	
    if (activeTabID == 'fernbedienung' || activeTabID == 'wochenKalenderImVisu') {
        //set focus on "#displayPanel" when a key was pressed. This prevent scroll effect, when the sidebar overflow
        var displayPanel = document.getElementById('displayPanel');
        displayPanel.focus();

        tastascii = 0;
        tastkey = event.key;
        tastkeylength = tastkey.length;
        tastcode = event.keyCode;
        if (tastkeylength < 2) {         // ein einzelnes Zeichen
            tastascii = tastkey.charCodeAt(0);
        }
        else {
            switch (tastcode) {
                case 37:  //  LEFT 
                    tastascii = 8;
                    break;
                case 38:  //  UP 
                    tastascii = 11;
                    break;
                case 39:  //  RIGTH
                    tastascii = 12;
                    break;
                case 40:  //  DOWN
                    tastascii = 10;
                    break;
                case 13:  //  ENTER
                    tastascii = 13;
                    break;

                case 27:  //  ESC
                    tastascii = 27;
                    break;
                case 17:  //  STRG
                    tastascii = 17;
                    break;

                default:
            }
        }
        if (tastascii > 0) {
            var TastURLId = TastURL + tastascii;
            var data = getData(TastURLId);
        }

        if (zykzaehler > einmalholen) {
            zykzaehler = einmalholen;
            tastzaehler = 0;
        }
        else {
            //  zykzaehler=zykzaehler+1;
            tastzaehler = einmalholen;
        }
    }
});*/

// Mousebutton Eventhandler für Bitmapwechsel
function handleMouseDown(e) {
    var currentBmpIndex = bmpIndex;

    //get mouse click position
    mx = parseInt(e.clientX - offsetX);  //alternativ var x = event.x;
    my = parseInt(e.clientY - offsetY);  //alternativ var y = event.y;

    var match = false; //Flag zur Click-treffer Erkennung (es ist nicht davon auszugehen, dass es keine doppelten Click-treffer gibt!)

    //handle for bitmap change or mouse click on non linked elements
    if (!match) {
        for (var i = 0; i < LinkButtonList.length; i++) {
            var item = LinkButtonList[i];
            //compare coordinate of click event with coordinate of the element in the list
            if (mx > item.x_min && mx < item.x_max && my > item.y_min && my < item.y_max) {

                match = true;

                //if coordinate correct, check the elements text and decide which element and which action do to
                if (item.text == "anstehende Störungen") {
                    displayStoerungen();  //todo: may be use only 1 modal to clean code
                }
                if (item.text == "Zähler anzeigen") {
                    displayZaehler();    //todo: may be use only 1 modal to clean code
                }

                //actual bitmap change
                bmpIndex = item.bmp;
                setBitmap(bmpIndex);
                requestDrawing();
            }
        }
    }

    //handle for button click and clickable item, same philosophy as bitmap change of non linked element above
    if (!match) {
        openFaceplate();
    }

    //click event für die kamera button
    if (((mx - xIPKamera1Button > 0) && (xIPkamera1ButtonBot - mx > 0)) && ((my - yIPKamera1Button > 0) && (yIPkamera1ButtonBot - my > 0))) {
        //alert('on kamera 1');
        //start streaming from IPKamera1
        if (IdVisu.toUpperCase() == 'P 679') {
            displayKameraStream('http://10.0.6.106:8880/action/snap?cam=0&user=admin&pwd=Emb_Mhl_2020');
        }
        if (IdVisu.toUpperCase() == 'P 640') {

            displayKameraStream('http://10.0.3.190:8080/snapshot.cgi?user=admin&pwd=');

        }
    }

    if (((mx - xIPKamera2Button > 0) && (xIPkamera2ButtonBot - mx > 0)) && ((my - yIPKamera2Button > 0) && (yIPkamera2ButtonBot - my > 0))) {
        //alert('on kamera 2');
        window.open("/Ueberwachung2.html");

    }
}

 function displayKameraStream(url) {
    var videomodal = document.getElementById('modalIPKamera');
    videomodal.style.display = "block";
    var videomodalHeader = document.getElementById('modalIPKameraHeader');
    videomodalHeader.innerHTML = 'Überwachungkamera der Anlage ' + Projektname;
    var imgbox = document.getElementById('ImgKamera');
    imgbox.src = getImage(url);
}


/*parseInt OHNE NaN Rückgabe; stattdessen if NaN return = 1*/
/*zur Reorganisation von visuFile -> zuordnung von Werten zu Icons*/
function parseInt1(int) {
    let r = parseInt(int); 
    if (Number.isNaN(r)) return 1;
    return r;
}
/*extrahieren einer Zahl aus einem String*/
/*zur Reorganisation von visuFile -> zuordnung von Werten zu Icons*/
/*NUTZT parseInt1 => GIBT '1' ZURÜCK WENN KEINE ZAHL GEFUNDEN!!!*/
function extractNo(str) {
    if (!str) return 1;
    return parseInt1(str.match(/\d+/));
}
function parseNo(str) {
    //console.log(str.match(/\d+/g));
    //console.log(parseFloat(str.replace(/[^0-9.]/g, ' '))); //replace everything with whitespaces except numbers and decimal points
    return parseFloat(str.replace(/[^0-9.]/g, ' ')); //replace everything with whitespaces except numbers and decimal points
}

function getAncestorByClassNames(obj, className1, className2) {
    let parent = obj;
    if (!className2) className2 = className1;
    while(parent && !parent.classList.contains(className1) && !parent.classList.contains(className2))
        parent = parent.parentElement;
    return parent;
}

function translatePearlVarName2cssCompatibleClassName(pearlVarName) { //pearVarNames enthalten CSS-identifyer!
    return `pearlVar_${pearlVarName.replaceAll(` `,`ws`)
                                   .replaceAll(`(`,`b`)
                                   .replaceAll(`)`,`d`)
                                   .replaceAll(`*`,`x`)
                                   .replaceAll(`/`,`q`)
                                   .replaceAll(`+`,`a`)
                                   .replaceAll(`.`,`o`)
                                   .replaceAll(`,`,`c`)
                                   .replaceAll(`>`,`gt`)
                                   .replaceAll(`<`,`lt`)}`;
}

function syncPearlVarNamesWithVisuItemIdx(vti, oldIdx) {
    const {idx, tooltip, link, signals} = vti;
    if (tooltip) {
        vti.tooltip = tooltip.replace(` ${oldIdx}`, ` ${idx}`).replace(`IDX`, `${idx}`);
    }
    if (link) {
        vti.link = link.toString().replace(` ${oldIdx}`, ` ${idx}`).replace(`IDX`, `${idx}`);
    }
    const signalKeysArray = [`FG`, `RM`, `A`, `BA`, `ABS`, `VAL1`, `VAL2`, `VAL3`];
    signalKeysArray.forEach(key => {
        if (signals[`${key}`].pearlVar.name) {
            signals[`${key}`].pearlVar.name = signals[`${key}`].pearlVar.name.replace(`(${oldIdx})`, `(${idx})`).replace(`IDX`, `${idx}`);
        }
        //inactive Values too?! (KES/BHKW)
        if (signals[`${key}`].inactiveValue) {
            signals[`${key}`].inactiveValue = signals[`${key}`].inactiveValue.replace(` ${oldIdx}`, ` ${idx}`).replace(`IDX`, `${idx}`);
        }
    });
}

//Wert auf Min & Max beschränken; by Default wird von Prozenten ausgegangen => min = 0, max = 100
function minmaxPercent(val, min=0, max=100) {
    return Math.max(min, Math.min(max, val));
}

function handlePmpIdx(bez, kanal) {
    if (bez == 'PH') kanal += 100;
    if (bez == 'KPU') kanal += 200;
    if (bez == 'BPU') kanal += 300;
    if (bez == 'LP') kanal += 500;
    if (bez == 'ZP') kanal += 600;
    if (bez == 'SP') kanal += 700;
    return kanal;
}

/*iconPosition == 'bottom' kann leider nicht allein über CSS gelöst werden => HTML-ElementSwap nötig => handlerFunction*/
function handleIconPosition(visuItem) {
    //if (!visuItem) return;
    const {vti, classList, firstElementChild, style} = visuItem;
    const {icon} = vti;
    const {position} = icon;
    if (classList.contains('KES') || classList.contains('BHK')) return visuItem;

    const visuArea = document.querySelector('.visuArea');
    const {gridSize, gridSnap} = visuArea;

    visuItem.classList.remove(`positionTop`, `positionRight`, `positionBottom`);    //[`positionTop`, `positionRight`, `positionBottom`] -> undefined === defaultVal === positionLeft
    if (position) visuItem.classList.add(position);
    
    const iconWidth = (classList.contains('TI')) ? 100 * gridSize.xRel / 2 : 100 * gridSize.xRel;
    const iconHeight = (classList.contains('TI')) ? 100 * gridSize.yRel / 2 : 100 * gridSize.yRel;
    
    if (position === `positionBottom`) {
        if (firstElementChild.classList.contains('divIcon')) {
            visuItem.appendChild(firstElementChild);
        }
        style.bottom = `${Math.max(0, 100 - parseFloat(style.top) - iconHeight)}%`;
        style.top = '';
    }
    else {
        if (firstElementChild.classList.contains('divValues')) {
            visuItem.appendChild(firstElementChild);
        }
        style.top = `${Math.max(0, 100 - parseFloat(style.bottom) - iconHeight)}%`;
        style.bottom = '';
    }

    if (position === `positionRight`) {
        style.right = `${Math.max(0, 100 - parseFloat(style.left) - iconWidth)}%`;
        style.left = '';
    }
    else {
        style.left = `${Math.max(0, 100 - parseFloat(style.right) - iconWidth)}%`;
        style.right = '';
    }
    
    return visuItem;
};

/*function toggleIconPosition(visuItem, position) {
    if (visuItem.classList.contains('txtItem')) return visuItem;
    const {vto} = visuItem;
    const {icon} = vto;
    if (position == 'left' || position == 'top' || position == 'right' || position == 'bottom') {
        icon.position = position;
    }
    else {
        const positionArray = ['left', 'top', 'right', 'bottom'];
        if (!icon.position) icon.position = positionArray[0];
        icon.position = (icon.position == positionArray.slice(-1)) ? positionArray[0] : positionArray[positionArray.indexOf(icon.position)+1];
    }
    handleIconPosition(visuItem);
    updateItemPropertyArea(visuItem);
}*/

/*function toggleIconOrientation(visuItem, orientation) {
    //const {vto} = visuItem;
    //const {MSR, idx, tooltip, txt, link, icon, AKAs, pos} = vto;
    //const {pngIdx} = link;
    //const {position, orientation} = icon;
    //const {FG, A, BA, VAL1, VAL2} = AKAs;
    //const {xRel, yRel, pngIdx} = pos;

    const {classList, vto} = visuItem;
    const {icon} = vto;
    //const {orientation} = icon;
    const divTxt = visuItem.querySelector('.divTxt');
    const orientationElements = visuItem.querySelectorAll('.canvasIcon, .divRM, .visuBtn, .visuTxt');

    if (orientation == 'up' || orientation == 'hor' || orientation == 'dn' ||
        orientation == 'top' || orientation == 'right' || orientation == 'bottom' || orientation == 'left') {
        icon.orientation = orientation;
    }
    else {
        const orientationArray = [];
        classList.contains('txtItem') ? orientationArray.push('up', 'hor', 'dn') : orientationArray.push('top', 'right', 'bottom', 'left');
        if (!icon.orientation) icon.orientation = orientationArray[0];
        icon.orientation = (icon.orientation == orientationArray.slice(-1)) ? orientationArray[0] : orientationArray[orientationArray.indexOf(icon.orientation)+1];
    }
    
    orientationElements.forEach(el => {
        el.classList.remove('top', 'right', 'bottom', 'left', 'up', 'hor', 'dn');
        if (icon.orientation) el.classList.add(icon.orientation);
    });
        
    if (icon.orientation == 'hor') {
        divTxt.style.width = divTxt.style.height;
        orientationElements[0].style.width = orientationElements[0].style.height;
        divTxt.style.height = '';
        orientationElements[0].style.height = '';
    }
    if (icon.orientation == 'dn') {
        divTxt.style.height = divTxt.style.width;
        orientationElements[0].style.height = orientationElements[0].style.width;
        divTxt.style.width = '';
        orientationElements[0].style.width = '';
    }
    updateItemPropertyArea(visuItem);
}*/

function snapToGrid(val, gridsizePercent, ceil) {
    gridsizePercent /= 2;
    if (ceil) return Math.ceil(val/gridsizePercent)*gridsizePercent;
    return Math.round(val/gridsizePercent)*gridsizePercent;
}

function snapItemToGrid(visuItem) {
    if (!visuItem) return visuItem;
    const visuArea = document.querySelector('.visuArea');
    if (!visuArea) return visuArea;
    const {style} = visuItem;
    const {gridSize} = visuArea;
    const {xRel, yRel, xRelRemainder, yRelRemainder} = gridSize;
    
    if (style.left) visuItem.style.left = `${minmaxPercent(snapToGrid(parseFloat(style.left), 100*xRel))}%`;
    if (style.top) visuItem.style.top = `${minmaxPercent(snapToGrid(parseFloat(style.top), 100*yRel))}%`;
    
    //if (style.right) visuItem.style.right = 
    if (style.right) style.right = `${minmaxPercent(snapToGrid(parseFloat(style.right) - 100*xRelRemainder, 100*xRel) + 100*xRelRemainder)}%`;
    //console.log(style.bottom);
    if (style.bottom) style.bottom = `${minmaxPercent(snapToGrid(parseFloat(style.bottom) - 100*yRelRemainder, 100*yRel) + 100*yRelRemainder)}%`;
    //console.log(style.bottom);
    return visuItem;
}

function itemCountById(id) {
    if (!id) return undefined;
    return document.querySelectorAll(`#${id}`).length;
}

function isUnusedID(id) {
    if (!id) return false;
    //console.log(id);
    //returns 'true' only if ID is NOT present!
    return (document.querySelectorAll(`#${id}`).length == 0);
}

function isUniqueID(id) {
    if (!id) return false;
    //console.log(id);
    //returns 'true' only if ID IS present ONCE
    return (document.querySelectorAll(`#${id}`).length == 1);
}

function solveMultipleIDs(id) {
    const ID = id;
    while (itemCountById(id) > 0 && extractNo(id) < 1000) id = id.replace(extractNo(id), extractNo(id) + 1);
    if (ID != id) console.warn(`changed ID from >${ID}< to >${id}<`);
    if (id >= 1000) console.error(`id overflow: ${id}`);
    return id;
}

// URL Query Strings auswerten
function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

//Zählerstände in Zwischenablage kopieren
function copyToClip() {
    // Create new element
    var el = document.createElement('textarea');

    // Set value (string to be copied)
    el.value = document.getElementById("modalZaehler").innerText;

    // Set non-editable to avoid focus and move outside of view
    el.setAttribute('readonly', '');
    el.style = { position: 'absolute', left: '-9999px' };
    document.body.appendChild(el);
    // Select text inside element
    el.select();
    // Copy text to clipboard
    document.execCommand("copy");
    // Remove temporary element
    document.body.removeChild(el);
}

/*Für die Rückübertragung soll die Werte 10 stellig, rechtbündig sein (Eckhards Vorgabe)
* Die padEnd() in Javascript kann dafür genutzt werden, diese Funktion funktioniert leider nicht im Internet Explorer
* Eine einfache Implementation als Alternativ wird unten geführt
*   *1 Werte werden in einzel Charakter geparst
*   *2 Ein Array mit feste Größe von  10 Elemente erzeugt
*   *3 Letztes Element des Charatker Array = Letztes Element des großfesten Array und weiter
*   *4 Nachdem Auffülen wird die gebliebenen Elemente des großfesten Array mit Leerzeichen
*   *5 Letztendlich werden die Kommas, die aus dem 1. Schritt mit Hilfe von Regex entfern
* */
function padStartUsingArray(wertFromTextbox, targetLength) {
    var valueInCharacter = wertFromTextbox.split('');
    var arrayFixedLength = new Array(parseInt(targetLength));
    var numberOfCharacter = valueInCharacter.length
    for (var k = 0; k < numberOfCharacter; k++) {
        arrayFixedLength[9 - k] = valueInCharacter[numberOfCharacter - 1 - k]
    }
    for (var l = 0; l < 10 - valueInCharacter.length; l++) {
        arrayFixedLength[l] = ' ';
    }
    var formatedValue = arrayFixedLength.toString().replace(/,/g, '');
    return formatedValue;
}

function b32(n) {
    if (!String.prototype.padStart) {
        String.prototype.padStart = function padStart(targetLength, padString) {
            targetLength = targetLength >> 0; //truncate if number or convert non-number to 0;
            padString = String((typeof padString !== 'undefined' ? padString : ' '));
            if (this.length > targetLength) {
                return String(this);
            }
            else {
                targetLength = targetLength - this.length;
                if (targetLength > padString.length) {
                    padString += padString.repeat(targetLength / padString.length); //append to original to ensure we are longer than needed
                }
                return padString.slice(0, targetLength) + String(this);
            }
        };
    }
    else {

        // >>> ensures highest bit isn’t interpreted as a sign
        return (n >>> 0).toString(2).padStart(32, '0');
    }
}

function sleep(miliseconds) {
    var currentTime = new Date().getTime();

    while (currentTime + miliseconds >= new Date().getTime()) {
    }
}