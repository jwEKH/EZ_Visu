//Parameter
const SYMBOL_DEFAULT_LINE_WIDTH = 3;

/*drawIcons*/
function createCanvasIcon(vti, color = 'black', bgColor = EKHdarkgrey) {
    const {MSR, idx, icon, signals} = vti;
    const {orientation} = icon;
    const canvas = document.createElement('canvas');
    canvas.classList.add('canvasIcon', MSR);
    //if (orientation) canvas.classList.add(orientation);   //moved 2 visuItem!
    
    canvas.width = 100;
    canvas.height = canvas.width;
    
    const ctx = canvas.getContext('2d');
    ctx.strokeStyle = color;
    ctx.lineWidth = SYMBOL_DEFAULT_LINE_WIDTH;
    ctx.fillStyle = bgColor;
    let radius;
    
    switch (MSR) {
        case 'YR': //Rückschlagklappe/-ventil (Passivbauteil)
            ctx.moveTo(1.4 * canvas.width/2, canvas.height/2);
            ctx.lineTo(.6 * canvas.width/2, canvas.height/2);
            ctx.moveTo(canvas.width/2, canvas.height/2);
            ctx.lineTo(1.4 * canvas.width/2, 1.8 * canvas.height/2);
            ctx.lineTo(.6 * canvas.width/2, 1.8 * canvas.height/2);
            ctx.lineTo(canvas.width/2, canvas.height/2);
            ctx.fill();
            ctx.stroke();
            break;
        case 'WW': //WW-Austritt (Duschkopf; Passivbauteil)
            radius = .4 * canvas.width/2;
            ctx.beginPath();
            ctx.strokeStyle = EKHmagenta;
            ctx.setLineDash([8, 8]);
            ctx.moveTo(canvas.width/2, canvas.height/2);
            ctx.lineTo(canvas.width/2, canvas.height/2 + radius);
            ctx.moveTo(canvas.width/2 - radius/2, canvas.height/2);
            ctx.lineTo(canvas.width/2 - radius, canvas.height/2 + radius);
            ctx.moveTo(canvas.width/2 + radius/2, canvas.height/2);
            ctx.lineTo(canvas.width/2 + radius, canvas.height/2 + radius);
            ctx.stroke();
            ctx.beginPath();
            ctx.strokeStyle = 'black';
            ctx.setLineDash([]);
            ctx.arc(canvas.width/2, canvas.height/2, radius, Math.PI, 2 * Math.PI);
            ctx.lineTo(canvas.width/2 - radius, canvas.height/2);
            ctx.fill();
            ctx.stroke();
            break;
        case 'KES': // Kessel
        case 'BHK': // BHKW
            //console.log(`noIcon for: >${MSR}<`);
            break;
        case 'HK': // Heizkreis
            radius = .9 * canvas.width/2;
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 0, 2 * Math.PI);
            ctx.fill();
            ctx.stroke();
            radius = .75 * canvas.width/2;
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 0, 2 * Math.PI);
            ctx.fillStyle = color;
            const hkNo = (idx > 99) ? parseInt(idx.toString().slice(-2)) : idx;
            ctx.font = (hkNo > 9) ? `${canvas.width/3.5}px Arial` : `${canvas.width/3}px Arial`;
            ctx.fillText(`HK${hkNo}`, (hkNo > 9) ? .15 * canvas.width : .2 * canvas.width, .6 * canvas.height);
            ctx.stroke();
            break;
        case 'NP': // Pumpe
            radius = .7 * canvas.width/2;
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 0, 2 * Math.PI); 
            ctx.moveTo(canvas.width/2 - radius, canvas.height/2);
            ctx.lineTo(canvas.width/2, canvas.height/2 - radius);
            ctx.lineTo(canvas.width/2 + radius, canvas.height/2);
            ctx.fill();
            ctx.stroke();
            break;
        case 'NL': // Lüfter
            radius = .9 * canvas.width/2;
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 0, 2 * Math.PI);
            ctx.moveTo(canvas.width/2 - Math.sin(Math.PI/3) * radius, canvas.height/2 + Math.cos(Math.PI/3) * radius);
            ctx.lineTo(canvas.width/2 - Math.sin(Math.PI/6) * radius, canvas.height/2 - Math.cos(Math.PI/6) * radius);
            ctx.moveTo(canvas.width/2 + Math.sin(Math.PI/6) * radius, canvas.height/2 - Math.cos(Math.PI/6) * radius);
            ctx.lineTo(canvas.width/2 + Math.sin(Math.PI/3) * radius, canvas.height/2 + Math.cos(Math.PI/3) * radius);
            ctx.fill();
            ctx.stroke();
            break;
        case 'YM': // Mischer
            ctx.moveTo(canvas.width/2, canvas.height/2);
            ctx.lineTo(.2 * canvas.width/2, 1.4 * canvas.height/2);
            ctx.lineTo(.2 * canvas.width/2, 0.6 * canvas.height/2);
            ctx.lineTo(canvas.width/2, canvas.height/2);
            ctx.fill();
            ctx.stroke();
            // HIER KEIN BREAK, DA FÜR MISCHER ZUNÄCHST "NUR" DER 3.ANSCHLUSSPUNKT GEZEICHNET WIRD!
        case 'YV': // Ventil
            ctx.moveTo(0.6 * canvas.width/2, 0.2 * canvas.height/2);
            ctx.lineTo(1.4 * canvas.width/2, 1.8 * canvas.height/2);
            ctx.lineTo(0.6 * canvas.width/2, 1.8 * canvas.height/2);
            ctx.lineTo(1.4 * canvas.width/2, 0.2 * canvas.height/2);
            ctx.lineTo(0.6 * canvas.width/2, 0.2 * canvas.height/2);
            ctx.fill();
            ctx.moveTo(canvas.width/2, canvas.height/2);
            ctx.lineTo(1.35 * canvas.width/2, canvas.height/2);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(1.65 * canvas.width/2, canvas.height/2, 0.3 * canvas.width/2, 0, 2 * Math.PI);
            ctx.fill();
            ctx.stroke();
            break;
        case 'YK': // Lüftungsklappe
            break;
        case 'HP': // Heizpatrone
            radius = 0.05 * canvas.width;
            ctx.rect(ctx.lineWidth, 0.3 * canvas.height, 0.4 * canvas.width, 0.4 * canvas.height);
            ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(ctx.lineWidth + 0.4 * canvas.width, 0.4 * canvas.height);
            ctx.lineTo(canvas.width - ctx.lineWidth, 0.4 * canvas.height);
            ctx.arc(canvas.width - ctx.lineWidth - radius, 0.4 * canvas.height + radius, radius, -Math.PI/2, Math.PI/2);
            ctx.moveTo(ctx.lineWidth + 0.4 * canvas.width, 0.5 * canvas.height);
            ctx.lineTo(canvas.width - ctx.lineWidth, 0.5 * canvas.height);
            ctx.arc(canvas.width - ctx.lineWidth - radius, 0.5 * canvas.height + radius, radius, -Math.PI/2, Math.PI/2);
            ctx.moveTo(ctx.lineWidth + 0.4 * canvas.width, 0.6 * canvas.height);
            ctx.lineTo(canvas.width - ctx.lineWidth, 0.6 * canvas.height);
            ctx.stroke();
            break;
        case 'TI': // Temperaturfühler
            ctx.fillStyle = color;
            ctx.font = `lighter ${canvas.height * .8}px Arial`;
            ctx.translate(canvas.width/2, canvas.height/2);
            ctx.rotate(45 * Math.PI / 180);
            ctx.fillText('T', -.25 * canvas.width, .7 * canvas.height);
            ctx.stroke();
            break;
        case 'PI': // Druckmessung
        case 'PD': // Diff.Druckmessung
            radius = .45 * canvas.width/2;
            if (MSR == 'PI') {
                ctx.moveTo(canvas.width/2, canvas.height);
                ctx.lineTo(canvas.width/2, canvas.height/2.5 + radius);
                ctx.stroke();
            }
            if (MSR == 'PD') {
                ctx.moveTo(.1 *canvas.width, canvas.height);
                ctx.lineTo(.1 * canvas.width, canvas.height/2.5);
                ctx.lineTo(.9 * canvas.width, canvas.height/2.5);
                ctx.lineTo(.9 * canvas.width, canvas.height);
                ctx.stroke();
            }
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2.5, radius, 0, 2 * Math.PI);
            ctx.fill();
            ctx.fillStyle = color;
            ctx.font = `${canvas.height * .4}px Arial`;
            const txt = (orientation === `orientationBottom`) ? `d` : `p` ;// quikk'n' dirty: if icon is upsideDown -> write 'd' cuz upsideDown its 'p'
            ctx.fillText(txt, canvas.width/2.5, canvas.height/2);
            ctx.stroke();
            break;
        case 'VZ': // Volumenstromzähler
        case 'QZ': // Wärmemengenzähler
        case 'JZ': // Stromzähler
            ctx.beginPath();
            ctx.rect(.1 *canvas.width, .1 *canvas.height, .8 *canvas.width, .6 *canvas.height);
            ctx.fill();
            ctx.rect(.2 *canvas.width, .2 *canvas.height, .6 *canvas.width, .3 *canvas.height);
            //ctx.stroke();
            ctx.fillStyle = color;
            ctx.font = `${canvas.height * .25}px Arial`;
            ctx.fillText(`${MSR}`, .35 *canvas.width, .45 *canvas.height);
            ctx.stroke();
            break;
        case 'QA': // Gassensor
            ctx.beginPath();
            ctx.moveTo(.1 *canvas.width, .1 *canvas.height);
            ctx.lineTo(.1 *canvas.width, .3 *canvas.height);
            ctx.lineTo(.2 *canvas.width, .3 *canvas.height);
            //ctx.moveTo(.2 *canvas.width, .3 *canvas.height);
            ctx.lineTo(.3 *canvas.width, .5 *canvas.height);
            ctx.lineTo(.7 *canvas.width, .5 *canvas.height);
            ctx.lineTo(.8 *canvas.width, .3 *canvas.height);
            ctx.lineTo(.9 *canvas.width, .3 *canvas.height);
            ctx.lineTo(.9 *canvas.width, .1 *canvas.height);
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
            ctx.lineWidth = SYMBOL_DEFAULT_LINE_WIDTH / 3; //1;
            ctx.moveTo(.2 *canvas.width, .3 *canvas.height);
            ctx.lineTo(.8 *canvas.width, .3 *canvas.height);
            for(let i=.3; i<.45; i+=.05) {
                ctx.moveTo(i *canvas.width, .35 *canvas.height);
                ctx.lineTo((i+.05) *canvas.width, .45 *canvas.height);
            }
            for(let i=.7; i>.5; i-=.05) {
                ctx.moveTo(i *canvas.width, .35 *canvas.height);
                ctx.lineTo((i-.05) *canvas.width, .45 *canvas.height);
            }
            ctx.stroke();
            break;
        case `BTN`:
            const btn = document.createElement('button');
            btn.innerHTML = signals.VAL1.inactiveValue;
            btn.classList.add('btnIcon', MSR);
            return btn;
        case `TXT`: //TextItems
        case `UKN`: //unresolved Items during update
            //console.log(`noIcon for: >${MSR}<`);
            break;
        default:
            console.log(`unknown Icon: >${MSR}<`);
            return null;
    }
    
    return canvas;
}

