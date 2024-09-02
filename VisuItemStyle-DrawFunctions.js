//Colors here in rgb, because style.color will return rgb-format
const MAGENTA = 'rgb(195, 29, 101)'; //hsl(334, 74%, 44%)';
const CYAN = 'rgb(29, 156, 195)'; //'hsl(194, 74%, 44%)';
const PURPLE = `rgb(112, 92, 147)`; //hsl(262, 23%, 47%)
const YELLOW =  'rgb(195, 195, 29)'; //'hsl(60, 74%, 44%)';
//const BG_COLOR = 'rgb(192, 192, 192)'; //'hsl(0, 0%, 75%)';

function microGridClickHandler(event) {
    event.target.classList.toggle('pressed');
}

function dottedLineClickHandler(event) {
    event.target.classList.toggle('pressed');
}

function colorPickClickHandler(event) {
    colorPickTargetHandler(event.target);
}

function colorPickTargetHandler(target) {
    if (!target) return target;
    const {style, classList} = target;

    const colors = ['', MAGENTA, CYAN, PURPLE, 'yellow'];
    const currentColor = style.color;
    
    style.color = (currentColor == colors[colors.length-1]) ? colors[0] : colors[colors.indexOf(currentColor)+1];
    //console.log(target.style.color);
    const colorFadeActive = document.querySelector('.btnColorFade').classList.contains('pressed');  //wenn ColorFade disabled endColor entsprechend startColor ändern
    if (!colorFadeActive && classList.contains('btnStartColor')) document.querySelector('.btnEndColor').style.color = style.color;
}

function drawModeBtnClickHandler(event) {
    if (!event) return event;
    const {target} = event;
    drawModeBtnHandler(target);
}

function drawModeBtnHandler(target) {
    if (!target || target.className.includes(`pressed`)) return target;
    
    const btnGroupHandlerReturnTarget = btnGroupHandler(target);
    if (btnGroupHandlerReturnTarget) {
        const {classList} = btnGroupHandlerReturnTarget;
        const visuArea = document.querySelector(`.visuArea`);
        if (classList.contains(`btnDrawLine`)) visuArea.drawMode = `line`;
        if (classList.contains(`btnDrawArc`)) visuArea.drawMode = `arc`;
        if (classList.contains(`btnDrawRect`)) visuArea.drawMode = `rect`;
        if (classList.contains(`btnDrawRoundRect`)) visuArea.drawMode = `roundRect`;
        if (classList.contains(`btnErase`)) visuArea.drawMode = `erase`;

        const btnOrthoMode = document.querySelector(`.btnOrthoMode`);
        if (visuArea.drawMode === `line`) {
            btnOrthoMode.disabled = false;
            editModeBtnHandler(btnOrthoMode, true);
        }
        else {
            editModeBtnHandler(btnOrthoMode, false);
            btnOrthoMode.disabled = true;
        }
        const noLineWidth = document.querySelector(`.noLineWidth`);
        noLineWidth.value = (visuArea.drawMode.toUpperCase().includes(`RECT`)) ? 1 : 2;
        const btnDottedLine = document.querySelector(`.btnDottedLine`);
        (visuArea.drawMode === `rect`) ? editModeBtnHandler(btnDottedLine, true) : editModeBtnHandler(btnDottedLine, false);
    }    
}

//Draw & Erase Functions
function drawModeFunctionHandler(event) {
    const visuArea = document.querySelector('.visuArea');
    const {drawMode} = visuArea;

    if (drawMode === 'line') draw(event);
    if (drawMode === 'arc') draw(event);
    if (drawMode === 'rect') draw(event);
    if (drawMode === 'roundRect') draw(event);
    if (drawMode === 'erase') erase(event);

    //(drawMode === 'arc') ? visuArea.addEventListener('click', drawArc) : visuArea.removeEventListener('click', drawArc); 
    //(drawMode === 'erase') ? visuArea.addEventListener('click', erase) : visuArea.removeEventListener('click', erase);    

}

function resetHighlightCanvas(resetPathData) {
    const highlightCanvas = document.querySelector('.highlightCanvas');
    const {startPath, controlPoint, width, height} = highlightCanvas;
    const ctx = highlightCanvas.getContext('2d');
    ctx.clearRect(0, 0, width, height);
    if (resetPathData) {
        startPath.xRel = undefined;
        startPath.yRel = undefined;
        controlPoint.xRel = undefined;
        controlPoint.yRel = undefined;
    }
}

