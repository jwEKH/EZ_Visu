'use strict';

//DEBUG Temps
const FORCE_LOAD_SERVERFILE_NAME = ``;//`E_Teststand1`;
const TEST_NEW_VISU_DATA = false;//true;
const FORCE_DONT_LOAD_DEPLOYED_DATA = false;
const FORCE_NA_ITEMS_HIDDEN = true;

//EKH Colors
const EKHlightgray = '#E0E0E0';
const EKHlightgrey = EKHlightgray;
const EKHdarkgray = '#C0C0C0';
const EKHdarkgrey = EKHdarkgray;
const EKHmagenta = 'hsl(334, 74%, 44%)';
const EKHcyan = 'hsl(194, 74%, 44%)';

// Diverse globale Variablen
//JW visuItemStyle
let timerLiveDataReload;
let timerAutoCloseWindow;

const AUTO_CLOSE_WINDOW_TIMEOUT_MS = 600000;
const GRIDSIZE_PERCENT_OF_WIDTH = 3;
//grid soll quadratisch sein => height = width!; bei positionierung (in %) bezieht sich css.top allerdings auf height => snapToGrid bekommt GRIDSIZE_PERCENT_OF_HEIGHT wenn höhenplatzierung!

// Doc ready
$(function () {
    //automatically close after 10 minutes of inactivity; reset on mouse/keyboard down; will be disabled when mode != watch || visurecording ist called
    timerAutoCloseWindow = setTimeout("window.close()", AUTO_CLOSE_WINDOW_TIMEOUT_MS);
    //console.log(AUTO_CLOSE_WINDOW_TIMEOUT_MS.parentElement());
    
    //AddEventListeners
    addEventListenersVisu();
    addEventListenersVisuEditor();
    
    //InitVisu
    //initVisu();
    const visuArea = document.querySelector('.visuArea');
    const visuRatio = visuArea.clientWidth / visuArea.clientHeight;
    visuArea.visuRatio = visuRatio;
    visuArea.gridSize = {};
    visuArea.gridSize.xRel = GRIDSIZE_PERCENT_OF_WIDTH/100;
    visuArea.gridSize.yRel = GRIDSIZE_PERCENT_OF_WIDTH/100 * visuRatio;
    visuArea.gridSize.xRelRemainder = (100 % (100 * visuArea.gridSize.xRel)) / 100; //relevant für style.right!
    visuArea.gridSize.yRelRemainder = (100 % (100 * visuArea.gridSize.yRel)) / 100; //relevant für style.bottom!
    visuArea.mode = 'watch'; //switchable to 'draw' || 'drag'
    visuArea.drawMode = 'line';
    
    window.IdVisu = getParameterByName('Id');   //kompatible ID für alte Visus
    window.VISU_ID = getParameterByName('Id').toUpperCase();
    window.IPE = getIPEFromProjectnumber(IdVisu);
    
    document.title = `Visualisierung ${getProjektName(IdVisu)}`;
    document.querySelector('.visuH1').innerText = document.title;
    const VISU_FILENAME = VISU_ID.trim().replace(' ','_');
    document.querySelector('.fileName').value = VISU_FILENAME;
    
    window.visuConfirmBtnState = disableConfirmBtn(getVisuSettingPermission(IdVisu));
    //MasterWindow init
    if (!window.pngIdx) {
        window.pngIdx = 0;
        window.windowStack = [window];
    }
    
    resizeHandler();

    
    //LoadVisu
    if (window.opener.visuDataRaw) {
        const visuDataParsed = JSON.parse(window.opener.visuDataRaw);
        //pearlTranslationArray: dient der übersetzung alter bezeichnungen zu pearlVars z.B. AI22 -> X_AEIN(22); sowohl vtis als auch vldis!
        window.pearlTranslationArray = parseOldVisuScript(visuDataParsed);
        //console.log(window.pearlTranslationArray);
        
        //Load LiveData 2 maybe generate vmiArray during updateVisuData() & then verify if up2date (see below)
        const visuLiveDataRaw = getOnlineData(VISU_ID);
        const visuLiveDataParsed = (visuLiveDataRaw) ? JSON.parse(visuLiveDataRaw) : undefined;
        //console.log(visuLiveDataParsed);
        window.vldiArray = translateOldVisuLiveData(visuLiveDataParsed, window.pearlTranslationArray);
        //console.log(window.vldiArray);
    
        window.visuData = updateVisuData(visuDataParsed, VISU_FILENAME, window.pearlTranslationArray, window.vldiArray);  //JW updateVisuData to ItemStyle
        //console.log(visuDataParsed, window.visuData);
        const {vtiArray, vmiArray} = window.visuData.visuArrays;
        //console.log(vtiArray);
        //vmiArray (visuMappingArray): Datenbasis zur generierung visuScript & von drag'n'drop MappingElementen für visuEditor
        //console.log(vmiArray);

        if (!visuLiveDataParsed) {
            if (!isAdmin() || getUsername() === `energiekontor NR`) {
                alert(`Anlage Offline!`);
                window.close();
            }
        }
        else {        
            //Verify if LiveData up2date
            const missingLiveDataArray = [];
            vtiArray.forEach(vti => {
                Object.keys(vti.signals).forEach(key => {
                    if (vti.signals[`${key}`].pearlVar.name) {
                        const foundVldi = window.vldiArray.find(vldi => (vti.signals[`${key}`].pearlVar.name === Object.keys(vldi).toString()));
                        if (!foundVldi) {
                            if (missingLiveDataArray.includes(`${vti.signals[`${key}`].pearlVar.name}(${vti.signals[`${key}`].pearlVar.oldName})`))  //entry already exists?
                            missingLiveDataArray.push(`${vti.signals[`${key}`].pearlVar.name}(${vti.signals[`${key}`].pearlVar.oldName})`);
                        }
                    }
                });
            });
            if (missingLiveDataArray.length) console.warn(`missing pearlVars: ${missingLiveDataArray.toString()}`);
        }
        
    }
    
    /* STÖRUNGEN UND ZÄHLERDATEN HOLEN -> kommt hier weg; todo: auf anfrage abholen!
    try {
        //WARUM in DocReady && warum in try()???
        window.visuLiveData = JSON.parse(getOnlineData(IdVisu)); //SCOPE?!??!!!
        console.log(window.visuLiveData);
        stoerungText = ''; //SCOPE?!??!!!
        window.visuLiveData.Stoerungen.forEach(el => stoerungText += `${el.BezNr}. ${el.StoerungText.trim()}<br/>`);
        //alert(stoerungText);
    }
    catch (e) {
        log(e.message);
        log("Es konnten keine Visualisierungsdaten heruntergeladen werden von Steuerung " + IdVisu);
    }
    getOnlinegesamtZaehler(IdVisu); //??*/
    
    
    
    
    
    //initVisuEdit
    if (isAdmin()) {
        //vmiArray (visuMappingArray): Datenbasis zur generierung visuScript & von drag'n'drop MappingElementen für visuEditor        
        if (window.pngIdx === 0) {
            document.querySelector('.visuHeader').classList.remove('hidden');
            const visuEditArea = document.querySelectorAll('.visuEditArea');
            visuEditArea.forEach(el => {
                el.addEventListener('mouseover', visuEditAreaHandler);
                el.addEventListener('mouseout', visuEditAreaHandler);
                if (el.classList.contains('visuDragArea')) el.addEventListener('drag', drag);
            });

            buildVisuDragArea();
            /*var btnStart = document.getElementById('btnStartRecord');
            btnStart.style.display = 'inline-block';*/
        }
        document.querySelector('.windowFooter').classList.toggle('hidden', (window.pngIdx != 0));
        
        const btnSnapToGrid = document.querySelector('.btnSnapToGrid');
        btnSnapToGrid.disabled = false;
        editModeBtnHandler(btnSnapToGrid, true);
        const btnSaveAndDeployVisu = document.querySelector('.btnSaveAndDeployVisu');
        btnSaveAndDeployVisu.disabled = (getUsername() === `energiekontor NR`);
    }
    
    //Build Visu
    if (window.opener.visuDataRaw) {
        window.visuDataRaw = window.opener.visuDataRaw;
        buildVisuFromFile(window.visuData, window.pngIdx);
        updateLiveData(window.vldiArray); //TEMPORÄR AUSKOMMENTIERT!!!!
    }
        
        

    //startCyclicReload of LiveData
    if (VISU_ID.startsWith('P2')) {
        visuArea.RELOAD_INTERVAL_MS = 1000;
        handleCbCyclicReload(!!window.vldiArray);
    }
    else {
        visuArea.RELOAD_INTERVAL_MS = 5000;
    }
});