/*drawAnimations*/
function createDivRM(vti, color = 'black', bgColor = EKHlightgrey) {
    const {MSR, signals, icon} = vti;
    const {RM} = signals;
    const {orientation} = icon;
    const divRM = document.createElement('div');
    divRM.classList.add('divRM', MSR);
    (RM.pearlVar.name) ? divRM.classList.add(translatePearlVarName2cssCompatibleClassName(RM.pearlVar.name)) : divRM.classList.add('NA', 'hidden');
    //if (orientation) divRM.classList.add(orientation);   //moved 2 visuItem!
    const canvas =  document.createElement('canvas');
    canvas.classList.add('canvasRM', MSR);
    
    canvas.width = 100;
    canvas.height = canvas.width;
    if (MSR != 'KES') divRM.appendChild(canvas);    //RM Kessel ist kein Canvas (vanillaCSS with divs)
    
    const ctx = canvas.getContext('2d');
    ctx.strokeStyle = color;
    ctx.lineWidth = SYMBOL_DEFAULT_LINE_WIDTH;
    ctx.fillStyle = bgColor;
    let radius;
    
    switch (MSR) {
        case 'YR': //Rückschlagklappe/-ventil (Passivbauteil)
        case 'WW': //WW-Austritt (Duschkopf; Passivbauteil)
            break;
        case 'KES': //Kessel
            divRM.classList.add('flameContainer');
            var flameColors = ['red', 'orange', 'yellow', 'white', 'blue'];
            for (var i=0; i<5; i++) {
                var div = document.createElement('div');
                div.classList.add('flame', flameColors[i]);
                divRM.appendChild(div);
            }
            break;
        case 'BHK': //BHKW
            radius = .75 * canvas.width/2;
            ctx.strokeStyle = EKHcyan;
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 0, 2 * Math.PI);
            ctx.stroke();
            radius = .6 * canvas.width/2;
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, -Math.PI/4, Math.PI/4);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 3*Math.PI/4, -3*Math.PI/4);
            ctx.stroke();
            ctx.lineWidth *= 1.5;
            ctx.beginPath();
            ctx.moveTo(canvas.width/2 - radius, canvas.height/2);
            ctx.lineTo(canvas.width/2 + radius, canvas.height/2);
            ctx.stroke();
            break;
        case 'HK': //Heizkreis
            break;
        case 'NP': //Pumpe
            radius = .4 * canvas.width/2;
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 0, 2 * Math.PI);		
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = 'black';
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 1.1*Math.PI, 1.9*Math.PI);
            ctx.lineTo(canvas.width/2, canvas.height/2);
            ctx.closePath();
            ctx.fill();
            //ctx.stroke();
            break;
        case 'NL': //Lüfter
            radius = .9 * canvas.width/2;
            ctx.beginPath();
            ctx.arc(canvas.width/2, canvas.height/2, radius, 0, 2 * Math.PI);			
            
            ctx.moveTo(canvas.width/2 - Math.sin(Math.PI/3) * radius, canvas.height/2 + Math.cos(Math.PI/3) * radius);
            ctx.lineTo(canvas.width/2 - Math.sin(Math.PI/6) * radius, canvas.height/2 - Math.cos(Math.PI/6) * radius);
            ctx.moveTo(canvas.width/2 + Math.sin(Math.PI/6) * radius, canvas.height/2 - Math.cos(Math.PI/6) * radius);
            ctx.lineTo(canvas.width/2 + Math.sin(Math.PI/3) * radius, canvas.height/2 + Math.cos(Math.PI/3) * radius);
            ctx.fill();
            ctx.stroke();
            break;
        case 'YM': //Mischer
            break; //Animation zunächst nicht für Mischer, da In-& Outlet Handling kompliziert!
        case 'YV': //Ventil
            ctx.fillStyle = 'black';
            ctx.moveTo(0.6 * canvas.width/2, 0.2 * canvas.height/2);
            ctx.lineTo(1.4 * canvas.width/2, 1.8 * canvas.height/2);
            ctx.lineTo(0.6 * canvas.width/2, 1.8 * canvas.height/2);
            ctx.lineTo(1.4 * canvas.width/2, 0.2 * canvas.height/2);
            ctx.lineTo(0.6 * canvas.width/2, 0.2 * canvas.height/2);
            ctx.fill();
            break;
        case 'YK': //Lüftungsklappe
            break;
        case 'HP': //Heizpatrone
            radius = 0.05 * canvas.width;
            ctx.rect(ctx.lineWidth, 0.3 * canvas.height, 0.4 * canvas.width, 0.4 * canvas.height);
            ctx.fill();
            ctx.stroke();

            ctx.font = `bolder ${0.2 * canvas.height}px Arial`;
            ctx.fillStyle = EKHmagenta;
            ctx.fillText('ON', 2 * ctx.lineWidth, 0.58 * canvas.height);
            ctx.stroke();
            
            ctx.strokeStyle = EKHmagenta;
            ctx.beginPath();
            ctx.moveTo(ctx.lineWidth + 0.4 * canvas.width, 0.4 * canvas.height);
            ctx.lineTo(canvas.width - ctx.lineWidth, 0.4 * canvas.height);
            ctx.arc(canvas.width - ctx.lineWidth - radius, 0.4 * canvas.height + radius, radius, -Math.PI/2, Math.PI/2);
            ctx.moveTo(ctx.lineWidth + 0.4 * canvas.width, 0.5 * canvas.height);
            ctx.lineTo(canvas.width - ctx.lineWidth, 0.5 * canvas.height);
            ctx.arc(canvas.width - ctx.lineWidth - radius, 0.5 * canvas.height + radius, radius, -Math.PI/2, Math.PI/2);
            ctx.moveTo(ctx.lineWidth + 0.4 * canvas.width, 0.6 * canvas.height);
            ctx.lineTo(canvas.width - ctx.lineWidth, 0.6 * canvas.height);
            ctx.stroke();
            break;
        case 'TI':
            break;
        case 'PI':
            break;
        case 'PD':
            break;
        case 'VZ':
            break;
        case 'QZ':
            break;
        case 'JZ':
            break;
        case 'QA':
            break;
        case `BTN`: //visuBtns
            divRM.classList.add('cloaked');
            break;
        case `TXT`: //TextItems
            break;
        case `UKN`: //unresolved Items during update
            break;
        default:
            console.log(`unknown Icon(RM): >${MSR}<`);
            return null;
    }
    return divRM;
}

