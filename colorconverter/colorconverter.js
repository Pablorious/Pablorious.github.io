class ColorConverter extends HTMLElement {
    constructor() {
        super();
        this.shadow = this.attachShadow({mode: 'open'})
        this.shadowRoot.innerHTML = `
            <style> 
                #body {
                    background-color: rgb(0,43,54);
                }
                #buttonContainer {
                    display: flex;
                    flex-wrap: wrap;
                    width: 300px; /* set the width of the buttons container */
                }
                #fileInput,#colorsInput{
                    background-color: rgb(42,161,152);
                    padding: 7px;
                    margin-top: 5px;
                    margin-right: 5px; /* add a margin to the buttons */
                    color: white;
                    border: none;
                    cursor: pointer;
                }
                #canvas {
                    flex-grow: 1;
                    vertical-align: top;
                }
            </style>
 
            <div id="buttonContainer">
              <button id="fileInput">Choose Image</button>
              <select id="colorsInput">
                  <option value="solarized">Solarized</option>
                  <option value="grayscale">Grayscale</option>
                  <option value="neons">Neons</option>
                  <option value="black and white">Black and White</option>
              </select>
            </div>
            <input type="file" id="inputFile" accept="*" style="display:none"/>
            <canvas id="canvas"></canvas>
            `;        this._colors = 
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
            let distance = this._getColorDistanceSquared(r,g,b,color[0],color[1],color[2]);
            if (distance < nearestDistance){
                nearestColor = color;
                nearestDistance = distance;
            }
        }
        return nearestColor;
    }

    _getColorDistanceSquared(r1, g1, b1, r2, g2, b2) {
        function RGBtoL(red,green,blue) {
            return Math.pow((0.2126 * red),2) + 
		   Math.pow((0.7152 * green),2) + 
		   Math.pow((0.0722 * blue),2);
        }
	let l = Math.abs(RGBtoL(r1,g1,b1) - RGBtoL(r2,g2,b2));
        return l;
    }
}
customElements.define('color-converter',ColorConverter)