/******************* Create all needed Urls*******************************/
function createAllLink(IPE) {
    dataUrl = `http://${IPE}/JSONADD/GET?p=2&Var=all`; //FP
//JW paramsUrl = `http://${IPE}/JSONADD/GET?p=1&Var=all`;
    kalenderUrl = `http://${IPE}/JSONADD/GET?p=3&Var=all`; //FP
//JW benachrichtigungsUrl = `http://${IPE}/JSONADD/GET?p=4&Var=sel&V064`;
//JW anmeldungBenachrichtigungsUrl = `http://${IPE}/JSONADD/PUT?V009=QA>` + getUsername();
//JW abmeldungBenachrichtigungUrl = `http://${IPE}/JSONADD/PUT?V009=QA<` + getUsername();
//JW UpURL = `http://${IPE}/JSONADD/PUT?V010=11`;
//JW DownURL = `http://${IPE}/JSONADD/PUT?V010=10`;
//JW RightURL = `http://${IPE}/JSONADD/PUT?V010=12`;
//JW LeftURL = `http://${IPE}/JSONADD/PUT?V010=8`;
//JW EnterURL = `http://${IPE}/JSONADD/PUT?V010=13`;
    TastURL = `http://${IPE}/JSONADD/PUT?V010=`; //this & /*Hilfsfunk*/
    menuLink = `http://${IPE}/JSONADD/PUT?V004=`; //this
//JW menuTextFile = `http://${IPE}/DATA/menue.txt`;
//JW visuTextFile = `http://${IPE}/DATA/visdat.txt`;
}