function resetActiveVisuCanvas() {
    const visuCanvas = document.querySelector('.visuCanvas.active');
    const {width, height} = visuCanvas;
    const ctx = visuCanvas.getContext('2d');
    ctx.clearRect(0, 0, width, height);
}

function highlightGrid(event) {
	//console.log(event);
    if (!event) return event;
    const {target} = event;
    if (!target) return target;
    if (!target.className.includes('Canvas') && !target.className.includes('visuArea')) return target;

    const visuArea = document.querySelector('.visuArea');
    const {drawMode, orthoMode, gridSize, clientWidth, clientHeight} = visuArea;

    const highlightCanvas = document.querySelector('.highlightCanvas');
    const {startPath, controlPoint, width, height} = highlightCanvas;
    const x = event.layerX;
    const y = event.layerY;
    const startX = startPath.xRel * width;
    const startY = startPath.yRel * height;
    const controlX = controlPoint.xRel * width;
    const controlY = controlPoint.yRel * height;
    const microGridActive = document.querySelector('.btnMicroGrid.pressed');
    const dividerMicroGrid = (microGridActive) ? 2 : 1;
    let nextX = snapToGrid(x, gridSize.xRel / dividerMicroGrid * width);
    let nextY = snapToGrid(y, gridSize.yRel / dividerMicroGrid * height);

    const ctx = highlightCanvas.getContext('2d');
    resetHighlightCanvas();
    
    const pathStartColor = document.querySelector('.btnStartColor').style.color;
    const pathEndColor = document.querySelector('.btnEndColor').style.color;
    //console.log(drawMode, startPath);
    (drawMode == 'erase') ? ctx.fillStyle = 'black' : ctx.fillStyle = pathStartColor;

    if (startX && startY) {
        if (orthoMode && drawMode != 'erase')
            (Math.abs(startX - x) <= Math.abs(startY - y)) ? nextX = startX : nextY = startY;
        
        ctx.beginPath();
        ctx.arc(startX, startY, 5, 0, 2 * Math.PI);
        if (controlX && controlY) {
            ctx.fill();
            ctx.beginPath();
            ctx.arc(controlX, controlY, 5, 0, 2 * Math.PI);
            ctx.fill();
        }
        if (drawMode != 'erase') {
            ctx.fill();
            ctx.fillStyle = pathEndColor;
        }
        else {
            ctx.beginPath();
            ctx.fillRect(startX, startY, nextX - startX, nextY - startY);
            ctx.stroke();
        }
        if (drawMode == 'rect') {   //rectPreview...maybe add 4 lines too
            ctx.lineWidth = document.querySelector('.noLineWidth').valueAsNumber;
            ctx.strokeStyle = pathEndColor;
            ctx.beginPath();
            ctx.rect(startX, startY, nextX - startX, nextY - startY);
            ctx.stroke();
        }
        if (drawMode == 'roundRect') {   //rectPreview...maybe add 4 lines too
            const canvasGrid = document.querySelector('.canvasGrid');
            const roundRectRadii = gridSize.xRel/2 * canvasGrid.width
            ctx.lineWidth = document.querySelector('.noLineWidth').valueAsNumber;
            ctx.strokeStyle = pathEndColor;
            ctx.beginPath();
            try {
                ctx.roundRect(startX, startY, nextX - startX, nextY - startY, roundRectRadii);
            }
            catch (e) {
                roundRect(ctx, startX, startY, nextX - startX, nextY - startY, roundRectRadii);
            }
            ctx.stroke();
        }
    }
    ctx.beginPath();
    ctx.arc(nextX, nextY, 5, 0, 2 * Math.PI);
    ctx.fill();
}

