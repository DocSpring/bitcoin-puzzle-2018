// Color pallette:
const RED = '#d11141';
const GREEN = '#00b159';
const BLUE = '#00aedb';
const ORANGE = '#f37735';
const PINK = '#ff77aa';
// const YELLOW = '#ffc425';

const PUZZLES = [
  {
    name: 'Width and Height',
    html: `\
<div class="square"></div>`,
    solutionCSS: `\
.square {
  width: 60px;
  height: 60px;
  background: ${BLUE};
}`,
    defaultCSS: `\
.square {
  width: 60px;
  height: 30px;
  background: ${BLUE};
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
  background: ${BLUE};
}`,
    defaultCSS: `\
.square {
  width: 60px;
  height: 60px;
  background: ${BLUE};
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
  background: ${RED};
}`,
    defaultCSS: `\
.circle {
  width: 60px;
  height: 60px;
  background: ${RED};
}`,
  },

  {
    name: 'Square Border',
    html: `<div class="square"></div>`,
    solutionCSS: `\
.square {
  width: 40px;
  height: 40px;
  border: 10px solid ${BLUE};
}`,
    defaultCSS: `\
.square {
  width: 60px;
  height: 60px;
  background: ${BLUE};
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
  background: ${PINK};
}`,
    defaultCSS: `\
.diamond {
  background: ${PINK};
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
  border-left: 50px solid ${ORANGE};
}`,
    defaultCSS: `\
.triangle {
  color: ${ORANGE};
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
  border: 5px solid ${RED};
  position: relative;
}
.circle {
  border: 5px solid ${GREEN};
  width: 55px;
  height: 55px;
  border-radius: 50%;
  position: absolute;
  top: 10px;
  left: 10px;
}
.circle::after {
  content: "";
  border: 5px solid ${GREEN};
  width: 55px;
  height: 55px;
  border-radius: 50%;
  position: absolute;
  top: 20px;
  left: 20px;
}`,
    defaultCSS: `\
.square {
  /* ${RED} */
}
.circle {
  /* ${GREEN} */
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
  background: linear-gradient(#ee4444, #4444dd);
  margin-left: 32px;
  overflow: hidden;
}
.triangle {
  position: absolute;
  left: 55px;
  bottom: 29px;
  border-top: 40px solid transparent;
  border-bottom: 45px solid transparent;
  border-right: 50px solid #ff77aa;
  transform: rotate(81deg);
  z-index: 10;
}
.circle {
  position: absolute;
  bottom: -30px;
  right: 65px;
  background: linear-gradient(#ffe475, #ff77aa);
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

export default PUZZLES;
