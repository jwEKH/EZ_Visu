'use strict';

function fetchLiveData(projectNo) {
  const url = `WebServiceEK.asmx/getVisuDataRaw`;
  const options = {};
  options.method = `POST`;
  options.headers = {};
  options.headers[`Content-Type`] = `application/json; charset=utf-8`;
  options.body = `{Projektnummer: '${projectNo}'}`;
  
  return fetchData(url, options);
}

function fetchVisuServerFile(projectNo) {
  const url = `WebServiceEK.asmx/loadVisuFile`;
  const options = {};
  options.method = `POST`;
  options.headers = {};
  options.headers[`Content-Type`] = `application/json; charset=utf-8`;
  options.body = `{fname: '${projectNo}'}`;
  
  return fetchData(url, options);
}

function isAdmin() {
  const url = `WebServiceEK.asmx/isAdmin`;
  const options = {};
  options.method = `POST`;
  options.headers = {};
  options.headers[`Content-Type`] = `application/json; charset=utf-8`;
  options.body = `{}`;

  return fetchData(url, options);
}

async function fetchData(url, options) {
  try {
    const res = await fetch(url, options);
    if (res.ok) {
      const data = await res.json();
      return data.d;
    }
    else {
      console.error(`ServerErrorStatus: ${res.status}`);
    }
  }
  catch(err) {
    console.error(err);
  }
}