function draw(event) {
    //console.log(event);
    if (!event) return event;
    const {target} = event;
    if (!target) return target;
    //console.log({target});
    if (!target.className.includes('Canvas') && !target.className.includes('visuArea')) return target;
    //if (!target.className.includes('auxCanvas') && !target.className.includes('visuArea')) return target;

    const visuArea = document.querySelector('.visuArea');
    const {drawMode, orthoMode, gridSize, clientWidth, clientHeight} = visuArea;
    
    const highlightCanvas = document.querySelector('.highlightCanvas');
    const {startPath, controlPoint, width, height} = highlightCanvas;

    const x = event.layerX;
    const y = event.layerY;
    const startX = startPath.xRel * width;
    const startY = startPath.yRel * height;
    const controlX = controlPoint.xRel * width;
    const controlY = controlPoint.yRel * height;
    const microGridActive = document.querySelector('.btnMicroGrid.pressed');
    const dividerMicroGrid = (microGridActive) ? 2 : 1;
    let nextX = snapToGrid(x, gridSize.xRel / dividerMicroGrid * width);
    let nextY = snapToGrid(y, gridSize.yRel / dividerMicroGrid * height);

	if (!startPath.xRel || !startPath.yRel) {
		highlightCanvas.startPath.xRel = nextX / width;
		highlightCanvas.startPath.yRel = nextY / height;
	}
	else if (drawMode == 'arc' && (!controlPoint.xRel || !controlPoint.yRel)) {
		highlightCanvas.controlPoint.xRel = nextX / width;
		highlightCanvas.controlPoint.yRel = nextY / height;
	}
	else{
		if ((startX != nextX) || (startY != nextY)) {
			if (orthoMode)
				(Math.abs(startX - x) <= Math.abs(startY - y)) ? nextX = startX : nextY = startY;
			
            const visuCanvas = document.querySelector('.visuCanvas.active');
            let {lineStack} = visuCanvas;
            if (!lineStack) lineStack = [];
			const ctx = visuCanvas.getContext('2d');
			const gradient = ctx.createLinearGradient(startX, startY, nextX, nextY);
            let pathStartColor = document.querySelector('.btnStartColor').style.color;
            if (!pathStartColor) pathStartColor = 'black';
            let pathEndColor = document.querySelector('.btnEndColor').style.color;
            if (!pathEndColor) pathEndColor = 'black';
			const fadeVal = 0.5 * !document.querySelector('.btnColorFade').className.includes('pressed');
            
            //console.log(pathStartColor);
			gradient.addColorStop(0, pathStartColor);
			gradient.addColorStop(fadeVal, pathStartColor);
			gradient.addColorStop(1-fadeVal, pathEndColor);
			gradient.addColorStop(1, pathEndColor);
            
            const canvasGrid = document.querySelector('.canvasGrid');
            const gridSizePx = gridSize.xRel/2 * canvasGrid.width; //effektiv ist halbe Gridsize relevant, da tempFühler klein...
            const dottedLineActive = document.querySelector('.btnDottedLine').classList.contains('pressed')
            const lineDashPatternArray = (dottedLineActive) ? [gridSizePx/4, gridSizePx/4] : [];
            ctx.setLineDash(lineDashPatternArray);
            ctx.lineWidth = document.querySelector('.noLineWidth').valueAsNumber;
			ctx.strokeStyle = gradient;
			ctx.beginPath();
            ctx.moveTo(startX, startY);
            if (drawMode == 'line') ctx.lineTo(nextX, nextY);
            if (drawMode == 'arc') ctx.arcTo(controlX, controlY, nextX, nextY, Math.min(Math.abs(nextX-startX), Math.abs(nextY-startY)));
            if (drawMode == 'rect') ctx.rect(startX, startY, nextX - startX, nextY - startY);
            if (drawMode == 'roundRect') {
                const canvasGrid = document.querySelector('.canvasGrid');
                const roundRectRadii = gridSize.xRel/2 * canvasGrid.width
                try {
                    ctx.roundRect(startX, startY, nextX - startX, nextY - startY, roundRectRadii);
                }
                catch (e) {
                    console.warn(`Your browser does not support roundRect()! workaroundFunction Used...`);
                    roundRect(ctx, startX, startY, nextX - startX, nextY - startY, roundRectRadii);
                }
            }
            //console.log(controlX, controlY, nextX, nextY, Math.min(Math.abs(nextX-startX), Math.abs(nextY-startY)));
			ctx.stroke();
			
            const line = {};
            line.drawMode = drawMode;
            line.startPath = {};
			line.startPath.xRel = startPath.xRel;
            line.startPath.yRel = startPath.yRel;
            line.controlPoint = {};
			line.controlPoint.xRel = (drawMode == 'arc') ? controlPoint.xRel : undefined;
            line.controlPoint.yRel = (drawMode == 'arc') ? controlPoint.yRel : undefined;
            line.endPath = {};
			line.endPath.xRel = nextX / clientWidth;
			line.endPath.yRel = nextY / clientHeight;
			line.pathStartColor = pathStartColor;
            line.pathEndColor = pathEndColor;
            line.lineWidth = ctx.lineWidth;
            line.lineDashPatternArray = lineDashPatternArray;
            line.fadeVal = fadeVal;
			lineStack.push(line);
            visuCanvas.lineStack = lineStack;
			
            //console.log(JSON.stringify(lineStack));
            //console.table(lineStack);
		}
		
		startPath.xRel = undefined;
        startPath.yRel = undefined;
        controlPoint.xRel = undefined;
		controlPoint.yRel = undefined;
	}
	highlightGrid(event);
}

