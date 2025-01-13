//Testbench
const PROJECT_NO = `new`;//`P2033`;
const VISU_LIVE_DATA_OLD = `{"Projektnummer":"P2033","Stoerungen":[],"Items":[{"Bezeichnung":"HKNA","Kanal":1,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":" HK1 Nordtrasse    "},{"Bezeichnung":"HKNA","Kanal":2,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":" HK2 Westtrasse    "},{"Bezeichnung":"HKNA","Kanal":3,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":" HK3 Suedtrasse    "},{"Bezeichnung":"KES","Kanal":1,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":"CLICK0"},{"Bezeichnung":"KES","Kanal":2,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":"CLICK0"},{"Bezeichnung":"KES","Kanal":3,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":"CLICK0"},{"Bezeichnung":"HK ","Kanal":1,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":"CLICK0"},{"Bezeichnung":"HK ","Kanal":2,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":"CLICK0"},{"Bezeichnung":"HK ","Kanal":3,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":"CLICK0"},{"Bezeichnung":"HK ","Kanal":4,"iEinheit":0,"EinheitText":null,"Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":"CLICK0"},{"Bezeichnung":"PMK","Kanal":1,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":499.0,"sWert":null},{"Bezeichnung":"PMK","Kanal":2,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":800.0,"sWert":null},{"Bezeichnung":"PMK","Kanal":3,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":436.0,"sWert":null},{"Bezeichnung":"PMB","Kanal":1,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":365.0,"sWert":null},{"Bezeichnung":"AI","Kanal":0,"iEinheit":11,"EinheitText":"°Cø","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":10.06,"sWert":null},{"Bezeichnung":"AI","Kanal":1,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":11.82,"sWert":null},{"Bezeichnung":"AI","Kanal":2,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":89.04,"sWert":null},{"Bezeichnung":"AI","Kanal":3,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":85.460000000000008,"sWert":null},{"Bezeichnung":"AI","Kanal":4,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":85.210000000000008,"sWert":null},{"Bezeichnung":"AI","Kanal":5,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":70.39,"sWert":null},{"Bezeichnung":"AI","Kanal":6,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":54.64,"sWert":null},{"Bezeichnung":"AI","Kanal":7,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":47.870000000000005,"sWert":null},{"Bezeichnung":"AI","Kanal":8,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":86.94,"sWert":null},{"Bezeichnung":"AI","Kanal":9,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":79.31,"sWert":null},{"Bezeichnung":"AI","Kanal":10,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":75.9,"sWert":null},{"Bezeichnung":"AI","Kanal":11,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":58.1,"sWert":null},{"Bezeichnung":"AI","Kanal":12,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":55.58,"sWert":null},{"Bezeichnung":"AI","Kanal":13,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":81.710000000000008,"sWert":null},{"Bezeichnung":"AI","Kanal":14,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":56.160000000000004,"sWert":null},{"Bezeichnung":"AI","Kanal":15,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":77.72,"sWert":null},{"Bezeichnung":"AI","Kanal":16,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":57.9,"sWert":null},{"Bezeichnung":"AI","Kanal":17,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":77.9,"sWert":null},{"Bezeichnung":"AI","Kanal":18,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":65.37,"sWert":null},{"Bezeichnung":"AI","Kanal":19,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":77.33,"sWert":null},{"Bezeichnung":"AI","Kanal":20,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":56.9,"sWert":null},{"Bezeichnung":"AI","Kanal":21,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":34.54,"sWert":null},{"Bezeichnung":"AI","Kanal":22,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":82.43,"sWert":null},{"Bezeichnung":"AI","Kanal":23,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":57.95,"sWert":null},{"Bezeichnung":"AI","Kanal":24,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":88.08,"sWert":null},{"Bezeichnung":"AI","Kanal":25,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":81.210000000000008,"sWert":null},{"Bezeichnung":"AI","Kanal":26,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":67.570000000000007,"sWert":null},{"Bezeichnung":"AI","Kanal":27,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":57.06,"sWert":null},{"Bezeichnung":"AI","Kanal":28,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":56.95,"sWert":null},{"Bezeichnung":"AI","Kanal":30,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"AI","Kanal":32,"iEinheit":2,"EinheitText":"bar","Nachkommastellen":2,"isBool":false,"BoolVal":false,"Wert":-1.0,"sWert":null},{"Bezeichnung":"TH","Kanal":1,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":75.9,"sWert":null},{"Bezeichnung":"TH","Kanal":2,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":77.89,"sWert":null},{"Bezeichnung":"PKT","Kanal":1,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":120.51,"sWert":null},{"Bezeichnung":"PKT","Kanal":2,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":778.47,"sWert":null},{"Bezeichnung":"PKT","Kanal":3,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":0,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"PT","Kanal":1,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":239.0,"sWert":null},{"Bezeichnung":"PT","Kanal":2,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":25.240000000000002,"sWert":null},{"Bezeichnung":"PT","Kanal":3,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":669.69,"sWert":null},{"Bezeichnung":"PT","Kanal":4,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"PT","Kanal":5,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":344.56,"sWert":null},{"Bezeichnung":"PT","Kanal":6,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":77.600000000000009,"sWert":null},{"Bezeichnung":"PT","Kanal":7,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":438.21000000000004,"sWert":null},{"Bezeichnung":"DF","Kanal":1,"iEinheit":5,"EinheitText":"m^3/h","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":7.5,"sWert":null},{"Bezeichnung":"DF","Kanal":2,"iEinheit":5,"EinheitText":"m^3/h","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":6.8500000000000005,"sWert":null},{"Bezeichnung":"DF","Kanal":3,"iEinheit":5,"EinheitText":"m^3/h","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":22.11,"sWert":null},{"Bezeichnung":"DF","Kanal":4,"iEinheit":5,"EinheitText":"m^3/h","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"DF","Kanal":5,"iEinheit":5,"EinheitText":"m^3/h","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":13.86,"sWert":null},{"Bezeichnung":"DF","Kanal":6,"iEinheit":5,"EinheitText":"m^3/h","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":5.3,"sWert":null},{"Bezeichnung":"DF","Kanal":7,"iEinheit":5,"EinheitText":"m^3/h","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":18.0,"sWert":null},{"Bezeichnung":"PBH","Kanal":1,"iEinheit":4,"EinheitText":"kW","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":365.0,"sWert":null},{"Bezeichnung":"AA","Kanal":1,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"AA","Kanal":2,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":28.29,"sWert":null},{"Bezeichnung":"AA","Kanal":4,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":100.0,"sWert":null},{"Bezeichnung":"AA","Kanal":5,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"AA","Kanal":6,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":62.910000000000004,"sWert":null},{"Bezeichnung":"AA","Kanal":7,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":49.31,"sWert":null},{"Bezeichnung":"AA","Kanal":8,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":73.75,"sWert":null},{"Bezeichnung":"MS","Kanal":1,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":61.67,"sWert":null},{"Bezeichnung":"MS","Kanal":2,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":70.83,"sWert":null},{"Bezeichnung":"MS","Kanal":3,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":10.83,"sWert":null},{"Bezeichnung":"MS","Kanal":4,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"MS","Kanal":11,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":35.0,"sWert":null},{"Bezeichnung":"MS","Kanal":12,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":100.0,"sWert":null},{"Bezeichnung":"MS","Kanal":13,"iEinheit":7,"EinheitText":"%","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"PH","Kanal":1,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":true,"Wert":1.0,"sWert":null},{"Bezeichnung":"PH","Kanal":2,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":true,"Wert":1.0,"sWert":null},{"Bezeichnung":"PH","Kanal":3,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":true,"Wert":1.0,"sWert":null},{"Bezeichnung":"PH","Kanal":11,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"PH","Kanal":12,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"KPU","Kanal":1,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":true,"Wert":1.0,"sWert":null},{"Bezeichnung":"KPU","Kanal":2,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"KPU","Kanal":3,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"KL","Kanal":1,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":true,"Wert":1.0,"sWert":null},{"Bezeichnung":"KL","Kanal":2,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":true,"Wert":1.0,"sWert":null},{"Bezeichnung":"KL","Kanal":3,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"BPU","Kanal":1,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":true,"Wert":1.0,"sWert":null},{"Bezeichnung":"BL","Kanal":1,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":true,"Wert":1.0,"sWert":null},{"Bezeichnung":"SG","Kanal":1,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"BI","Kanal":35,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"BI","Kanal":36,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"BI","Kanal":37,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"BI","Kanal":111,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"BI","Kanal":112,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"BI","Kanal":113,"iEinheit":0,"EinheitText":"","Nachkommastellen":0,"isBool":true,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"HKT","Kanal":1,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":76.88,"sWert":null},{"Bezeichnung":"HKT","Kanal":2,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":76.75,"sWert":null},{"Bezeichnung":"HKT","Kanal":3,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":76.850000000000009,"sWert":null},{"Bezeichnung":"HKT","Kanal":4,"iEinheit":1,"EinheitText":"°C","Nachkommastellen":1,"isBool":false,"BoolVal":false,"Wert":0.0,"sWert":null},{"Bezeichnung":"GR","Kanal":1,"iEinheit":2,"EinheitText":"bar","Nachkommastellen":2,"isBool":false,"BoolVal":false,"Wert":1.5,"sWert":null}],"VisuJsonItems":[]}`;
const VISU_LIVE_DATA_NEW = `{"header":{"prjNo":2033,"prjName":" Biogasanlage Dralle  Hohne                       ","date":" 9. 1.2025","time":"17:03:01"},"liveData":{"AI0":   0.61,"TH1": 156.20,"TH2":  65.20,"MS4":   0.00,"PH  1":1,"PH  2":1,"PH  3":1,"PH 11":0,"PH 12":0,"KPU 1":1,"KPU 2":1,"KPU 3":0,"KL  1":1,"KL  2":1,"KL  3":0,"BPU 1":1,"BL  1":1,"SG  1":1,"BI 35":0,"BI 36":0,"BI 37":0,"BI 111":0,"BI 112":0,"BI 113":0,"HKT 1":  63.15,"HKT 2":  63.15,"HKT 3":  63.15,"HKT 4":   0.00,"GR  1":   1.50,"HKNA 1":" HK1 Nordtrasse     ","MS 1":   0.00,"HKNA 2":" HK2 Westtrasse     ","MS 2":   0.00,"HKNA 3":" HK3 Suedtrasse     ","MS 3":   0.00,"PMK 1": 300.00,"PKT 1":   0.00,"MS11":  25.83,"PMK 2": 300.00,"PKT 2":   0.00,"MS12":  25.83,"PMK 3": 300.00,"PKT 3":   0.00,"MS13":  25.83,"PMB 1": 300.00,"PBH 1": 300.00,"AI 1": 156.19,"AI 2": 156.19,"AI 3": 156.19,"AI 4": 156.19,"AI 5": 156.19,"AI 6": 156.19,"AI 7": 156.20,"AI 8": 156.19,"AI 9": 156.20,"AI10": 156.19,"AI11": 156.19,"AI12": 156.19,"AI13": 156.20,"AI14": 156.19,"AI15": 156.19,"AI16": 156.19,"AI17": 156.15,"AI18": 156.17,"AI19": 156.17,"AI20": 156.17,"AI21": 156.17,"AI22": 156.17,"AI23": 156.17,"AI24": 156.17,"AI25": 156.17,"AI26": 156.17,"AI27": 156.17,"AI28": 156.17,"AI29": 156.18,"AI30":   0.00,"AI31":   0.00,"AI32":  -1.00,"AA 1":   0.00,"AA 2": 100.00,"AA 3":   0.00,"AA 4": 100.00,"AA 5":   0.00,"AA 6":  54.67,"AA 7":  54.67,"AA 8":  54.67,"PT 1":   0.00,"DF 1":   0.00,"PT 2":   0.00,"DF 2":   0.00,"PT 3":   0.00,"DF 3":   0.00,"PT 4":   0.00,"DF 4":   0.00,"PT 5":   0.00,"DF 5":   0.00,"PT 6":   0.00,"DF 6":   0.00,"PT 7":   0.00,"DF 7":   0.00}}`;

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

  window.DEBUG = confirm(`DEBUGmode?`);

  initVisu();
  
}, false);
/*********************GenericFunctions*********************/
async function initVisu() {
  //getProjectNo
  const projectNo = (window.DEBUG) ? PROJECT_NO : getProjectNoFromLocation();
  
  //fetchVisuServerFile
  const visuData = (window.DEBUG) ? false : await fetchVisuServerFile(projectNo);
  //getLiveData
  window.liveData = (window.DEBUG) ? VISU_LIVE_DATA_OLD : await fetchLiveData(projectNo); 
  
  buildVisu(visuData);
  buildSignalTable(visuData, window.liveData);

  addGenericEventHandler();

  const cbReloadLiveData = document.querySelector(`#cbReloadLiveData`);
  cbReloadLiveData.checked = true;
  if (!window.DEBUG && cbReloadLiveData.checked) {
    window.reloadLiveDataIntervalId = setInterval(refreshLiveData, 2000);
  }

  const cbEditMode = document.querySelector(`#cbEditMode`);
  if (cbEditMode) {
    cbEditMode.checked = false;
    editModeSwitchHandler();
  }  
}