function createLinkForClickableElement(id) {
    var link = 'http://' + window.IPE + '/JSONADD/PUT?V008=Qz' + id;
    ClickableElementUrlList.push(link);
}

//after refresh the visualisierung canvas is the same as the wochenkalender canvas
//using 2 canvas does not solve the problem, maybe the initcanvas causes this problem (maybe pass canvas as params is not best practice)
// try new approach, initcanvas in visuview.aspx no longer takes any params, but initialize the wochenkalendercanvas directly
function initCanvasWK() {
    //var parent = canvasWK.parentNode;
    //canvasWK.width = parent.width;
    //parent.offsetWidth > 0 ? canvasWK.width = parent.offsetWidth : canvasWK.width = 960;
    //parent.offsetHeight > 0 ? canvasWK.height = parent.offsetHeight : canvasWK.height = 520;
    //var parent = document.getElementById('fernbedienungDisplay');
    //canvasWK.width = parent.offsetWidth;
    //canvasWK.height = parent.offsetHeight;
    canvasWK.width = window.innerWidth;
    canvasWK.height = 520;

    canvasWK.addEventListener("click", function (evt) {
        var rect = canvasWK.getBoundingClientRect();

        if (stat4 == '1' && statmouseweek) {    //status 4:  Wochenkalender in CANVAS und Maus im Wochenfeld 
            var x = evt.clientX - rect.left;
            var y = evt.clientY - rect.top;
            var ypos = Math.round((y - 76) / 30) - 1;
            var xpos = Math.round((x - 50) / 5);
            var maus = Math.round(4001 + ypos * 144 + xpos)
            var TastURLId = `${TastURL}${maus}`;
            var data = getData(TastURLId);
        }
        else {
            var x = evt.clientX - rect.left;
            var y = 8 + evt.clientY - rect.top;

            var xr = Math.round(x / 16)   //   /16 Zeichenbreite
            var yr = Math.round(y / 30)   //   /30 Zeilenhoehe
            //  alert(xr + ',' + yr);
            var maus = Math.round(1000 + yr * 100 + xr)
            var TastURLId = `${TastURL}${maus}`;
            var data = getData(TastURLId);
        }

        if (zykzaehler > einmalholen) {
            zykzaehler = einmalholen;
            tastzaehler = 0;
        }
        else {
            tastzaehler = einmalholen;
        }

        if (xr > 54 && yr < 3) {
            toclipboard = true;
        }

    }, false);

    canvasWK.addEventListener('mousemove', function (evt) {
        var rect = canvasWK.getBoundingClientRect();
        var x = evt.clientX - rect.left;
        var y = evt.clientY - rect.top;
        var xr = Math.round(x / 1)
        var yr = Math.round(y / 1)

        statmouseweek = false;

        if (stat4 == '1') {    //status 4:  Wochenkalender in CANVAS anzeigen 
            if (xr > 50 && xr < 768 && yr > 91 && yr < 300) {
                statmouseweek = true;
                mousex = xr;
                mousey = yr;
                //timeweek(ctxWK);
                timeweek();
            }
        }

    }, false);
}

function timeweek() {
    //ctx = canvasContext;
    ctxWK.fillStyle = "#E0E0E0";
    ctxWK.fillRect(775, 90, 70, 220);

    var ypos = 85 + 30 * (Math.round((mousey - 76) / 30));
    var timehour = Math.round((mousex - 64) / 30);
    var timemin = 10 * Math.round((mousex - 50 - timehour * 30) / 5);
    ctxWK.fillStyle = "#000000";
    if (timemin > 50) {
        timemin = 50;
    }
    if (timemin < 10) {
        ctxWK.fillText(("00" + timehour).slice(-2) + ":00", 782, ypos);
    }
    else {
        ctxWK.fillText(("00" + timehour).slice(-2) + ":" + timemin, 778, ypos);
    }
}



/*function ReloadTimerFunc() {
    ReloadData();

    if (bAutoReload == true) {
        nReloadCycles++;
        if (nReloadCycles > maxReloadCycles) {
            nReloadCycles = 0;
            $("#cbcyclicReload").prop("checked", false);
        }
        else
            timerLiveDataReload = setTimeout(function () { ReloadTimerFunc() }, RELOAD_INTERVAL_MS);
    }
}*/