/*handleAnimation*/
function handleAnimation(value, target) {
    //console.log(target);
    const visuItem = getAncestorByClassNames(target, 'visuItem');
    const {classList} = target;
    const {vti} = visuItem;
    const {signals} = vti;
    const {FG, RM, A, BA, ABS} = signals;
    //console.log(className, value);
    //console.log(visuItem);

    if (classList.contains('divFG')) {
        target.classList.toggle('hidden', !!value ^ FG.isLowActive);
    }
    else if (classList.contains('divRM')) {
        if (visuItem.classList.contains('BHK') || visuItem.classList.contains('NP') || visuItem.classList.contains('NL')) {
            target.classList.toggle('spin', !!value ^ RM.isLowActive);
        }
        if (visuItem.classList.contains('YV') || visuItem.classList.contains('YM')) {
            target.classList.toggle('hidden', !!value ^ RM.isLowActive);
        }
        if (visuItem.classList.contains('HP')) {
            target.classList.toggle('hidden', !(!!value ^ RM.isLowActive));
        }
        if (visuItem.classList.contains('KES')) {
            target.classList.toggle('hidden', !classList.toggle('flicker', !!value ^ RM.isLowActive));
        }
    }
    else if (classList.contains('pStoerung')) {
        //target.innerHTML = '&#x26A0';
        target.classList.toggle('hidden', !classList.toggle('blink', !!value ^ A.isLowActive));
    }
    else if (classList.contains('pBA')) {
        //target.innerHTML = '&#x270B';
        target.classList.toggle('hidden', !(!!value ^ BA.isLowActive));
    }
    else if (classList.contains('pABS')) {
        //target.innerHTML = '&#x1F31C';
        //target.innerHTML = (!!value ^ ABS.isLowActive) ? '&#x1F31C': '&#x1F31E'; //Absenkung: Sonne:	1F31E, 1F505, 1F506, 2600; Mond: 1F31C, 1F31B, 1F319, 263E
        target.classList.toggle('hidden', !(!!value ^ ABS.isLowActive));
    }
    else {
        target.classList.toggle('hidden', !value);
    }
}

