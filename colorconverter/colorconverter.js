class ColorConverter extends HTMLElement {
    constructor() {
        super();
        this.shadow = this.attachShadow({mode: 'open'})
        this.shadowRoot.innerHTML = `
            <style> 
                #body {
                    background-color: rgb(0,43,54);
                }
                #fileInput,#colorsInput{
                    background-color: rgb(42,161,152);
                    padding: 7px;
                    margin-top: 5px;
                    color: white;
                    border: none;
                    cursor: pointer;
                }
                #canvas {
                    vertical-align: top;
                }
            </style>
 
            <button id="fileInput">Choose Image</button>
            <select id="colorsInput">
                <option value="solarized">Solarized</option>
                <option value="grayscale">Grayscale</option>
                <option value="neons">Neons</option>
                <option value="black and white">Black and White</option>
            </select>
            <input type="file" id="inputFile" accept="*" style="display:none"/>
            <canvas id="canvas"></canvas>
            `;
        this._colors = 
             {neons: [[0,0,0],[255,0,0],[0,255,0],[0,0,255],[0,255,255],[255,0,255],[255,255,0],[255,255,255]]
             ,solarized : [[0,43,54],[181,137,0],[203,75,22],[220,50,47],[211,54,130],[108,113,196],[38,139,210],[42,161,152],[133,153,0]]
             ,grayscale : [[0,0,0],[255,255,255],[127,127,127],[63,63,63],[191,191,191]]
             ,"black and white" : [[0,0,0],[255,255,255]]
             }
        
        this.fileInputButton = this.shadow.querySelector("#fileInput");
        this.colorSelector = this.shadow.querySelector("#colorsInput");
        this.imageCanvas = this.shadow.querySelector("canvas");
        this.fileInputButton.addEventListener("click", this.openFileDialog.bind(this));
        this.colorSelector.addEventListener("change", this.updateCanvas.bind(this));
        this.image = null;
    }
     
    updateCanvas(){
        console.log(this.colorSelector.value);
        console.log(this._colors);
        console.log(this._colors[this.colorSelector.value]);
        const selectedColorScheme = this._colors[this.colorSelector.value];
        const ctx = this.imageCanvas.getContext("2d");
        ctx.drawImage(this.image, 0, 0, this.image.width, this.image.height);
        const imageData = ctx.getImageData(0, 0, this.imageCanvas.width, this.imageCanvas.height);
        const data = imageData.data;

        for (let i = 0; i < data.length; i += 4) {
            let r = data[i];
            let g = data[i + 1];
            let b = data[i + 2];
            let nearestColor = this._getNearestColor(r, g, b, selectedColorScheme.palette);

            data[i] = nearestColor[0];
            data[i + 1] = nearestColor[1];
            data[i + 2] = nearestColor[2];
    }
    ctx.putImageData(imageData, 0, 0);
}

    openFileDialog(){
        const fileInput = document.createElement("input");
        fileInput.type = "file";

        fileInput.addEventListener("change", (event) => {
            const file = event.target.files[0];
            const reader = new FileReader();
            
            reader.addEventListener("load", (event) => {
                this.image = new Image();
                this.image.src = event.target.result;

                this.image.addEventListener("load", () => {
                    this.imageCanvas.width = this.image.width;
                    this.imageCanvas.height = this.image.height;
                    
                    const ctx = this.imageCanvas.getContext("2d");
                    ctx.drawImage(this.image, 0, 0,this.image.width,this.image.height);
                    this.updateCanvas();
                });
            });
            reader.readAsDataURL(file);
        });
        fileInput.click();
    }

    _getNearestColor(r,g,b){
        let palette = this._colors[this.colorSelector.value]
        let nearestColor = palette[0];
        let nearestDistance = Number.MAX_SAFE_INTEGER;
        for (let color of palette){
            let distance = this._getColorDistance(r,g,b,color[0],color[1],color[2]);
            if (distance < nearestDistance){
                nearestColor = color;
                nearestDistance = distance;
            }
        }
        return nearestColor;
    }
    _getColorDistance(r1, g1, b1, r2, g2, b2) {
        //return Math.sqrt(Math.pow(r1 - r2, 2) + Math.pow(g1 - g2, 2) + Math.pow(b1 - b2, 2));
        function RGBtoHSL(red,green,blue) {
            let r = red / 255;
            let g = green / 255;
            let b = blue / 255;

            let min = Math.min(r, g, b);
            let max = Math.max(r, g, b);
            let delta = max - min;

            let h, s, l = (max + min) / 2;

            if (delta === 0) {
                h = 0;
                s = 0;
            } else {
                s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);
                let deltaR = (((max - r) / 6) + (delta / 2)) / delta;
                let deltaG = (((max - g) / 6) + (delta / 2)) / delta;
                let deltaB = (((max - b) / 6) + (delta / 2)) / delta;

                if (r === max) { h = deltaB - deltaG;} 
                else if (g === max) { h = (1 / 3) + deltaR - deltaB; } 
                else if (b === max) { h = (2 / 3) + deltaG - deltaR; }
            
                if (h < 0) h += 1;
                if (h > 1) h -= 1;
            }
            return [h, s, l];
        }

    function weightedHSLdistance(hsl1, hsl2) {
        let hDiff = 5 * Math.min(Math.abs(hsl1[0] - hsl2[0]), 1 - Math.abs(hsl1[0] - hsl2[0]));
        let sDiff = Math.abs(hsl1[1] - hsl2[1]);
        let lDiff = 20 * Math.abs(hsl1[2] - hsl2[2]);

        return Math.sqrt(hDiff * hDiff + sDiff * sDiff + lDiff * lDiff);
      }

    let hsl1 = RGBtoHSL(r1,g1,b1);
    let hsl2 = RGBtoHSL(r2,g2,b2);

    return weightedHSLdistance(hsl1, hsl2);
    }
}
customElements.define('color-converter',ColorConverter)