function displayZaehler() {
    var modal = document.getElementById('modalZaehler');
    window.onclick = function (event) {
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }
    //zähler holen
    var prj = visudata.VCOData.Projektnumer;
    var Projektname = getProjektName(prj);
    var currentdate = new Date();
    var datetime = "&emsp;&emsp;" + currentdate.getDate() + "."
        + (currentdate.getMonth() + 1) + "."
        + currentdate.getFullYear() + " : "
        + currentdate.getHours() + ":"
        + (currentdate.getMinutes() < 10 ? '0' : '') + currentdate.getMinutes();
    //+ currentdate.getSeconds();
    var dateMonthYear = currentdate.getDate() + "."
        + (currentdate.getMonth() + 1) + "."
        + currentdate.getFullYear();

    if (gesamtZaehler != "") {
        document.getElementById("modalHeaderZaehler").innerHTML = '<h4> Zähler: ' + Projektname + " " + datetime + '<span onclick="closeModalZaehler()" class="close">&times;</span>';
        document.getElementById("modalContenZaehler").style.width = '80%';
        document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + gesamtZaehler + "</pre>";
        $('#datetimepicker1').datepicker().on('changeDate', function () {
            var date = $('#inputDate').pearlVar.name();
            var zaehler = getZaheler(prj, date);
            document.getElementById("modalHeaderZaehler").innerHTML = '<h4> Zähler: ' + Projektname + " " + date + '<span onclick="closeModalZaehler()" class="close">&times;</span>';
            if (zaehler != "")
            {
                document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + zaehler + "</pre>";
              }
            else
            {
                document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>  Keine Zählerdaten am: " + date + " gefunden </pre>";
            }
         });
    }
    else
    {
        var aktuelleZaehler = getOnlineAktuellZaehler(prj)
        document.getElementById("modalContenZaehler").style.width = '80%';
        if (aktuelleZaehler != "")
        {
            document.getElementById("modalHeaderZaehler").innerHTML = '<h4> Zähler: ' + Projektname + " " + datetime + '<span onclick="closeModalZaehler()" class="close">&times;</span>';
            document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + aktuelleZaehler + "</pre>";
        }
        $('#datetimepicker1').datepicker().on('changeDate', function () {
            var date = $('#inputDate').pearlVar.name();
            var zaehler = getZaheler(prj, date);
            document.getElementById("modalHeaderZaehler").innerHTML = '<h4> Zähler: ' + Projektname + " " + date + '<span onclick="closeModalZaehler()" class="close">&times;</span>';
            if (zaehler != "")
            {
                document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>" + zaehler + "</pre>";

            }
            else {
                document.getElementById("aktuelleZaehler").innerHTML = "</br> <pre>  Keine Zählerdaten am: " + date + " gefunden </pre>";
   
            }
        });
     }
    modal.style.display = "block";
}

function displayStoerungen() {

    var canvas = document.getElementById("myCanvas");
    var modal = document.getElementById('stoerungModal');
    window.onclick = function (event) {
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }
    //alert(stoerungText);
    if (stoerungText != "") {
        document.getElementById("modalHeader").innerHTML = '<h4> Aktuelle Störungen' + '<span id="closeModal" class="close">&times;</span>';
        document.getElementById("modalContent").style.width = '30%';
        document.getElementById("modalBody").innerHTML = "";
        document.getElementById("modalBody").innerHTML = stoerungText;
        var span = document.getElementById("closeModal");
        span.onclick = function () {
            modal.style.display = "none";
        }
    }
    else {
        document.getElementById("modalHeader").innerHTML = '<h4> Aktuelle Störungen' + '<span id="closeModal" class="close">&times;</span>';
        document.getElementById("modalContent").style.width = '30%';
        document.getElementById("modalBody").innerHTML = "keine weiteren Störungen";
        var span = document.getElementById("closeModal");
        span.onclick = function () {
            modal.style.display = "none";
        }
    }
    modal.style.display = "block";
}


/*
// Neuzeichnung anfordern (Timer ruft auf)
function requestDrawing() {
    requestDrawingFlag = true;
}

// Timer-Mechanik Darstellung und Animation
var TimerVar = setInterval(function () { globalTimer() }, 100);
var TimerToggle = false;
var TimerToggleCounter = 0;
var TimerCounter = 0;

function globalTimer() {
    if (requestDrawingFlag || hasSymbolsFlag) {
        TimerCounter++;
        if (TimerCounter > 10000)
            TimerCounter = 0;

        // 500ms Toggle (1 Hz)
        TimerToggleCounter++;
        if (TimerToggleCounter > 5) {
            TimerToggleCounter = 0;
            TimerToggle = !TimerToggle;
        }
        requestDrawingFlag = false;
    }

}

// Bitmap setzen
function setBitmap(idx) {
    $("#imgTarget").remove();
    $("#imgArea").prepend("<img id='imgTarget' src='" + visudata.VCOData.Bitmaps[idx].URL + "' class='coveredImage'>");
    $(".insideWrapper").css("background-color", bgColors[bmpIndex]);
}*/

function setPNGs(bitmaps) {
    const divVisus = document.querySelectorAll('.divVisu');
    //const length = Math.min(bitmaps.length, divVisus.length);
    divVisus.forEach((el, i) => {
        if (bitmaps[i]) {
            const img = document.createElement('img');
            img.classList.add('png', 'cloaked');
            img.src = bitmaps[i].URL;
            img.style.position = 'absolute';
            img.style.left = 0;
            el.appendChild(img);
        }
    });
}