/********************************OLD STUFF*********************************
// Diverse Zeichenfunktionen wie im Editor
//function Heizkreis(ctx, x, y, scale) {
//    ctx.save();
//    ctx.lineWidth = 1;
//    ctx.translate(x, y);
//    ctx.beginPath();
//    ctx.arc(0, 0, 18, 0, 2 * Math.PI);
//    ctx.stroke();
//    ctx.restore();
//}

function Heizkreis(vDynCtx, x, y, betrieb) {
    var notches = 7,                      // num. of notches
        radiusO = 12,                    // outer radius
        radiusI = 9,                    // inner radius
        radiusH = 5,                    // hole radius
        taperO = 30,                     // outer taper %
        taperI = 40,                     // inner taper %

        // pre-calculate values for loop
        pi2 = 2 * Math.PI,            // cache 2xPI (360deg)
        angle = pi2 / (notches * 2),    // angle between notches
        taperAI = angle * taperI * 0.005, // inner taper offset (100% = half notch)
        taperAO = angle * taperO * 0.005, // outer taper offset
        a = angle,                  // iterator (angle)
        toggle = false;                  // notch radius level (i/o)

    vDynCtx.save();
    vDynCtx.fillStyle = '#000';
    vDynCtx.lineWidth = 2.5;
    vDynCtx.strokeStyle = '#000';
    vDynCtx.beginPath()
    vDynCtx.moveTo(x + radiusO * Math.cos(taperAO), y + radiusO * Math.sin(taperAO));

    for (; a <= pi2; a += angle) {

        // draw inner to outer line
        if (toggle) {
            vDynCtx.lineTo(x + radiusI * Math.cos(a - taperAI),
                y + radiusI * Math.sin(a - taperAI));
            vDynCtx.lineTo(x + radiusO * Math.cos(a + taperAO),
                y + radiusO * Math.sin(a + taperAO));
        }

        // draw outer to inner line
        else {
            vDynCtx.lineTo(x + radiusO * Math.cos(a - taperAO),  // outer line
                y + radiusO * Math.sin(a - taperAO));
            vDynCtx.lineTo(x + radiusI * Math.cos(a + taperAI),  // inner line
                y + radiusI * Math.sin(a + taperAI));
        }

        // switch level
        toggle = !toggle;
    }
    // close the final line
    vDynCtx.closePath();
    vDynCtx.moveTo(x + radiusH, y);
    vDynCtx.arc(x, y, radiusH, 0, pi2);

    if (betrieb == '0') {

    }
    else {
        //vDynCtx.font = "12px Arial";
        //vDynCtx.fillText("Handbetrieb", x - 20, y + 24);
        vDynCtx.translate(x,y)
        vDynCtx.moveTo(40, 27);
        vDynCtx.lineTo(40, 10);
        vDynCtx.arc(38, 8, 2, 2 * Math.PI, 1 * Math.PI, true);
        vDynCtx.lineTo(36, 16);
        vDynCtx.arc(34, 6.5, 2, 2 * Math.PI, 1 * Math.PI, true);
        vDynCtx.lineTo(32, 15);
        vDynCtx.arc(30, 5.5, 2, 2 * Math.PI, 1 * Math.PI, true);
        vDynCtx.lineTo(28, 15);
        vDynCtx.arc(26, 6.5, 2, 2 * Math.PI, 1 * Math.PI, true);
        vDynCtx.lineTo(24, 20);
        vDynCtx.lineTo(20, 16);
        vDynCtx.arc(19, 17.8, 2, 1.8 * Math.PI, 0.8 * Math.PI, true);
        vDynCtx.lineTo(26, 27);
        vDynCtx.lineTo(40, 27);
        vDynCtx.fillStyle = 'yellow';
        vDynCtx.scale(1, 1)
        vDynCtx.fill();
        //vDynCtx.stroke();
    }
    vDynCtx.stroke();
    vDynCtx.restore();
}


function Absenkung(ctx, x, y, scale, active) {
    ctx.save();
    ctx.moveTo(0 - 10 * scale, 0);
    ctx.font = '10pt Arial';
    ctx.fillStyle = 'blue';

    ctx.translate(x, y);

    if (active == 1)
        ctx.fillText('Nacht', 0, 0);
    else
        ctx.fillText('Tag', 1, 0);

    ctx.restore();
}


function BHDreh(ctx, x, y, scale, rotation) {
    ctx.save();
    ctx.lineWidth = 1 * scale;
    ctx.translate(x, y);
    ctx.rotate(Math.PI / 180 * rotation);
    ctx.strokeStyle = "steelblue";
    ctx.beginPath();
    ctx.arc(0, 0, 13 * scale, 0, Math.PI * 2, true);

    ctx.moveTo(0 + 10 * scale, 0);
    ctx.arc(0, 0, 10 * scale, 0, -Math.PI / 4, true);
    ctx.moveTo(0 + 10 * scale, 0);
    ctx.arc(0, 0, 10 * scale, 0, Math.PI / 4, false);

    ctx.moveTo(0 - 10 * scale, 0);
    ctx.arc(0, 0, 10 * scale, Math.PI, -3 * Math.PI / 4, false);
    ctx.moveTo(0 - 10 * scale, 0);
    ctx.arc(0, 0, 10 * scale, Math.PI, 3 * Math.PI / 4, true);
    ctx.stroke();

    ctx.lineWidth = 3 * scale;

    ctx.beginPath();
    ctx.moveTo(0 - 10 * scale, 0);
    ctx.lineTo(0 + 10 * scale, 0);

    ctx.stroke();
    ctx.restore();
}


function feuer(ctx, x, y, scale) {
    // 30x48
    var rd1 = (Math.random() - 0.5) * 3;
    var rd2 = (Math.random() - 0.5) * 3;
    var rd3 = (Math.random() - 0.5) * 3;
    var rd4 = (Math.random() - 0.5) * 3;
    var rd5 = (Math.random() - 0.5) * 3;
    var rd6 = (Math.random() - 0.5) * 3;
    ctx.save();

    ctx.lineWidth = 1;
    ctx.translate(x, y);
    ctx.scale(scale, scale);
    ctx.strokeStyle = "red";
    ctx.fillStyle = "yellow";
    ctx.beginPath();
    ctx.moveTo(0 + rd1, -20);
    ctx.lineTo(-5 + rd2, -10);
    ctx.lineTo(-8 + rd3, -5);
    ctx.lineTo(-7 + rd4, 5);
    ctx.lineTo(-2 + rd5, 10);

    ctx.lineTo(2 + rd5, 10);
    ctx.lineTo(4 + rd4, 5);
    ctx.lineTo(6 + rd6, -5);
    ctx.lineTo(5 + rd2, -10);
    ctx.lineTo(0 + rd1, -20);
    ctx.fill();
    ctx.stroke();

    //ctx.closePath();
    ctx.restore();
}

function pmpDreh2(ctx, x, y, scale, rot) {
    // 12x12
    ctx.save();
    ctx.strokeStyle = "black";
    ctx.fillStyle = "black";
    ctx.lineWidth = 1;
    ctx.translate(x, y);
    ctx.rotate(Math.PI / 180 * rot);
    ctx.scale(scale, scale);
    ctx.beginPath();
    ctx.arc(0, 0, 11, 0, Math.PI * 2, true);
    ctx.stroke();
    ctx.closePath();
    ctx.beginPath();
    ctx.lineWidth = 1, 5;
    ctx.arc(0, 0, 6, 0, Math.PI * 2, true);
    ctx.fillStyle = 'black';
    ctx.fill();
    ctx.closePath();
    ctx.beginPath();
    ctx.arc(0, 0, 6, startAngle, endAngle, true);
    ctx.lineTo(0, 0);
    ctx.fillStyle = 'white';
    ctx.fill();
    ctx.closePath();

    ctx.stroke();
    ctx.restore();
}

function drawEllipse(ctx, x, y, w, h) {
    var kappa = .5522848,
        ox = (w / 2) * kappa, // control point offset horizontal
        oy = (h / 2) * kappa, // control point offset vertical
        xe = x + w,           // x-end
        ye = y + h,           // y-end
        xm = x + w / 2,       // x-middle
        ym = y + h / 2;       // y-middle


    ctx.moveTo(x, ym);
    ctx.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
    ctx.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
    ctx.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
    ctx.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
    //ctx.closePath(); // not used correctly, see comments (use to close off open path)
    ctx.stroke();
}

function luefter(ctx, x, y, scale, rotL, rotDir) {
    // 51x51
    ctx.save();
    ctx.strokeStyle = "black";
    ctx.fillStyle = "grey";
    ctx.lineWidth = 1;
    ctx.translate(x, y);
    ctx.rotate(Math.PI / 180 * rotDir);
    ctx.scale(scale, scale);
    ctx.beginPath();
    ctx.arc(0, 0, 24, 0, Math.PI * 2, true);
    ctx.moveTo(0, -24);
    ctx.lineTo(-23, -5);
    ctx.moveTo(0, 24);
    ctx.lineTo(-23, 5);
    ctx.stroke();
    ctx.closePath();
    ctx.beginPath();
    ctx.rotate(Math.PI / 180 * rotL);
    drawEllipse(ctx, 0, -5, 22, 10);
    drawEllipse(ctx, -22, -5, 22, 10);
    ctx.fill();

    ctx.restore();
}

//Zeichnen: Abluftklappe 
function ablufklappen(ctx, x, y, scale, rot) {
    ctx.save();
    ctx.strokeStyle = "black";
    ctx.lineWidth = 1;
    ctx.translate(x, y);
    ctx.scale(scale, scale);
    ctx.beginPath();
    //Kreis zeichnen
    ctx.arc(15, 0, 3, 0, 2 * Math.PI, false);
    ctx.fillStyle = 'black';
    ctx.fill();

    //Linine durch den Kreis zeichnen ggf. rotieren
    //rotation 0 = bool value = 1
    if (rot == 0) {
        ctx.moveTo(0, 0);
        ctx.lineTo(30, 0);
    }
    //rotation 0 = bool value = 0
    if (rot == 45) {
        ctx.rotate(45 * Math.PI / 180);
        ctx.moveTo(0, 0);
        ctx.lineTo(30, 0);

    }
    ctx.stroke();
    ctx.restore();
}

function ventil(ctx, x, y, scale, rot) {
    // 6x6
    ctx.save();
    ctx.strokeStyle = "black";
    ctx.fillStyle = "black";
    ctx.lineWidth = 1;
    ctx.translate(x, y);
    ctx.rotate(Math.PI / 180 * rot);
    ctx.scale(scale, scale);
    ctx.beginPath();
    ctx.fillRect(-3, -1, 3, 2);
    ctx.moveTo(0, 3);
    ctx.lineTo(3, 0);
    ctx.lineTo(0, -3);
    ctx.fill();

    ctx.restore();
}

function Led(ctx, x, y, scale, col) {


    ctx.save();
    ctx.strokeStyle = "black";
    ctx.fillStyle = "#aaa";
    ctx.lineWidth = 1;
    ctx.translate(x, y);
    ctx.scale(scale, scale);
    ctx.beginPath();

    ctx.arc(0, 0, 6, 0, Math.PI * 2, true);
    ctx.stroke();
    ctx.fill();
    ctx.closePath();
    ctx.beginPath();
    ctx.arc(0, 0, 4, 0, Math.PI * 2, true);
    ctx.fillStyle = col;
    ctx.fill();
    ctx.restore();
}*/