function copyLineStackFrom(event) {
    const visuCanvasOriginIdx = document.querySelector('.noCopyLineStackFrom').valueAsNumber;
    if (!confirm(`Do you really want to overwrite the existing lineStack on THIS canvas with the lineStack of visuCanvas${visuCanvasOriginIdx}?`)) return;
    const activeVisuCanvas = document.querySelector('.visuCanvas.active');
    const originLineStack = document.querySelector(`#visuCanvas${visuCanvasOriginIdx}`).lineStack;
    activeVisuCanvas.lineStack = originLineStack;
    console.log(originLineStack);
    resetActiveVisuCanvas();
    drawStack(activeVisuCanvas);
}

function drawStack(visuCanvas) {
    if (!visuCanvas) visuCanvas = document.querySelector('.visuCanvas.active');
    let {lineStack, width, height} = visuCanvas;
    if (!lineStack) lineStack = [];
    const ctx = visuCanvas.getContext('2d');

	lineStack.forEach(function(el) {
        //console.log('redraw Canvas');
        const {drawMode, startPath, controlPoint, endPath, fadeVal, pathStartColor, pathEndColor, lineWidth, lineDashPatternArray} = el;
        const startX = startPath.xRel * width;
        const startY = startPath.yRel * height;
        const controlX = controlPoint.xRel * width;
        const controlY = controlPoint.yRel * height;
        const endX = endPath.xRel * width;
        const endY = endPath.yRel * height;
        
		const gradient = ctx.createLinearGradient(startX, startY, endX, endY);
        gradient.addColorStop(0, pathStartColor);
        gradient.addColorStop(fadeVal, pathStartColor);
        gradient.addColorStop(1-fadeVal, pathEndColor);
		gradient.addColorStop(1, pathEndColor);
        
		ctx.beginPath();
        ctx.setLineDash(lineDashPatternArray);
		ctx.strokeStyle = gradient;
        ctx.lineWidth = lineWidth;
        ctx.moveTo(startX, startY);
        if (!drawMode || drawMode == 'line') ctx.lineTo(endX, endY);
        if (drawMode == 'arc') ctx.arcTo(controlX, controlY, endX, endY, Math.min(Math.abs(endX-startX), Math.abs(endY-startY)));
        if (drawMode == 'rect') ctx.rect(startX, startY, endX - startX, endY - startY);
        if (drawMode == 'roundRect') {
            const canvasGrid = document.querySelector('.canvasGrid');
            const visuArea = document.querySelector('.visuArea');
            const {gridSize} = visuArea;
            const roundRectRadii = gridSize.xRel/2 * canvasGrid.width
            try {
                ctx.roundRect(startX, startY, endX - startX, endY - startY, roundRectRadii);
            }
            catch (e) {
                roundRect(ctx, startX, startY, endX - startX, endY - startY, roundRectRadii);
            }
        }
        ctx.stroke();
	});	
}