//JW
function updateLiveData(vldiArray) {
    if (!vldiArray) {
        console.warn(`vldiArray = ${vldiArray}`);
        return;
    }
    vldiArray.forEach(vldi => {
        const vldiEntries = Object.entries(vldi).flat();    //returnValue is encapsulated so flatten it!
        const pearlVarName = vldiEntries[0];
        const value = vldiEntries[1];
        //console.log(pearlVarName, value, vldiEntries);
        const targets = document.querySelectorAll(`.${translatePearlVarName2cssCompatibleClassName(pearlVarName)}`);
        //console.log(targets);
        targets.forEach(target => {
            const {classList} = target;
            const visuItem = getAncestorByClassNames(target, `visuItem`);
            const {vti} = visuItem;
            const {signals} = vti;
            //const {FG, RM, A, BA, ABS, VAL1, VAL2, VAL3} = signals;
            if (classList.contains(`pVal`)) {
                const key = (classList.contains(`pVal1`)) ? `VAL1` : (classList.contains(`pVal2`)) ? `VAL2` : `VAL3`;
                const {pearlVar, nkStellen, unit, inactiveValue, activeValue, isLowActive} = signals[`${key}`];
                if (pearlVar.dataType === `A`) target.innerHTML = value.trim();
                if (pearlVar.dataType && pearlVar.dataType.includes(`F`)) {
                    //(target.innerHTML !== `${parseFloat(value).toFixed(nkStellen)} ${unit}`) ? target.style.background = `red` : target.style.background = ``;
                    target.innerHTML = (key === `VAL2` && (vti.MSR === `BHK` || vti.MSR === `KES`)) ? `(${parseFloat(value).toFixed(nkStellen)} ${(unit) ? unit : ``})` : `${parseFloat(value).toFixed(nkStellen)} ${(unit) ? unit : ``}`;
                }
                if (pearlVar.dataType === `B(1)`) target.innerHTML = ((!!value) ^ isLowActive) ? activeValue : inactiveValue;
                //if (pearlVar.dataType === `B(1)`) console.log(value, (!!value), isLowActive);
            }
            else {
                handleAnimation(value, target);
            }
        });
    });
    /*//console.table(window.visuLiveData.Items);
    const filteredVisuLiveDataItems = window.visuLiveData.Items.filter(item => !item.sWert);
    filteredVisuLiveDataItems.forEach(item => {
        //console.log({item});
        const targets = document.querySelectorAll(`.${item.Bezeichnung.trim()}${item.Kanal}`);
        //console.log(targets);
        targets.forEach(target => {
            const {classList} = target;
            //console.log(classList, item);
            //OLD STYLE
            if (classList.contains('divRM') || classList.contains('pStoerung') || classList.contains('pBA')) handleAnimation(item, target);
            if (classList.contains('pVal')) target.innerHTML = `${item.Wert.toFixed(item.Nachkommastellen)} ${item.EinheitText}`;
            //NEW STYLE
            if (classList.contains('visuItem')) {
                console.log('NWO!');
                const {FG, A, BA, VAL1, VAL2} = item;
                if (FG.pearlVar.name) handleAnimation(FG.pearlVar.name, target.querySelector('.divRM'));
                if (A.pearlVar.name) handleAnimation(A.pearlVar.name, target.querySelector('.pStoerung'));
                if (BA.pearlVar.name) handleAnimation(BA.pearlVar.name, target.querySelector('.pBA'));
                if (VAL1.pearlVar.name) target.querySelector('.pVal1').innerHTML = `${VAL1.Wert.toFixed(VAL1.Nachkommastellen)} ${VAL1.EinheitText}`;
                if (VAL2.pearlVar.name) target.querySelector('.pVal1').innerHTML = `${VAL2.Wert.toFixed(VAL2.Nachkommastellen)} ${VAL2.EinheitText}`;
            }
        });
    });*/
}

//JW
function buildVisuFromFile(visuFile, defaultPngIdx = 0) {    
    const {vtiArray, lineStackList} = visuFile.visuArrays;
    //console.log(visuFile);
    //if (document.querySelectorAll('.divVisu').length > 1) resetVisu();
    resetVisu();

    const maxPngIdx = Math.min(99, vtiArray.reduce((prev, current) => (prev.pngPosition.pngIdx > current.pngPosition.pngIdx) ? prev : current).pngPosition.pngIdx);
    
    while (document.querySelectorAll('.visuCanvas').length <= maxPngIdx) {
        visuTabHandler();
    }
    if (lineStackList) {
        document.querySelectorAll('.visuCanvas').forEach((visuCanvas, idx) => {
            visuCanvas.lineStack = lineStackList[idx];
            drawStack(visuCanvas);
        });
    }

    const divVisus = document.querySelectorAll('.divVisu');
    switchVisuCanvas(divVisus[defaultPngIdx]);

    vtiArray.forEach((vti, i) => {
        const {MSR, idx, signals, pngPosition} = vti;
        const {FG, RM, A, BA, ABS, VAL1, VAL2, VAL3} = signals;
        const color =  ((MSR.startsWith('N') && !FG.pearlVar.name && !RM.pearlVar.name) ||
                        (!FG.pearlVar.name && !RM.pearlVar.name && !A.pearlVar.name && !BA.pearlVar.name && !ABS.pearlVar.name && !VAL1.pearlVar.name && !VAL2.pearlVar.name && !VAL3.pearlVar.name)) ? 
                            EKHlightgrey : 'black';
        const visuItem = createVisuItem(vti, color);
        divVisus[pngPosition.pngIdx].appendChild(visuItem);
    });
    //DEBUG:
    const undefinedClassNameArray = document.querySelectorAll(`.undefined`);
    if (undefinedClassNameArray.length) console.error(undefinedClassNameArray);
    //document.querySelectorAll('.visuAreaFooter .NA, .visuAreaFooter .divIcon').forEach(el => el.classList.add('cloaked'));
}