function addGenericEventHandler() {
  document.querySelector(`#cbEditMode`).addEventListener(`input`, editModeSwitchHandler);
  document.querySelector(`#cbReloadLiveData`).addEventListener(`input`, (ev) => {
    if (ev.target.checked) {
      const simulatedLiveData = (window.DEBUG) ? VISU_LIVE_DATA_OLD : undefined;
      refreshLiveData(simulatedLiveData);
      window.reloadLiveDataIntervalId = setInterval(refreshLiveData, 2000, simulatedLiveData);
    }
    else {
      clearInterval(window.reloadLiveDataIntervalId);
    }
  });
}

function createBackgroundSVG(idx=1) {
  const svg = document.createElementNS(SVG_NS, `svg`);
  svg.setAttributeNS(null, `viewBox`, `0 0 ${SVG_VIEWBOX_WIDTH} ${SVG_VIEWBOX_HEIGHT}`);
  svg.classList.add(`bgSVG`, `active`);
  svg.setAttribute(`tab-idx`, idx);
  //svg.setAttribute(`active`, true);
  return svg;
}

function createIcon(symbol) {

  const icon = (symbol === `flamme`) ? document.createElement(`div`) : document.createElementNS(SVG_NS, `svg`);
  icon.classList.add(`icon`);
  if (icon.tagName === `svg`) {
    const viewBoxHeight = (symbol === `waermetauscher`) ? 25 : 13;
    icon.setAttributeNS(null, `viewBox`, `-0.5 -0.5 13 ${viewBoxHeight}`);
    const path = document.createElementNS(SVG_NS, `path`)
    
    icon.appendChild(path);
    const strokeColor = (symbol === `aggregat`) ? CYAN_HEX : STROKE_COLOR;
    path.setAttributeNS(null,`stroke`, strokeColor);
    const strokeWidth = (symbol.match(/(temperatur)|(aggregat)/)) ? 2 * STROKE_WIDTH : STROKE_WIDTH;
    path.setAttributeNS(null, `stroke-width`, strokeWidth);
    const fillColor = (symbol.match(/(temperatur)|(aggregat)|(schalter)/)) ? `none` : FILL_COLOR;
    path.setAttributeNS(null,`fill`, fillColor);
    
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

    path.setAttributeNS(null, `d`, d);
  }
  else if (symbol === `kessel`) {
    icon.classList.add(`flame`);
    [`red`, `orange`, `yellow`, `white`, `blue`].forEach(color => {        
      const div = document.createElement(`div`);
      div.classList.add(`flameLayer`, color);
      icon.appendChild(div);
    });
  }
  
  return icon;
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
        const target = (value === `button` || value === `text`) ? divSignals : divIcon ;
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
    if (icon !== `button` && icon !== `text`) {
      divIconSignals.push(`Betrieb`);
      divIconSignals.reverse();
    }
    divIconSignals.forEach(signal => {
      const div = document.createElement(`div`);
      const parent = (!icon || (signal !== `Betrieb` &&  icon.match(/(aggregat)|(kessel)|(puffer)/))) ? visuItem : divIcon;
      parent.appendChild(div);
      div.classList.add(`div${signal}`, `divIconSignal`);
      div.toggleAttribute(`na`, true);
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
  divVisu.addEventListener(`dragover`, divVisuDragOverEventHandler);
  divVisu.addEventListener(`drop`, divVisuDropEventHandler);
  divVisu.addEventListener(`click`, divVisuClickEventHandler);
  divVisu.addEventListener(`contextmenu`, divVisuContextMenuEventHandler);

  document.querySelector(`.visuTabs`).addEventListener(`click`, visuTabsClickEventHandler);
  
  document.querySelectorAll(`.btnUnDo, .btnReDo`).forEach(btn => btn.addEventListener(`click`, unDoReDoEventHandler));
  document.querySelector(`.btnSave`).addEventListener(`click`, saveBtnHandler);
  document.querySelector(`#openLocaleFile`).addEventListener(`input`, openLocalFileEventHandler);
  document.querySelector(`[type=color]`).addEventListener(`input`, colorInputEventHandler);

  //document.querySelector(`.signalTable`).addEventListener(`input`, signalTableInputEventHandler);
  //document.querySelectorAll(`.cbSignalTableColumnVisibility`).forEach(cb => cb.addEventListener(`change`, signalTableColumnVisibilityHandler));
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
  const selectionEvent = (document.querySelector(`.selectionArea`) || ev.type === `click`);
  if (!selectionEvent && document.querySelector(`#cbGridSnap`).checked) {
    xSvg = Math.round(GRIDSIZE_AS_PARTS_FROM_WIDTH * (xSvg / activeSvg.viewBox.baseVal.width)) / GRIDSIZE_AS_PARTS_FROM_WIDTH * activeSvg.viewBox.baseVal.width;
    ySvg = Math.round((GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * (ySvg / activeSvg.viewBox.baseVal.height)) / (GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * activeSvg.viewBox.baseVal.height;
  }

  return {xSvg: xSvg, ySvg: ySvg}
}

function selectionAreaHandler() {
  const selectionArea = document.querySelector(`.selectionArea`);
  const selectionAreaBox = selectionArea.getBoundingClientRect();
  const {x, y, width, height} = selectionAreaBox;
  const divVisu = document.querySelector(`.divVisu`);

  const selectDrawnElements = document.querySelector(`#cbSelectDrawnElements`).checked;
  const selectVisuItems = document.querySelector(`#cbSelectVisuItems`).checked;
  const elSelector = (selectDrawnElements & selectVisuItems) ? `line, .visuItem` :
                     (selectDrawnElements) ? `line` :
                     (selectVisuItems) ? `.visuItem` :
                     undefined;
  divVisu.querySelectorAll(elSelector).forEach(el => {
    elBox = el.getBoundingClientRect();

    const match = (selectionArea.partialSelection) ? 
                  (!(x > elBox.x+elBox.width || y > elBox.y+elBox.height || width+x < elBox.x || height+y < elBox.y)) :
                  (x <= elBox.x) && (width+x >= elBox.width+elBox.x) && (y <= elBox.y) && (height+y >= elBox.height+elBox.y);
    el.toggleAttribute(`highlighted`, match);
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
  const activeSvg = document.querySelector(`svg.active`);
  const svgCoordinates = calcSvgCoordinates(ev);
  const selectionArea = activeSvg.querySelector(`.selectionArea`);
  if (selectionArea) {
    selectionArea.remove();
    document.querySelectorAll(`[highlighted]`).forEach(el => {
      el.toggleAttribute(`selected`);
      el.removeAttribute(`highlighted`);
    });
  }
  else {
    const selectionArea = document.createElementNS(SVG_NS, `polygon`);
    activeSvg.appendChild(selectionArea);
    selectionArea.classList.add(`selectionArea`);
    selectionArea.setAttributeNS(null,`opacity`, `0.1`);
    selectionArea.svgCoordinates = svgCoordinates;
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

  return fsEditorTools;
}

function createSignal(attributes) {
  const inputEl = document.createElement(`input`);
  inputEl.value = attributes[`signal-id`];
  inputEl.readOnly = true;
  inputEl.addEventListener(`contextmenu`, editSignalAttributesEventHandler);
  Object.entries(attributes).forEach(([key, value]) => {
    (key === `tooltip`) ? inputEl.setAttribute(`title`, value) : inputEl.setAttribute(key, value);
  });

  return inputEl;
}

function editSignalAttributesEventHandler(ev) {
  if (ev.type === `contextmenu`) {
    ev.preventDefault();
  }
  removeExistingNode(document.querySelector(`.divEditSignal`));

  const divEditSignal = document.createElement(`div`);
  document.body.appendChild(divEditSignal);
  divEditSignal.signalEl = ev.target;
  divEditSignal.classList.add(`divEditSignal`);
  divEditSignal.style.left = `${ev.pageX}px`;
  divEditSignal.style.top = `${ev.pageY}px`;

  const forbiddenAttributeNames = [`class`, `readonly`, `draggable`, `type`];
  getAttributesAsMap(ev.target, forbiddenAttributeNames).forEach((value, key) => {
    createEditSignalRow(key, value).forEach(el => divEditSignal.appendChild(el));
  });

  const selectAddAttribute = createSelectAddAttribute(ev.target.getAttributeNames());
  divEditSignal.appendChild(selectAddAttribute);

  const btnConfirm = document.createElement(`input`);
  btnConfirm.type = `button`;
  btnConfirm.value = `Confirm Changes`;
  btnConfirm.addEventListener(`click`, confirmSignalAttributeEditEventHandler);
  divEditSignal.appendChild(btnConfirm);
}

function confirmSignalAttributeEditEventHandler(ev) {
  const divEditSignal = ev.target.closest(`.divEditSignal`);
  const {signalEl} = divEditSignal;
  divEditSignal.querySelectorAll(`input:not([type=button]), select:not(.selectAddAttribute)`).forEach(attributeInput => {
    const key = attributeInput.getAttribute(`attribute-name`);
    //console.log(key);
    if (attributeInput.type === `checkbox`) {
      signalEl.toggleAttribute(key, attributeInput.checked);
    }
    else if (attributeInput.value) {
      signalEl.setAttribute(key, attributeInput.value);
    }
    else {
      signalEl.removeAttribute(key);
    }
    signalEl.value = signalEl.getAttribute(`signal-id`);
  });
  
  removeExistingNode(document.querySelector(`.divEditSignal`));
}

function createEditSignalRow(key, value) {
  const lbl = document.createElement(`label`);
  lbl.innerText = `${key}:`;
  const input = (key.match(/(unit)|(dec-place)|(stil)|(icon)/)) ? createSelectElement(key) : document.createElement(`input`);
  input.setAttribute(`attribute-name`, key);
  if (key.match(/(toggle)/)) {
    input.type = `checkbox`
  }
  else if (key.match(/(true-txt)|(false-txt)/)) {
    input.setAttribute(`list`, `favBoolTxtList`);
  }

  if (input.type === `checkbox`) {
    input.checked = true;
  }
  else if (value) {
    input.value = value;
  }
  else {
    input.placeholder = key;
  }

  return [lbl, input];
}

function selectAddAttributeInputEventHandler(ev) {
  const divEditSignal = ev.target.closest(`.divEditSignal`);
  createEditSignalRow(ev.target.value).forEach(el => divEditSignal.insertBefore(el, ev.target));
  const selectedOption = ev.target.querySelector(`option[value=${ev.target.value}]`);
  ev.target.removeChild(selectedOption);
  ev.target.disabled = (ev.target.childElementCount <= 1);
}

function createSelectAddAttribute(existingAttributeNames) {
  const selectAddAttribute = createSelectElement(`addAttribute`, existingAttributeNames);
  selectAddAttribute.classList.add(`selectAddAttribute`);
  selectAddAttribute.addEventListener(`input`, selectAddAttributeInputEventHandler);
  return selectAddAttribute;
}

function createSelectElement(type, excludedOptions = []) {
  const options = (type === `unit`) ? [``, `°C`, `bar`, `V`, `kW`, `m³/h`, `mWS`, `%`, `kWh`, `Bh`, `m³`, `°Cø`, `mV`, `UPM`, `s`, `mbar`, `A`, `Hz`, `l/h`, `l`] :
                  (type === `dec-place`) ? [``, 0, 1, 2, 3, 4] :
                  (type === `stil`) ? [``, `sollwert`, `grenzwert`] :
                  (type === `icon`) ? [``, `temperatur`, `heizkreis`, `pumpe`, `mischer`, `ventil`, `aggregat`, `puffer`, `waermetauscher`, `heizpatrone`, `luefter`, `lueftungsklappe`, `gassensor`, `schalter`, `zaehler`] :
                  (type === `addAttribute`) ? [`addAttribute...`, `signal-id`, `rtos-id`, `unit`, `title`, `stil`, `toggle`, `dec-place`, `icon`, `true-txt`, `false-txt`, `range-max`, `range-min`] :
                  [];
  
  const select = document.createElement(`select`);
  options.forEach(value => {
    if (!excludedOptions.includes(value)) {
      const option = document.createElement(`option`);
      select.appendChild(option);
      option.innerText = value;
      option.value = value;
    }
  });

  return select;                
}

function addSignalTableRow(attributes) {
  const signalTableBody = document.querySelector(`.signalTable tbody`);
  const tr = document.createElement(`tr`);
  signalTableBody.appendChild(tr);
  [`UsageCount`, `RtosTerm`, `SignalId`, `Tooltip`, `DecPlace`, `Unit`, `Style`, `TrueTxt`, `FalseTxt`].forEach(col => {
    const td = document.createElement(`td`);
    tr.appendChild(td);
    if (col === `UsageCount`) {
      td.innerText = 0;
      td.classList.add(`${attributes[`signal-id`]}count`);
    }
    else if (col.match(/(Rtos)|(SignalId)|(Tooltip)|(Txt)/)) {
      const input = document.createElement(`input`);
      td.appendChild(input);
      input.classList.add(`txt${col}`);
      input.type = `text`;
      input.value = (col === `SignalId` && attributes[`signal-id`]) ? `${attributes[`signal-id`]}` :
                    (col === `RtosTerm` && attributes[`rtos-id`]) ? `${attributes[`rtos-id`]}` :
                    (col === `Tooltip` && attributes.title) ? `${attributes.title}` :
                    ``;
      if (col === `SignalId`) {
        input.readOnly = true;
        input.draggable = true;
        Object.entries(attributes).forEach(([key, value]) => {
          input.setAttribute(key, value);
        });
        //input.addEventListener(`focus`, highlightSignalsHandler);
      }
      else if (col.match(/(Txt)/)) {
        input.setAttribute(`list`, `favBoolTxtList`);
        if (attributes[`true-txt`] && col.match(/(TrueTxt)/)) {
          input.value = attributes[`true-txt`].trim();
        }
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
          option.selected = (decPlace == attributes[`dec-place`]);
        });
      }

      if (col === `Unit`) {
        [``, `°C`, `bar`, `V`, `kW`, `m³/h`, `mWS`, `%`, `kWh`, `Bh`, `m³`, `°Cø`, `mV`, `UPM`, `s`, `mbar`, `A`, `Hz`, `l/h`, `l`].forEach(unit => {
          const option = document.createElement(`option`);
          select.appendChild(option);
          option.innerText = unit;
          option.value = unit;
          option.selected = (unit === attributes.unit);
        });
      }

      if (col === `Style`) {
        [``, `sollwert`, `grenzwert`].forEach(style => {
          const option = document.createElement(`option`);
          select.appendChild(option);
          //select.setAttribute(`stil`, style);
          option.innerText = style;
          option.value = style;
          option.setAttribute(`stil`, style);
          option.selected = (style === attributes.stil);
        });
      }
    }
  });
}

function initSignalTable(visuLiveData) {
  const signalTableBody = document.querySelector(`.signalTable tbody`);
  if (visuLiveData) {
    //create table according to liveSignals
    //console.log(visuLiveData);
    visuLiveData.filter(signal => signal.Bezeichnung.trim() !== `HK` && signal.Bezeichnung.trim() !== `BHK` && signal.Bezeichnung.trim() !== `KES` && signal.Bezeichnung.trim() !== `WWL`).forEach(signal => {
      const {Bezeichnung, Kanal, Nachkommastellen, iEinheit, sWert} = signal;
      const tr = document.createElement(`tr`);
      signalTableBody.appendChild(tr);
      [`UsageCount`, `RtosTerm`, `SignalId`, `Tooltip`, `DecPlace`, `Unit`, `Style`, `TrueTxt`, `FalseTxt`].forEach(col => {
        const td = document.createElement(`td`);
        tr.appendChild(td);
        if (col === `UsageCount`) {
          td.innerText = 0;
          td.classList.add(`${Bezeichnung.trim()}${Kanal}count`);
        }
        else if (col.match(/(Rtos)|(SignalId)|(Tooltip)|(Txt)/)) {
          const input = document.createElement(`input`);
          td.appendChild(input);
          input.classList.add(`txt${col}`);
          input.type = `text`;
          if (col === `SignalId`) {
            input.value = `${Bezeichnung.trim()}${Kanal}`;
            input.setAttribute(`signal-id`, `${Bezeichnung.trim()}${Kanal}`);
            input.readOnly = true;
            input.draggable = true;
            //input.addEventListener(`focus`, highlightSignalsHandler);
          }
          else if (col.match(/(Txt)/)) {
            input.setAttribute(`list`, `favBoolTxtList`);
            if (sWert && col.match(/(TrueTxt)/)) {
              input.value = sWert.trim();
            }
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
              option.selected = (decPlace === Nachkommastellen);
            });
          }

          if (col === `Unit`) {
            [``, `°C`, `bar`, `V`, `kW`, `m³/h`, `mWS`, `%`, `kWh`, `Bh`, `m³`, `°Cø`, `mV`, `UPM`, `s`, `mbar`, `A`, `Hz`, `l/h`, `l`].forEach((unit, idx) => {
              const option = document.createElement(`option`);
              select.appendChild(option);
              option.innerText = unit;
              option.value = unit;
              option.selected = (idx === iEinheit);
            });
          }

          if (col === `Style`) {
            [``, `sollwert`, `grenzwert`].forEach(style => {
              const option = document.createElement(`option`);
              select.appendChild(option);
              //select.setAttribute(`stil`, style);
              option.innerText = style;
              option.value = style;
              option.setAttribute(`stil`, style);
              option.selected = (Bezeichnung.trim() === `HKT` && style === `sollwert` || Bezeichnung.trim() === `GR` && style === `grenzwert`);
            });
          }
        }
      });
    });
  }
  else {
    if (confirm(`no LiveData found. Create generic signalTable?`)) {
      createGenericSignalTable();
    }
  }

  signalTableTxtSignalIdsAddAttributes();

  //signalTableAddRow();

  [`RtosTerm`, `SignalParameters`].forEach(colName => {
    const cb = document.querySelector(`#cbShow${colName}`);
    const col = document.querySelector(`.col${colName}`);
    col.style.visibility = (cb.checked) ? `` : `collapse`;
  });
}

function createGenericSignalTable() {
  const signalTableBody = document.querySelector(`.signalTable tbody`);
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
            input.setAttribute(`signal-id`, `${signalGroup}${i}`);
            input.readOnly = true;
            input.draggable = true;
            if (!signalGroup.match(/(DI)|(DO)/)) {
              input.setAttribute(`dec-place`, 1);
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
    }
  });
}

function signalTableTxtSignalIdsAddAttributes() {
  document.querySelectorAll(`.signalTable tbody tr`).forEach(tr => {
    const txtSignalId = tr.querySelector(`.txtSignalId`);
    
    const txtRtosTermVal = tr.querySelector(`.txtRtosTerm`).value;
    const txtTooltipVal = tr.querySelector(`.txtTooltip`).value;
    const selDecPlaceVal = tr.querySelector(`.selDecPlace`).value;
    const selUnitVal = tr.querySelector(`.selUnit`).value;
    const selStyleVal = tr.querySelector(`.selStyle`).value;
    const txtTrueTxtVal = tr.querySelector(`.txtTrueTxt`).value;
    const txtFalseTxtVal = tr.querySelector(`.txtFalseTxt`).value;
    
    if (txtRtosTermVal !== ``) {
      txtSignalId.setAttribute(`rtos-id`, txtRtosTermVal);
    }
    if (txtTooltipVal !== ``) {
      txtSignalId.setAttribute(`title`, txtTooltipVal);
    }
    if (selDecPlaceVal !== ``) {
      txtSignalId.setAttribute(`dec-place`, selDecPlaceVal);
    }
    if (selUnitVal !== ``) {
      txtSignalId.setAttribute(`unit`, selUnitVal);
    }
    if (selStyleVal !== ``) {
      txtSignalId.setAttribute(`stil`, selStyleVal);
    }
    if (txtTrueTxtVal !== ``) {
      txtSignalId.setAttribute(`true-txt`, txtTrueTxtVal);
    }
    if (txtFalseTxtVal !== ``) {
      txtSignalId.setAttribute(`false-txt`, txtFalseTxtVal);
    }
  });
}

function createVisuItemPool() {
  const visuItemPool = document.createElement(`details`);
  visuItemPool.classList.add(`visuItemPool`, `visuEditElement`);
  //visuItemPool.setAttribute(`open`, `true`);
  const summary = document.createElement(`summary`);
  summary.innerText = `visuItems`;
  visuItemPool.appendChild(summary);
  [`temperatur`, `heizkreis`, `pumpe`, `mischer`, `ventil`, `aggregat`, `kessel`, `puffer`, `waermetauscher`, `heizpatrone`, `luefter`, `lueftungsklappe`, `button`, `gassensor`, `schalter`, `zaehler`, `text`].forEach(el => {
    visuItemPool.appendChild(createVisuItem({icon: el}));
  });
  
  return visuItemPool;
}

function editModeSwitchHandler() {
  const editModeActive = document.querySelector(`#cbEditMode`).checked;
  
  const divVisu = document.querySelector(`.divVisu`);
  divVisu.toggleAttribute(`edit-mode`, editModeActive);
  
  if (editModeActive) {
    clearInterval(window.reloadLiveDataIntervalId);
    document.querySelector(`#cbReloadLiveData`).checked = false;

    divVisu.querySelectorAll(`.txtSignalId[signal-id]`).forEach(txtSignalId => txtSignalId.value = txtSignalId.getAttribute(`signal-id`));
    divVisu.querySelectorAll(`.divIconSignal[signal-id]`).forEach(divIconSignal => divIconSignal.removeAttribute(`cloaked`));
  }

  if (editModeActive && !document.querySelector(`.visuItemPool`)) {
    //document.body.appendChild(createSignalTable());
    //console.log(window.visuLiveData);
    //initSignalTable(window.visuLiveData);
    document.body.appendChild(createVisuItemPool());
    //document.body.appendChild(createEditorTools());
    document.querySelector(`#selStrokeDasharray`).style.color = document.querySelector(`.colorPicker`).value;
    updateUnDoReDoStack(`reset`);
  }
  
  document.querySelectorAll(`.visuEditElement, .visuTabs, .editorTools`).forEach(el => el.toggleAttribute(`cloaked`, !editModeActive));
  document.querySelectorAll(`[draggable]`).forEach(el => el.setAttribute(`draggable`, (editModeActive) ? `true` : `false`));
  (editModeActive) ? addEditorEventHandler() : removeEditorEventHandler();
  cancelCurrentDrawing();
  cancelCurrentSelection();
  cancelCurrentAttributeEdit();
}

function updateUnDoReDoStack(reset) {
  //cancelCurrentDrawing();
  //cancelCurrentSelection();
  const elClassNames = [`divVisu`, `visuTabs`];
  elClassNames.forEach(className => {
    const el = document.querySelector(`.${className}`);
    if (reset || !el.unDoReDoStack) {
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

  const msSinceLastBlurEvent = ev.timeStamp - window.lastBlurEventTimeStamp;
  let actionExecuted = (msSinceLastBlurEvent < 700) ? true : false; //block contexmenuEvent for 700ms after blurEvent

  actionExecuted |= cancelCurrentSelection();

  actionExecuted |= cancelCurrentAttributeEdit();

  if (!actionExecuted) {
    drawModeClickEventHandler(ev); //drawing only starts when no selection was active
  }
}

function divVisuMouseMoveEventHandler(ev) {  
  drawModeHoverEventHandler(ev);
  selectModeHoverEventHandler(ev);
}

function mouseDownEventHandler(ev) {
  if (ev.buttons === 1) {
    const visuItem = (ev.target.matches(`.txtSignalId`)) ? null : ev.target.closest(`.divVisu .visuItem`);
    //console.log(visuItem);
    if (visuItem) {
      if (!visuItem.matches(`[selected]`)) {
        if (!ev.shiftKey && !ev.ctrlKey) {
          document.querySelectorAll(`[selected]`).forEach(el => {
            if (el !== visuItem) {
              el.removeAttribute(`selected`);
            }
          });
        }
      }
      visuItem.toggleAttribute(`selected`);
    }
    else if (!ev.shiftKey && !ev.ctrlKey) {
      document.querySelectorAll(`[selected]`).forEach(el => el.removeAttribute(`selected`));
    }

    if (ev.target.matches(`[draggable]`)) {
      ev.target.setAttribute(`dragging`, `true`);
    }
  }
}

function divVisuClickEventHandler(ev) {
  const msSinceLastBlurEvent = ev.timeStamp - window.lastBlurEventTimeStamp;
  let actionExecuted = (msSinceLastBlurEvent < 700) ? true : false; //block clickEvent for 700ms after blurEvent
    
  const selectionArea = document.querySelector(`.selectionArea`);
  if (!selectionArea) {
    actionExecuted |= removeDivIconSignal(ev);
    
    if (!actionExecuted) {
      actionExecuted |= cancelCurrentDrawing();
    }
  }
  
  if (!actionExecuted) {
    const visuItem = ev.target.closest(`.visuItem`);
    if (selectionArea || !visuItem) {
      selectModeClickEventHandler(ev);  //selection only starts when no other action was executed
    }  
  }  
}

function linkBtnBlurHandler(ev) {
  window.lastBlurEventTimeStamp = ev.timeStamp; //save timeStamp to avoid click- contextmenuEvent (selection/drawing) afterwards
  ev.target.type = `button`;
  ev.target.removeEventListener(`blur`, linkBtnBlurHandler);
  
  if (ev.type === `keydown`) {
    if(ev.key === `Escape`) {
      ev.target.value = ev.target.fallbackVal; //cancelAction => fallbackVal
    }
    document.activeElement.blur();
  }
}

function txtElBlurHandler(ev) {
  ev.target.removeEventListener(`blur`, txtElBlurHandler);
  
  if (ev.type === `keydown`) {
    if(ev.key === `Escape`) {
      ev.target.value = ev.target.fallbackVal; //cancelAction => fallbackVal
    }
    document.activeElement.blur();
  }
}

function cancelCurrentDrawing() {
  removeExistingNode(document.querySelector(`.hoverMarker`));
  return removeExistingNode(hoverLine = document.querySelector(`.hoverLine`)); //feedback whether drawing was active or not
}

function cancelCurrentSelection() {
  document.querySelectorAll(`[selected]`).forEach(el => el.removeAttribute(`selected`));
  document.querySelectorAll(`[highlighted]`).forEach(el => el.removeAttribute(`highlighted`));
  return removeExistingNode(selectionArea = document.querySelector(`.selectionArea`)); //feedback whether selection was active or not
}

function cancelCurrentAttributeEdit() {
  return removeExistingNode(document.querySelector(`.divEditSignal`));
}

function removeDivIconSignal(ev) {
  if (ev.target.matches(`.divIconSignal[signal-id]`)) {
    ev.target.removeAttribute(`signal-id`);
    ev.target.removeAttribute(`title`);
    ev.target.setAttribute(`na`, true);
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
  //const target = (ev.target.matches(`[draggable]`)) ? ev.target : ev.target.closest(`.visuItem[draggable]`);
  const {target} = ev;
  if (target) {
    if (target.matches(`.divVisu *`)) {
      target.setAttribute(`selected`, `true`);
    }
  }

  const selectedElements = document.querySelectorAll(`[dragging], [selected][draggable]`);
  //console.log(selectedElements);
  const offsets = [];
  selectedElements.forEach(selectedEl => {
    const targetBox = selectedEl.getBoundingClientRect();
    const offset = {};
    offset.x = ev.x - targetBox.x;
    offset.y = ev.y - targetBox.y;
    offsets.push(offset);    
    selectedEl.setAttribute(`dragging`, `true`);
  });
  ev.dataTransfer.clearData();
  ev.dataTransfer.setData(`offsets`, JSON.stringify(offsets));
}



function divVisuDragOverEventHandler(ev) {
  const draggingItems = document.querySelectorAll(`[dragging]`);
  draggingItems.forEach(draggingItem => {
    ev.preventDefault();
    ev.dataTransfer.dropEffect = (ev.ctrlKey || draggingItem.closest(`.signalTable`)) ? `copy` : `move`;
  });
}

function dragEndEventHandler(ev) {
  removeAllDraggingAttributes();
}

function createDropItem(draggingItem) {
  let dropItem = draggingItem;
  const icon = dropItem.getAttribute(`icon`);
  if (icon) {
    dropItem = document.createElement(`div`);
    getAttributesAsMap(draggingItem).forEach((value, key) => dropItem.setAttribute(key, value));
    dropItem.appendChild(createIcon(dropItem.getAttribute(`icon`)));

  }

  return dropItem;
}

function divVisuDropEventHandler(ev) {
  const draggingItems = document.querySelectorAll(`[dragging]`);
  const offsets = JSON.parse(ev.dataTransfer.getData(`offsets`));
  const target = document.querySelector(`.divVisu`);
  draggingItems.forEach((draggingItem, idx) => {
    const dropItem = createDropItem((ev.dataTransfer.dropEffect === `copy`) ? draggingItem.cloneNode(true) : draggingItem);
    draggingItem.toggleAttribute(`selected`, (ev.dataTransfer.dropEffect !== `copy`));
    
    const divVisuBox = target.getBoundingClientRect();
    
    dropItem.style.position = `absolute`;
    const xRel = (ev.x - divVisuBox.x - offsets[idx].x)/divVisuBox.width;
    const yRel = (ev.y - divVisuBox.y - offsets[idx].y)/divVisuBox.height;
    
    const gridSnapActive = document.querySelector(`#cbGridSnap`).checked;
    const left = (gridSnapActive) ? `${Math.round(GRIDSIZE_AS_PARTS_FROM_WIDTH * xRel) / GRIDSIZE_AS_PARTS_FROM_WIDTH * 100}%` : `${xRel*100}%`;
    const top = (gridSnapActive) ? `${Math.round((GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * yRel) / (GRIDSIZE_AS_PARTS_FROM_WIDTH/ASPECT_RATIO) * 100}%` : `${yRel*100}%`;
   
    dropItem.style.left = left;
    dropItem.style.top = top;
    
    target.appendChild(dropItem);

      
    updateUnDoReDoStack();
  });

  removeAllDraggingAttributes();
}

function dblClickEventHandler(ev) {
  if (ev.target.matches(`.divVisu [type = button], .visuTab[tab-idx], [readonly]`)) {
    inputEl = document.createElement(`input`);
    document.body.appendChild(inputEl);
    inputEl.id = `tmpInputEl`;
    inputEl.addEventListener(`blur`, (ev) => {
      inputEl.remove();
    });
    inputEl.value = (ev.target.value) ? ev.target.value : ev.target.innerText;
    inputEl.callerEl = ev.target;
    inputEl.focus();
    inputEl.style.left = `${ev.x}px`;
    inputEl.style.top = `${ev.y}px`;
    /*
    ev.target.type = `text`; //convert button to text element
    ev.target.fallbackVal = ev.target.value; //perceive current Text for cancelAction 
    ev.target.addEventListener(`blur`, linkBtnBlurHandler);
    */
  }
  else {
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
}

function rotateLinkBtn(ev) {
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
}

function keyDownEventHandler(ev) {
  //console.log(ev.key);
  const key = ev.key.toLowerCase();
  const {activeElement} = document;
  if (activeElement.matches(`#tmpInputEl`)) {
    if (key.match((/(escape)|(enter)/))) {
      if (key === `enter`) {
        if (activeElement.callerEl.type) {
          activeElement.callerEl.value = activeElement.value;
        }
        else {
          activeElement.callerEl.innerText = activeElement.value;
        }
      }
      activeElement.blur();
    }
  }
  else if (activeElement.matches(`.visuItem[icon=button] input`)) {
    if (key.match((/(escape)|(enter)/))) {
      linkBtnBlurHandler(ev);
    }
  }
  else if (activeElement.matches(`.visuItem[icon=text] input`)) {
    if (key.match((/(escape)|(enter)/))) {
      activeElement.blur();
    }
  }
  else if (!activeElement.matches(`[type=text]:not([readonly])`)) {
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
        cancelCurrentAttributeEdit();
      }
      if (key.match(/(delete)|(backspace)/)) {
        if (activeElement.matches(`.divVisu [readonly]`)) {
          activeElement.remove();
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
              const iconPosition = el.getAttribute(`iconPosition`);
              if (dxRel) {
                //console.log(`match`);
                if (iconPosition === `right`) {
                  el.style.right = `${parseFloat(el.style.right) - 100 * dxRel}%`;
                }
                else {
                  el.style.left = `${parseFloat(el.style.left) + 100 * dxRel}%`;
                }
              }
              if (dyRel) {
                if (iconPosition === `bottom`) {
                  el.style.bottom = `${parseFloat(el.style.bottom) - 100 * dyRel}%`;
                }
                else {
                  el.style.top = `${parseFloat(el.style.top) + 100 * dyRel}%`;
                }
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
    el.querySelectorAll(`[type=text]`).forEach(txtEl => txtEl.value = txtEl.getAttribute(`signal-id`));
  });
  cancelCurrentDrawing();
  updateUsedCount();
}

function openLocalFileEventHandler(ev) {
  const reader = new FileReader();
  const file = ev.target.files[0];
  if (file) {
    reader.readAsText(file);
    reader.addEventListener(`load`, () => {
      console.log(file.name);
      if (file.name.match(/(\.txt)/i)) {
        buildVisu(reader.result);
        buildSignalTable(reader.result, window.liveData);
      }
      else if (file.name.match(/(\.p)/i)) {
        parseVisuSkript(reader.result);
      }
      //console.log(reader.result);
    });
  }
}

function createSignalTableRowElements(attributesObject) {
  const lbl = document.createElement(`label`);
  lbl.innerText = `0`;
  
  const signalEl = document.createElement(`input`);
  Object.entries(attributesObject).forEach(([key, value]) => signalEl.setAttribute(key, value));
  signalEl.type = `text`;
  signalEl.value = signalEl.getAttribute(`signal-id`);
  signalEl.readOnly = true;
  signalEl.draggable = true;
  signalEl.classList.add(`signalEl`);
  signalEl.addEventListener(`contextmenu`, editSignalAttributesEventHandler);

  return [lbl, signalEl];
}

function buildSignalTable(visuDataJson, liveData) {
  removeExistingNode(document.querySelector(`.signalTable`));
  const signalTable = document.createElement(`div`);
  document.body.appendChild(signalTable);
  signalTable.classList.add(`signalTable`);
  
  if (visuDataJson) {
    const visuData = JSON.parse(visuDataJson);   
    visuData.signalTableData.forEach(entry => {
      //console.log(entry);
      createSignalTableRowElements(entry).forEach(el => signalTable.appendChild(el));
    });  
  }
  if (liveData) {
    Object.keys(reformatLiveData(liveData).liveData).forEach((signalId) => {
      if (!signalTable.querySelector(`[signal-id = ${signalId}]`)) {
        createSignalTableRowElements({"signal-id": signalId}).forEach(el => signalTable.appendChild(el));
      }
    });
  }
}

function buildVisu(visuDataJson) {
  if (visuDataJson) {
    const visuData = JSON.parse(visuDataJson);
    
    
    //divVisuData
    const divVisu = document.querySelector(`.divVisu`);
    divVisu.innerHTML = visuData.divVisuHTML;
    divVisu.querySelectorAll(`[type=text]`).forEach(visuSignal => {
      const signalId = visuSignal.getAttribute(`signal-id`);
      visuSignal.value = signalId;
      //add information from visu to signalTable
      /*
      const txtSignalId = signalTable.querySelector(`[signal-id = ${signalId}]`);
      if (txtSignalId) {
        getRelevantAttributesAsMap(visuSignal).forEach((val, key) => {
          txtSignalId.setAttribute(key, val);
        });
      }
      else {
        console.warn(`signal-id ${signalId} not in signalTable included needs to be added! todo...`);
      }
      */
    });
    
    if (isAdmin()) {
      updateUnDoReDoStack();
    }
  }
  else {
    document.querySelector(`.divVisu`).appendChild(createBackgroundSVG());
  }
}

function parseVisuSkript(txt) {
  //console.log(txt);
  const data = txt.match(/([A-Z]+\s*\d+),\d,\s*\d+',.+\*\//g);
  //console.log(data);
  
  data.forEach(dataset => {
    const result = dataset.match(/(?<name>[A-Z]+)\s*(?<idx>\d+),(?<nk>\d),\s*(?<unit>\d+)',(?<rtos>.+)(?:TO\s*TEMP\s*BY).*\/\*\s*(?<tooltip>.+)\*\//);
    //console.log(result);

    //update rtos term & tooltip/title
    const txtSignalIds = document.querySelectorAll(`[signal-id=${result.groups.name}${result.groups.idx}]`);
    txtSignalIds.forEach(txtSignalId => {
      txtSignalId.setAttribute(`rtos-id`, result.groups.rtos.trim());
      txtSignalId.setAttribute(`title`, result.groups.tooltip.replace(`<<<`, ``).trim());
      const tr = txtSignalId.closest(`tr`);
      if (tr) {
        const txtRtosTerm = tr.querySelector(`.txtRtosTerm`);
        //txtRtosTerm.setAttribute(`rtos-id`, result.groups.rtos.trim());
        txtRtosTerm.value = result.groups.rtos;
        const txtTooltip = tr.querySelector(`.txtTooltip`);
        //txtTooltip.setAttribute(`tooltip`, result.groups.tooltip.trim());
        txtTooltip.value = result.groups.tooltip.replace(`<<<`, ``).trim();
      }
    });
  });

  
}

function colorInputEventHandler(ev) {
  document.querySelector(`#selStrokeDasharray`).style.color = ev.target.value;
}

function saveBtnHandler() {
  cancelCurrentSelection();
  cancelCurrentDrawing();
  cancelCurrentAttributeEdit();
  saveVisu();
  //saveSvg(document.querySelector(`svg`), `test.svg`);
}

function saveVisu() {
  const signalTableSignalIds = document.querySelectorAll(`.signalTable .txtSignalId`);
  const data = {};
  data.signalTableData = [];
  signalTableSignalIds.forEach(signalId => {
    data.signalTableData.push(getRelevantAttributesAsObject(signalId));
  });

  data.divVisuHTML = document.querySelector(`.divVisu`).innerHTML;
  console.log(data);

  const jsonData = JSON.stringify(data);
  console.log(jsonData);
  
  const blob = new Blob([jsonData], {type:"text/html;charset=utf-8"});
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

function signalTableAddRow() {
  const signalGroup = `dummy`;
  const idx = 0;

  const signalTableBody = document.querySelector(`.signalPool tbody`);
  const tr = document.createElement(`tr`);
  signalTableBody.appendChild(tr);
  [`UsageCount`, `RtosTerm`, `SignalId`, `Tooltip`, `DecPlace`, `Unit`, `Style`, `TrueTxt`, `FalseTxt`].forEach(col => {
    const td = document.createElement(`td`);
    tr.appendChild(td);
    if (col === `UsageCount`) {
      td.innerText = 0;
      td.classList.add(`${signalGroup}${idx}count`);
    }
    else if (col.match(/(Rtos)|(SignalId)|(Tooltip)|(Txt)/)) {
      const input = document.createElement(`input`);
      td.appendChild(input);
      input.classList.add(`txt${col}`);
      input.type = `text`;
      if (col === `SignalId`) {
        input.value = `${signalGroup}${idx}`;
        input.setAttribute(`signal-id`, `${signalGroup}${idx}`);
        input.readOnly = true;
        input.draggable = true;
        if (!signalGroup.match(/(DI)|(DO)|(dummy)/)) {
          input.setAttribute(`dec-place`, 1);
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
          option.selected = (decPlace === 1 && !signalGroup.match(/(DI)|(DO)|(dummy)/));
        });
      }

      if (col === `Unit`) {
        [``, `°C`, `bar`, `V`, `kW`, `m³/h`, `mWS`, `%`, `kWh`, `Bh`, `m³`, `°Cø`, `mV`, `UPM`, `s`, `mbar`, `A`, `Hz`, `l/h`, `l`].forEach(unit => {
          const option = document.createElement(`option`);
          select.appendChild(option);
          option.innerText = unit;
          option.value = unit;
          option.selected = (unit === `°C` && !signalGroup.match(/(DI)|(DO)|(dummy)/));
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
}

function signalTableInputEventHandler(ev) {
  const {target} = ev;
  const tr = target.closest(`tr`);
  const txtSignalId = tr.querySelector(`.txtSignalId`);
  document.querySelectorAll(`[signal-id = ${txtSignalId.value}]`).forEach(el => {
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
          el.setAttribute(`dec-place`, target.value);
        }
        else {
          el.removeAttribute(`dec-place`);
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
        el.setAttribute(`true-txt`, target.value);
      }
      else {
        el.removeAttribute(`true-txt`);
      }
    }
    if (target.matches(`.txtFalseTxt`)) {
      if (target.value.trim().length) {
        el.setAttribute(`false-txt`, target.value);
      }
      else {
        el.removeAttribute(`false-txt`);
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
  document.querySelectorAll(`[signal-id]`).forEach(signalEl => {
    //console.log(signalEl);
    const signalId = signalEl.getAttribute(`signal-id`);
    const signalCounter = document.querySelector(`.${signalId}count`)
    if (signalCounter) {
      signalCounter.innerText = divVisu.querySelectorAll(`[signal-id=${signalId}]`).length;
    }
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

function resizeSignalTableTxtInputs() {
  const signalTable = document.querySelector(`.signalTable`);
  [`txtRtosTerm`, `txtSignalId`, `txtTooltip`, `txtTrueTxt`, `txtFalseTxt`].forEach(col => {
    const colElements = signalTable.querySelectorAll(`.${col}`);
    const maxChar = Math.max(...Array.from(colElements, (el) => el.value.length));
    if (maxChar) {
      colElements.forEach(el => {
        el.style.width = `${maxChar+1}ch`;
      });
    }
  });
}

function highlightSignalsHandler(ev) {
  //console.log(document.querySelectorAll(`.txtSignalId[signal-id = ${ev.target.getAttribute(`signal-id`)}]`));
  document.querySelectorAll(`[highlighted]`).forEach(el => el.removeAttribute(`highlighted`));
  document.querySelectorAll(`[signal-id = ${ev.target.getAttribute(`signal-id`)}]`).forEach(el => el.setAttribute(`highlighted`, true));
}

/*********************ComFunctions*********************/
async function refreshLiveData() {
  const visuLiveData = reformatLiveData(await fetchLiveData(getProjectNoFromLocation()));
  //console.log(visuLiveData);
  if (visuLiveData) {
    //console.log(visuLiveData);
    const divVisu = document.querySelector(`.divVisu`);
    Object.entries(visuLiveData.liveData).forEach(([key, value]) => {
      const txtSignalIds = divVisu.querySelectorAll(`.txtSignalId[signal-id = ${key}]`);
      if (txtSignalIds) {
        txtSignalIds.forEach(el => {
          const decPlace = el.getAttribute(`dec-place`);
          const unit = el.getAttribute(`unit`);
          el.value = `${value.toFixed(decPlace)} ${unit}`;
        });
      }

      const divIconSignals = divVisu.querySelectorAll(`.divIconSignal[signal-id = ${key}]`);
      if (divIconSignals) {
        divIconSignals.forEach(el => {
          el.toggleAttribute(`cloaked`, !value);
        });
      }
    });

    if (visuLiveData.header.date) {
      document.querySelector(`.liveDataTimeStamp`).innerText = `Letzte Daten: ${visuLiveData.header.date} ${visuLiveData.header.time}`;
    }
  }
  else {
    console.log(`stopped reloadLiveDataInterval!`);
    clearInterval(window.reloadLiveDataIntervalId);
  }
}

function reformatLiveData(fetchedData) {
  const liveData = JSON.parse(fetchedData.replaceAll(` `,``));
  if (liveData.header) {
    return liveData;
  }
  else {
    const reformattedLiveData = {};
    reformattedLiveData.header = {};
    reformattedLiveData.liveData = {};

    liveData.Items.filter(signal => signal.Bezeichnung.trim() !== `HK` && signal.Bezeichnung.trim() !== `BHK` && signal.Bezeichnung.trim() !== `KES` && signal.Bezeichnung.trim() !== `WWL`).forEach(signal => {
      const {Bezeichnung, Kanal, Wert, sWert} = signal;
      reformattedLiveData.liveData[`${Bezeichnung}${Kanal}`] = (sWert) ? sWert.trim() : Wert;
    });
    
    return reformattedLiveData;
  }
}

/*********************AuxFunctions*********************/
function removeExistingNode(el) {
  if (el) {
    el.remove();
    return true;
  }
  return false;
}

function getProjectNoFromLocation() {
  return window.location.search.replace(`?Id=`,``);
}

function getUniqueAttributeNames(el) {
  //using MapConstructor to ensure that no duplicates included!
  return [...new Set(el.getAttributeNames())];
}

function getRelevantAttributesAsMap(el, relevantAttributeNames = [`signal-id`, `rtos-id`, `title`, `tooltip`, `dec-place`, `unit`, `stil`, `true-txt`, `false-txt`]) {
  const map = new Map();
  getUniqueAttributeNames(el).forEach(name => {
    if (relevantAttributeNames.includes(name)) {
      map.set(name, el.getAttribute(name));
    }
  });
  return map;
}

function getRelevantAttributesAsObject(el, relevantAttributeNames = [`signal-id`, `rtos-id`, `title`, `tooltip`, `dec-place`, `unit`, `stil`, `true-txt`, `false-txt`]) {
  const obj = {};
  getUniqueAttributeNames(el).forEach(name => {
    if (relevantAttributeNames.includes(name)) {
      obj[`${name}`] = el.getAttribute(name);
    }
  });
  return obj;
}

function getAttributesAsMap(el, exclusiveAttributeNames = []) { //[`class`, `rtos-id`, `title`, `tooltip`, `dec-place`, `unit`, `stil`, `true-txt`, `false-txt`]) {
  const map = new Map();
  getUniqueAttributeNames(el).forEach(name => {
    if (!exclusiveAttributeNames.includes(name)) {
      map.set(name, el.getAttribute(name));
    }
  });
  return map;
}

function getAttributesAsObject(el, exclusiveAttributeNames = []) { //[`class`, `rtos-id`, `title`, `tooltip`, `dec-place`, `unit`, `stil`, `true-txt`, `false-txt`]) {
  const obj = {};
  getUniqueAttributeNames(el).forEach(name => {
    if (!exclusiveAttributeNames.includes(name)) {
      obj[`${name}`] = el.getAttribute(name);
    }
  });
  return obj;
}

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


function l(...data) {
  console.log(data);
}