/*
function loadVisuFileFromServer(fname) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/loadVisuFile",
        data: '{fname: ' + "'" + fname + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            //log("loadVisuFileFromServer ok");
            res = r;
            return res;
        },
        complete: function (xhr, status) {
            //log("loadVisuFileFromServer complete");
        },
        error: function (msg) {
            //log("loadVisuFileFromServer fail: " + msg);
        }
    });
    return res;
}

/*
function isAdmin() {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/isAdmin",
        data: '{}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            log("getRole ok");
            res = r;
        },
        complete: function (xhr, status) {
            log("getRole complete");
        },
        error: function (msg) {
            log("getRole fail: " + msg);
        }
    });
    return res;
}

// VTO (Visu Transfer Objekt) laden
function loadVTO() {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/loadVTO",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            log("loadVTO ok");
            res = r;
        },
        complete: function (xhr, status) {
            log("loadVTO complete");
        },
        error: function (msg) {
            log("loadVTO fail: " + msg);
        }
    });
    return res;
}

function loadDeployedVTO(prj) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/loadDeployedVTO",
        data: '{Projektnummer: ' + "'" + prj + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            //log("loadDeployedVTO ok");
            res = r;
        },
        complete: function (xhr, status) {
            //log("loadDeployedVTO complete");
        },
        error: function (msg) {
            //log("loadDeployedVTO fail: " + msg);
        }
    });
    return res;
}

// Datei per Name laden
function loadVisuFileFromServer(fname) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/loadVisuFile",
        data: '{fname: ' + "'" + fname + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            //log("loadVisuFileFromServer ok");
            res = r;
            return res;
        },
        complete: function (xhr, status) {
            //log("loadVisuFileFromServer complete");
        },
        error: function (msg) {
            //log("loadVisuFileFromServer fail: " + msg);
        }
    });
    return res;
}

// aktuellen Stand mit Dateinamen speichern
function saveFileToServer(vto) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/saveVisuFile",
        data: vto,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            log("saveFileToServer ok");
            res = r;
        },
        complete: function (xhr, status) {
            log("saveFileToServer complete");
        },
        error: function (msg) {
            log("saveFileToServer fail: " + msg);
        }
    });
    return res;
}

// aktuellen Stand als Deploy in EF speichern
function deployVisu(vto) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/deployVisu",
        data: vto,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            log("deployVisu ok");
            res = r;
        },
        complete: function (xhr, status) {
            log("deployVisu complete");
        },
        error: function (msg) {
            log("deployVisu fail: " + msg);
        }
    });
    return res;
}

// Hintergrundfarbe einer Bitmap ermitteln
function getBGColor(url) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getBackgroundColor",
        data: '{imgURL: ' + "'" + url + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            //VCO_Data = response.d;
            //jsonVCOData = $.parseJSON(VCO_Data);
            log(response.d);
            res = response.d;
            //$(".insideWrapper").css("background-color", response.d);
        },
        complete: function (xhr, status) {
            log("getBGColor ok");
        },
        error: function (msg) {
            log("getBGColor fail: " + msg);
        }
    });
    return res;
}

// Beispieldaten per Projektnummer laden (siehe Impl. Websevice)
function getVisuDownload(prj) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getVisuSampleData",
        data: '{Projektnummer: ' + "'" + prj + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            log("getVisuDownload ok");
            res = r;
        },
        complete: function (xhr, status) {
            log("getVisuDownload complete");
        },
        error: function (msg) {
            log("getVisuDownload fail: " + msg);
        }
    });

    return res;
}

function getOnlineData(prj) {
    let responseData;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getVisuDataRaw",
        data: '{Projektnummer: ' + "'" + prj + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            responseData = response.d;
            log("getOnlineData ok");
        },
        complete: function (xhr, status) {
            const date = new Date();
            const h = `0${date.getHours()}`.slice(-2);
            const m = `0${date.getMinutes()}`.slice(-2);
            const s = `0${date.getSeconds()}`.slice(-2);
            const timestamp = `${h}:${m}:${s}`;

            $("#xlabel").empty();
            $("#xlabel").append("<bdi>Letztes Update: " + timestamp + "</bdi>");
            
            log("getOnlineData complete");
        },
        error: function (msg) {
            log("getOnlineData fail: " + msg);
        }
    });

    return responseData;
}

function getOnlineDataAsync(prj) {
    let responseData;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getVisuDataRaw",
        data: '{Projektnummer: ' + "'" + prj + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (response) {
            responseData = response.d;
            //console.log({responseData});
            log("getOnlineData ok");

        },
        complete: function (xhr, status) {
            if (responseData) { 
                window.vldiArray = translateOldVisuLiveData(JSON.parse(responseData), window.pearlTranslationArray);
                
                const date = new Date();
                const h = `0${date.getHours()}`.slice(-2);
                const m = `0${date.getMinutes()}`.slice(-2);
                const s = `0${date.getSeconds()}`.slice(-2);
                const timestamp = `${h}:${m}:${s}`;

                $("#xlabel").empty();
                $("#xlabel").append("<bdi>Letztes Update: " + timestamp + "</bdi>");
            }
            log("getOnlineData complete");
        },
        error: function (msg) {
            log("getOnlineData fail: " + msg);
        }
    });
}

function getOnlineAktuellZaehler(prj) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getZaehlerAktuell",
        data: '{Projektnummer: ' + "'" + prj + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            log("getOnlineTaehler ok");

            var d = new Date();
            var h = d.getHours(); h = ("0" + h).slice(-2);
            var m = d.getMinutes(); m = ("0" + m).slice(-2);
            var s = d.getSeconds(); s = ("0" + s).slice(-2);
            var t = h + ":" + m + ":" + s;

            $("#xlabel").empty();
            $("#xlabel").append("<bdi>Letztes Update: " + t + "</bdi>");

            res = r;

        },
        complete: function (xhr, status) {
            log("getOnlineTaehler complete");
        },
        error: function (msg) {
            log("getOnlineTaehler fail: " + msg);
        }
    });

    return res;
}

function getOnlinegesamtZaehler(prj) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getZaehlerGesamt",
        data: '{Projektnummer: ' + "'" + prj + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (response) {
            gesamtZaehler = response.d;
            //var r = response.d;
            log("getOnlineZaehler ok");

            var d = new Date();
            var h = d.getHours(); h = ("0" + h).slice(-2);
            var m = d.getMinutes(); m = ("0" + m).slice(-2);
            var s = d.getSeconds(); s = ("0" + s).slice(-2);
            var t = h + ":" + m + ":" + s;

            $("#xlabel").empty();
            $("#xlabel").append("<bdi>Letztes Update: " + t + "</bdi>");

            //return res;

            //res = r;

        },
        complete: function (xhr, status) {
            log("getOnlineZaehler complete");
        },
        error: function (msg) {
            log("getOnlineZaehler fail: " + msg);
        }
    });
    if (res == 1) {

        MeldungAndCloseModal("Aktualisierung erfolgreich");
    }
    if (res == 0) {

        MeldungAndCloseModal("Aktualisierung fehlgeschlagen");
    }
}

function getZaheler(Steuerung, datum) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getZaehlerData",
        data: "{Steuerung: '" + Steuerung + "', datum:'" + datum + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false, // wichtig! sonst kein Rückgabewert
        success: function (response) {
            var r = response.d;
            log("requestHeader ok");
            res = r;
        },
        complete: function (xhr, status) {
            log("requestHeader complete");
        },
        error: function (msg) {
            log("requestHeader fail: " + msg);
        }
    });
    return res;
}



function getData(Url) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getJSONData",
        data: "{Url: '" + Url + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false, // wichtig! sonst kein Rückgabewert
        success: function (response) {
            res = response.d;
            log("requestJSONData ok");
            //res = r;
        },
        complete: function (xhr, status) {
            log("requestJSONData complete");
        },
        error: function (msg) {
            log("requestJSONData fail: " + msg);
        }
    });
    return res;
}



function sendDataWT(Url) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/SendDataToRtos",
        data: "{Url: '" + Url + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false, // wichtig! sonst kein Rückgabewert
        success: function (response) {
            res = response.d;
            log("sendData ok");
            //res = r;
        },
        complete: function (xhr, status) {
            log("sendData complete");
        },
        error: function (msg) {
            log("sendData fail: " + msg);
        }
    });
    return res;
}


function getImage(Url) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getImageIPCam",
        data: "{Url: '" + Url + "'}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false, // wichtig! sonst kein Rückgabewert
        success: function (response) {
            res = 'data:image/png;base64,' + response.d;
            log("requestImage ok");
            //res = r;
        },
        complete: function (xhr, status) {
            log("requestImage complete");
        },
        error: function (msg) {
            log("requestImage fail: " + msg);
        }
    });
    return res;
}



function getProjektName(prj) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getPrjName",
        data: '{ProjektNummer: ' + "'" + prj + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            res = response.d;
            log("getname ok");

        },
        complete: function (xhr, status) {
            log("getname complete");
        },
        error: function (msg) {
            log("getname fail: " + msg);
        }
    });
    return res;
}

function getUsername() {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getUserName",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false, // wichtig! sonst kein Rückgabewert
        success: function (response) {
            res = response.d;
            log("getUserName ok");
            //res = r;
        },
        complete: function (xhr, status) {
            log("getUserName complete");
        },
        error: function (msg) {
            log("getUserName fail: " + msg);
        }
    });
    return res;
}

function getIPEFromProjectnumber(ProjektNummer) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getIPEFromProjektnummer",
        data: '{ProjektNummer: ' + "'" + ProjektNummer + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            //console.log("get IPE ok");
            res = r + ':8080';
        },
        complete: function (xhr, status) {
            //console.log("getIPE complete");
        },
        error: function (msg) {
            //console.log("getIPE fail: " + msg);
        }
    });
    return res;
}

function getVisuSettingPermission(prj) {
    var res;
    $.ajax({
        type: "POST",
        url: "WebServiceEK.asmx/getPermissionForVisuSetting",
        data: '{Projektnummer: ' + "'" + prj + "'" + '}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var r = response.d;
            log("getPermission ok");
            res = r;
        },
        complete: function (xhr, status) {
            log("getPermission complete");
        },
        error: function (msg) {
            log("getPermission fail: " + msg);
        }
    });
    return res;
}
*/