/*********************CREATE ELEMENTS***********************/
/*createVisuItem*/
function createVisuItem(vti, color = 'black', syncIdx = false) {
    const visuItem = document.createElement('div');
    visuItem.classList.add('visuItem');
    visuItem.vti = JSON.parse(JSON.stringify(vti)); //disconnect Reference to inputParameter vti!
    
    const {MSR, idx, tooltip, link, pngPosition, icon, signals} = visuItem.vti;
    const {pngIdx, xRel, yRel} = pngPosition;
    const {position, orientation, cloaked} = icon;
    const {FG, RM, A, BA, ABS, VAL1, VAL2, VAL3} = signals;

    

    //if (MSR.startsWith('NP') && idx < 99) vti.idx = 99; //vti.idx('NP') starts @ 100; Template have idx==0!
    visuItem.id = solveMultipleIDs(`${MSR}${vti.idx}`);
    visuItem.vti.idx = (parseNo(visuItem.id) || 1);  //update vti.idx due 2 possible change by solveMultipleIDs above!
    if (syncIdx) {
        syncPearlVarNamesWithVisuItemIdx(visuItem.vti, idx);
    }
    visuItem.classList.add(MSR);/*, visuItem.id);*/ //id also in classList seems unneccessary!
    visuItem.title = visuItem.vti.tooltip;

    if (position) visuItem.classList.add(position);    //[`positionTop`, `positionRight`, `positionBottom`] -> undefined === defaultVal === positionLeft
    if (orientation) visuItem.classList.add(orientation);    //moved here! [`orientationRight`, `orientationBottom`, `orientationLeft`] -> undefined === defaultVal === orientationTop

    const divValues = document.createElement('div');
    divValues.classList.add('divValues');
    divValues.classList.toggle('cloaked', MSR === `BTN`); //convert to bool 4 correct handling if undefined!
        for (let i = 1; i <= 3; i++) {
            const pVal = document.createElement('p');
            pVal.classList.add(`pVal`, `pVal${i}`);
            
            if (!!signals[`VAL${i}`].type) pVal.classList.add(`${signals[`VAL${i}`].type}`);// : pVal.classList.remove(`${signals[`VAL${i}`].type}`); //convert to bool 4 correct handling if undefined!
            pVal.innerHTML = (signals[`VAL${i}`].inactiveValue) ? signals[`VAL${i}`].inactiveValue : `VAL${i}`;
            if (signals[`VAL${i}`].pearlVar.name) {
                pVal.classList.add(translatePearlVarName2cssCompatibleClassName(signals[`VAL${i}`].pearlVar.name));
            }
            else if (!signals[`VAL${i}`].inactiveValue) {
                pVal.classList.add('NA', 'hidden');
            }
            divValues.appendChild(pVal);
        }
    visuItem.appendChild(divValues);

    const divIcon = document.createElement('div');
    divIcon.classList.add('divIcon');
    divIcon.classList.toggle('cloaked', !!cloaked); //convert to bool 4 correct handling if undefined!
        const canvasIcon = createCanvasIcon(vti, color);
        divIcon.appendChild(canvasIcon);
        
        const divRM = createDivRM(vti);
        divIcon.appendChild(divRM);

        const booleanSignalsArray = [`FG`, `A`, `BA`, `ABS`];
        const booleanSignalsSymbolArray = [`&#x23FA`, `&#x26A0`, `&#x270B`, `&#x1F31C`]; //Absenkung: Mond: 1F31C, 1F31B, 1F319, 263E; Sonne: 1F31E, 1F505, 1F506, 2600;
        const booleanSignalsTitleArray = [`angefordert`, `anstehende Störung`, `aktuelle Betriebsart`, `Absenkung`];
        booleanSignalsArray.forEach((el, idx) => {
            const pBool = document.createElement('p');
            pBool.classList.add(`p${(el === 'A') ? 'Stoerung' : el}`);
            pBool.title = booleanSignalsTitleArray[idx];
            if (signals[`${el}`].pearlVar.name) {
                pBool.classList.add(translatePearlVarName2cssCompatibleClassName(signals[`${el}`].pearlVar.name));
            }
            else {
                pBool.classList.add('NA', 'hidden');
            }
            pBool.innerHTML = booleanSignalsSymbolArray[idx];

            const targetDiv = (MSR == 'KES' || MSR == 'BHK') ? divValues : divIcon;
            const referenceNode = (MSR == 'KES' || MSR == 'BHK') ? divValues.firstElementChild : null;
            targetDiv.insertBefore(pBool, referenceNode);
        });
    visuItem.appendChild(divIcon);
            
    
    const visuArea = document.querySelector('.visuArea');
    const {gridSize, gridSnap, mode} = visuArea;
    const draggable = (mode === 'drag');
    visuItem.style.left = (gridSnap) ? `${snapToGrid(100*xRel, 100*gridSize.xRel)}%` : `${100*xRel}%`;
    visuItem.style.top = (gridSnap) ? `${snapToGrid(100*yRel, 100*gridSize.yRel)}%` : `${100*yRel}%`;
    handleIconPosition(visuItem);
    toggleDraggable(draggable, visuItem);
    toggleVisuItemEditMode(visuItem);
    
    return visuItem;
}

