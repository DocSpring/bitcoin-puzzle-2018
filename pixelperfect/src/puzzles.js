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
    name: 'Round corners',
    html: `<div class="square"></div>`,
    solutionCSS: `\
.square {
  width: 60px;
  height: 60px;
  border-radius: 20px;
  background: ${GREEN};
}`,
    defaultCSS: `\
.square {
  width: 60px;
  height: 60px;
  background: ${GREEN};
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
    name: 'Triangle',
    html: `<div class="triangle"></div>`,
    solutionCSS: `\
.triangle {
  border-top: 60px solid transparent;
  border-bottom: 60px solid transparent;
  border-left: 60px solid ${ORANGE};
}`,
    defaultCSS: `\
.triangle {
  /* color: ${ORANGE} */
}`,
  },

  {
    name: 'Two circles in a square',
    html: `\
<div class="square">
  <div class="circle-one" />
  <div class="circle-two" />
</div>`,
    solutionCSS: `\
.square {
  width: 110px;
  height: 110px;
  border: 5px solid #ff0000;
  position: relative;
}
.circle-one, .circle-two {
  border: 5px solid #00ff00;
  width: 55px;
  height: 55px;
  border-radius: 50%;
  position: absolute;
}

.circle-one {
  top: 10px;
  left: 10px;
}
.circle-two {
  bottom: 10px;
  right: 10px;
}`,
    defaultCSS: `\
.square {

}
.circle-one, .circle-two {

}
.circle-one: {

}

.circle-two: {

}`,
  },
];

export default PUZZLES;
