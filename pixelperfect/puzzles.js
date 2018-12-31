const PUZZLES = [
  {
    name: 'Width and Height',
    html: `\
<div class="square"></div>`,
    solutionCSS: `\
.square {
  width: 60px;
  height: 60px;
  background: #00aedb;
}`,
    defaultCSS: `\
.square {
  width: 60px;
  height: 30px;
  background: #00aedb;
}`,
  },

  {
    name: 'Margin',
    html: `<div class="square"></div>`,
    solutionCSS: `\
.square {
  width: 60px;
  height: 60px;
  margin-top: 20px;
  margin-left: 40px;
  background: #00aedb;
}`,
    defaultCSS: `\
.square {
  width: 60px;
  height: 60px;
  background: #00aedb;
}`,
  },

  {
    name: 'Circle',
    html: `<div class="circle"></div>`,
    solutionCSS: `\
.circle {
  width: 60px;
  height: 60px;
  border-radius: 60px;
  background: #d11141;
}`,
    defaultCSS: `\
.circle {
  width: 60px;
  height: 60px;
  background: #d11141;
}`,
  },

  {
    name: 'Square Border',
    html: `<div class="square"></div>`,
    solutionCSS: `\
.square {
  width: 40px;
  height: 40px;
  border: 10px solid #00aedb;
}`,
    defaultCSS: `\
.square {
  width: 60px;
  height: 60px;
  background: #00aedb;
}`,
  },

  {
    name: 'Diamond',
    html: `<div class="diamond"></div>`,
    solutionCSS: `\
.diamond {
  width: 64px;
  height: 64px;
  margin: 20px;
  transform: rotate(45deg);
  background: #ff77aa;
}`,
    defaultCSS: `\
.diamond {
  background: #ff77aa;
}`,
  },

  {
    name: 'Triangle',
    html: `<div class="triangle"></div>`,
    solutionCSS: `\
.triangle {
  margin-left: 21px;
  border-top: 30px solid transparent;
  border-bottom: 30px solid transparent;
  border-left: 50px solid #f37735;
}`,
    defaultCSS: `\
.triangle {
  color: #f37735;
}`,
  },

  {
    name: 'Two circles in a square',
    html: `\
<div class="square">
  <div class="circle" />
</div>`,
    solutionCSS: `\
.square {
  width: 110px;
  height: 110px;
  border: 5px solid #d11141;
  position: relative;
}
.circle {
  border: 5px solid #00b159;
  width: 55px;
  height: 55px;
  border-radius: 50%;
  position: absolute;
  top: 10px;
  left: 10px;
}
.circle::after {
  content: "";
  border: 5px solid #00b159;
  width: 55px;
  height: 55px;
  border-radius: 50%;
  position: absolute;
  top: 20px;
  left: 20px;
}`,
    defaultCSS: `\
.square {
  /* #d11141 */
}
.circle {
  /* #00b159 */
}`,
  },

  {
    name: 'Find the Color',
    html: `\
<div class="container">
  <div class="triangle"></div>
  <div class="circle"></div>
</div>`,
    solutionCSS: `\
.container {
  padding: 5px;
  position: relative;
  width: 220px;
  height: 120px;
  background: #660077;
  margin-left: 32px;
  overflow: hidden;
}
.triangle {
  position: absolute;
  left: 55px;
  bottom: 30px;
  border-top: 30px solid transparent;
  border-bottom: 30px solid transparent;
  border-right: 40px solid #ff88bb;
  z-index: 10;
}
.circle {
  position: absolute;
  bottom: -30px;
  right: 65px;
  background: #ffe475;
  width: 100px;
  height: 100px;
  border-radius: 50px;
  z-index: 0;
}`,
    defaultCSS: `\
.container {

}
.triangle {

}
.circle {

}`,
  },
];

module.exports = PUZZLES;