function initVisuCanvases() {
    const visuArea = document.querySelector('.visuArea');
    if (!visuArea) return visuArea;
    const {gridSize, clientWidth, clientHeight} = visuArea;

    const visuCanvases = document.querySelectorAll('.visuCanvas');
    if (visuCanvases.length < 1) visuTabHandler();
    visuCanvases.forEach(el => {
        el.width = clientWidth;
        el.height = clientHeight;
        if(!el.lineStack) el.lineStack = [];
    });

    const highlightCanvas = document.querySelector('.highlightCanvas');
    highlightCanvas.width = clientWidth;
    highlightCanvas.height = clientHeight;
    highlightCanvas.startPath = {};
    highlightCanvas.startPath.xRel = undefined;
    highlightCanvas.startPath.yRel = undefined;
    highlightCanvas.controlPoint = {};
    highlightCanvas.controlPoint.xRel = undefined;
    highlightCanvas.controlPoint.yRel = undefined;

    const canvasGrid = document.querySelector('.canvasGrid');
    canvasGrid.width = clientWidth;
    canvasGrid.height = clientHeight;
    const {width, height} = canvasGrid;
    const gridSizePx = gridSize.xRel/2 * width; //effektiv ist halbe Gridsize relevant, da tempFühler klein...
    
    const ctx = canvasGrid.getContext('2d');
    ctx.clearRect(0, 0, width, height);
    ctx.setLineDash([gridSizePx/4, gridSizePx/4]);
    
    for (let i=gridSizePx; i<height; i+=gridSizePx) {
        ctx.beginPath();
        ctx.lineWidth = (i > (height-gridSizePx)/2 && i < (height+gridSizePx)/2) ? 3 : 1;
        ctx.moveTo(0, i);
        ctx.lineTo(width, i);
        ctx.stroke();
    }
    for (let i=gridSizePx; i<width; i+=gridSizePx) {
        ctx.beginPath();
        ctx.lineWidth = (i > (width-gridSizePx)/2 && i < (width+gridSizePx)/2) ? 3 : 1;
		ctx.moveTo(i, 0);
		ctx.lineTo(i, height);
        ctx.stroke();
    }
    drawStack();
}

function visuTabClickHandler(event) {
    if (!event) return event;
    const {target} = event;
    visuTabHandler(target)
}

function visuTabHandler(target) {
    const addTab = document.querySelector('.addTab');
    if (!target || target == addTab) target = addVisuCanvas();
    switchVisuCanvas(target);
}

function addVisuCanvas() {
    const target = document.querySelector('.addTab');	
    
    const visuArea = document.querySelector('.visuArea');
    const {clientWidth, clientHeight} = visuArea;
    const visuAreaFooter = document.querySelector('.visuAreaFooter');
    const visuFooter = document.querySelector('.visuFooter');
	const idx = document.querySelectorAll('.visuCanvasTab').length - 1;
    if (idx < 0) return idx;
    document.querySelector('.noCopyLineStackFrom').max = idx;   //updateRangeOfNumberElementToCopyLineStacksFrom
	const newCanvasTab = document.createElement('div');
	visuFooter.insertBefore(newCanvasTab, target);
	newCanvasTab.classList.add('visuCanvasTab');
	newCanvasTab.id = solveMultipleIDs(`visuCanvasTab${idx}`);
	newCanvasTab.idx = idx;
	newCanvasTab.innerHTML = `visuCanvas ${idx}`;
	newCanvasTab.addEventListener('click', visuTabClickHandler);
	//newCanvasTab.addEventListener('contextmenu', rightclick);
	
	//var divVisu = document.getElementById('divVisu');
    
    const newCanvas = document.createElement('canvas');
    newCanvas.classList.add('visuCanvas');
	newCanvas.id = solveMultipleIDs(`visuCanvas${idx}`);
	newCanvas.idx = idx;
    newCanvas.width = clientWidth;
    newCanvas.height = clientHeight;
    newCanvas.lineStack = [];
	
    const newDiv = document.createElement('div');
    newDiv.classList.add('divVisu');
	newDiv.id = solveMultipleIDs(`divVisu${idx}`);
	newDiv.idx = idx;
	//newDiv.addEventListener('dragover', dragoverHandler);
	//newDiv.addEventListener('drop', drop);
    
    newDiv.appendChild(newCanvas);
    visuArea.insertBefore(newDiv, visuAreaFooter);
    
    return newCanvasTab;
}