function erase(event) {
    //console.log(event);
    if (!event) return event;
    const {target} = event;
    if (!target) return target;
    if (!target.className.includes('Canvas') && !target.className.includes('visuArea')) return target;
    //if (!target.className.includes('Canvas') && !target.className.includes('visuArea')) return target;

    const visuArea = document.querySelector('.visuArea');
    const {drawMode, orthoMode, gridSize, clientWidth, clientHeight} = visuArea;
    
    const highlightCanvas = document.querySelector('.highlightCanvas');
    const {startPath, controlPoint, width, height} = highlightCanvas;

    const x = event.layerX;
    const y = event.layerY;
    const startX = gridSize.xRel * width;
    const startY = gridSize.yRel * height;
    const microGridActive = document.querySelector('.btnMicroGrid.pressed');
    const dividerMicroGrid = (microGridActive) ? 2 : 1;
    const nextX = snapToGrid(x, gridSize.xRel / dividerMicroGrid * width);
    const nextY = snapToGrid(y, gridSize.yRel / dividerMicroGrid * height);
    const nextXrel = nextX / width;
    const nextYrel = nextY / height;
    
    if (!startPath.xRel || !startPath.yRel) {
		highlightCanvas.startPath.xRel = nextXrel;
		highlightCanvas.startPath.yRel = nextYrel;
	}
	else {
        const visuCanvas = document.querySelector('.visuCanvas.active');
        let {lineStack} = visuCanvas;
        if (!lineStack) lineStack = [];
        const remainingLineStack = [];
		const ctx = visuCanvas.getContext('2d');
					
		//if (startPath.x == nextX || startPath.y == nextY) {		
			lineStack.forEach(function(el) {
                if (startX < nextX) {
                    if (Math.min(startPath.xRel, nextXrel) <= Math.min(el.startPath.xRel, el.endPath.xRel) && Math.min(startPath.yRel, nextYrel) <= Math.min(el.startPath.yRel, el.endPath.yRel) &&
                        Math.max(startPath.xRel, nextXrel) >= Math.max(el.startPath.xRel, el.endPath.xRel) && Math.max(startPath.yRel, nextYrel) >= Math.max(el.startPath.yRel, el.endPath.yRel)) {
                        //nothing
                    }
                    else {
                        remainingLineStack.push(el);
                    }
                }
                else {
                    console.log('todo...ACAD EraseLogic!');
                    if (Math.min(startPath.xRel, nextXrel) <= Math.min(el.startPath.xRel, el.endPath.xRel) && Math.min(startPath.yRel, nextYrel) <= Math.min(el.startPath.yRel, el.endPath.yRel) &&
                        Math.max(startPath.xRel, nextXrel) >= Math.max(el.startPath.xRel, el.endPath.xRel) && Math.max(startPath.yRel, nextYrel) >= Math.max(el.startPath.yRel, el.endPath.yRel)) {
                        //nothing
                    }
                    else {
                        remainingLineStack.push(el);
                    }
                }
            });
            visuCanvas.lineStack = remainingLineStack;
			
            resetActiveVisuCanvas();
			drawStack();
		
		startPath.xRel = undefined;
        startPath.yRel = undefined;
        controlPoint.xRel = undefined;
		controlPoint.yRel = undefined;
	}
	highlightGrid(event);	
}

function eraseLastPath() {
    console.log('eraseLastPath');
    const visuCanvas = document.querySelector('.visuCanvas.active');
    let {lineStack} = visuCanvas;
    if (!lineStack) lineStack = [];
    if (lineStack == []) return lineStack;
    lineStack.pop();
    resetActiveVisuCanvas();
	drawStack();
    return lineStack;
}

function roundRect(ctx, x, y, width, height, radii = document.querySelector('.visuArea').gridSize.xRel/2 * document.querySelector('.canvasGrid').width, stroke = false, fill = false) {
    if (typeof radii === 'number') {
      radii = {tl: radii, tr: radii, br: radii, bl: radii};
    } else {
      radii = {...{tl: 0, tr: 0, br: 0, bl: 0}, ...radii};
    }
    if (width < 0) {
        x += width;
        width *= -1;
    }
    if (height < 0) {
        y += height;
        height *= -1;
    }
    ctx.beginPath();
    ctx.moveTo(x + radii.tl, y);
    ctx.lineTo(x + width - radii.tr, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radii.tr);
    ctx.lineTo(x + width, y + height - radii.br);
    ctx.quadraticCurveTo(x + width, y + height, x + width - radii.br, y + height);
    ctx.lineTo(x + radii.bl, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radii.bl);
    ctx.lineTo(x, y + radii.tl);
    ctx.quadraticCurveTo(x, y, x + radii.tl, y);
    ctx.closePath();
    if (fill) {
      ctx.fill();
    }
    if (stroke) {
      ctx.stroke();
    }
  }