function switchVisuCanvas(target) {
    //console.log(target);
    //if (!target) return;

    const visuCanvasTabs = document.querySelectorAll('.visuCanvasTab');
    const visuDivs = document.querySelectorAll('.divVisu');
    const visuCanvases = document.querySelectorAll('.visuCanvas');

	visuCanvasTabs.forEach(el => el.classList.toggle('active', (el.idx == target.idx)));
    visuDivs.forEach(el => {
        el.classList.toggle('active', (el.idx == target.idx));
        el.classList.toggle('hidden', (el.idx != target.idx));
    });
    visuCanvases.forEach(el => {
        el.classList.toggle('active', (el.idx == target.idx));
        el.classList.toggle('hidden', (el.idx != target.idx));
    });

    //console.log(document.querySelector('.visuCanvas.active'));
    const focusedItem = document.querySelector('.divVisu.active').focusedItem;
    //console.log(focusedItem);
    updateItemPropertyArea(focusedItem);  //TEMPORÄR AUSKOMMENTIERT!

}


/*********************HILFSFUNKTIONEN***********************/


// Aufruf Funktion
function  drawTextList() {
    var FreitextList = visudata.FreitextList;
    var n = FreitextList.length;
    for (i = 0; i < n; i++) {
        var item = FreitextList[i];
        if (FreitextList[i].bmpIndex == bmpIndex) {
            var x = item.x;
            var y = item.y;
            var txt = item.Freitext;
            ctx.font = item.font;
            ctx.fillStyle = item.BgColor;
            var w = ctx.measureText(txt).width;

            if (item.isVerweis) {
                ctx.save();
                ctx.translate(x, y);
                if (item.VerweisAusrichtung == "up")
                    ctx.rotate(-Math.PI / 2);
                if (item.VerweisAusrichtung == "dn")
                    ctx.rotate(Math.PI / 2);
                ctx.fillRect(0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16);
                ctx.strokeStyle = "black";
                ctx.strokeRect(0 - 6, 0 - item.BgHeight - 6, w + 16, item.BgHeight + 16);
                ctx.fillStyle = item.Color;
                ctx.fillText(txt, 0, 0);
                ctx.restore();
                //remove from loop, coz add to much redundant element each loop (when bitmap change)
                //addLinkButtonToList(x, y, w, item.BgHeight, item.VerweisAusrichtung, item.idxVerweisBitmap, item.Freitext)

            }
            else {
                ctx.fillRect(x - 1, y - item.BgHeight - 1, w + 2, item.BgHeight + 3);
                ctx.fillStyle = item.Color;
                ctx.fillText(txt, x, y);
            }
        }
    }
}

// Loggen
function log(s) {
    $('#output').append(`${new Date().toLocaleTimeString()} ${s}<br/>`);
    const objDiv = document.getElementById("output");
    objDiv.scrollTop = objDiv.scrollHeight;
}

function handleCbCyclicReload(force) {
    //console.log("handleCbCyclicReload");
    const cbcyclicReload = document.querySelector('#cbcyclicReload');
    if (force !== undefined) cbcyclicReload.checked = force;
    if (force) ReloadData();
    //let timerLiveDataReload;
    const visuArea = document.querySelector('.visuArea');
    (cbcyclicReload.checked) ? timerLiveDataReload = setInterval(ReloadData, visuArea.RELOAD_INTERVAL_MS) : clearInterval(timerLiveDataReload);
}

function cbDebugChanged() {
    var checked = $('#cbDebug').prop('checked');
    showLog = checked;
    if (checked == true) {
        //window.resizeTo(wInit, hInit);
        $('#output').show();
    }
    else {
        //window.resizeTo(wInit, hInit - 130);
        $('#output').hide();
    }

}

function UpdateClickHandler() {
    var checked = $('#cbcyclicReload').prop('checked');
    if (checked == false) {
        ReloadData();
    }
}

function ReloadData() {
    if (window.pngIdx) {
        window.vldiArray = window.opener.vldiArray;
    }
    else {
        const testToggleVal = (window.testToggle) ? `1` : ``;
        window.testToggle = (testToggleVal) ? 0 : 1;
        if (TEST_NEW_VISU_DATA) {
            window.vldiArray = JSON.parse(loadVisuFileFromServer(`visdat${testToggleVal}`)).pop();
        }
        else {
            getOnlineDataAsync(window.IdVisu);  //writes directly on window.vldiArray (translationIncluded!)
        }
        //console.log(window.vldiArray);
        
        //const visuArea = document.querySelector('.visuArea');
        //const {windowStack} = visuArea;
        if (window.windowStack) window.windowStack.forEach(el => el.vldiArray = window.vldiArray);
    }

    updateLiveData(window.vldiArray);
}

function closemodalIPKamera(){
    var modalIPKamera = document.getElementById('modalIPKamera');
    modalIPKamera.style.display = 'none';
}

function hideElemementById(id) {
    var selectedElement = document.getElementById(id);
    selectedElement.style.display = "none";

}

function showElemementById(id) {
    var selectedElement = document.getElementById(id);
    selectedElement.style.display = "block";
}

function AnchorHandler(id) {
    //var menuLinkId = menuLink + id;
    let data = getData(`${menuLink}${Id}`);
    //refreshTextAreaWithoutParameterLocal(fernbedienungCanvasContext, fernbedienungCanvas, data);
}
