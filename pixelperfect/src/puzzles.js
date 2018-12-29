// Color pallette:
const RED = '#d11141';
const GREEN = '#00b159';
const BLUE = '#00aedb';
// const PINK = '#ff77aa';
// const ORANGE = '#f37735';
// const YELLOW = '#ffc425';

const PUZZLES = [
  {
    html: `<div class="square"></div>`,
    defaultCSS: `.square {
  width: 60px;
  height: 30px;
  background: ${BLUE};
}`,
    solutionCSS: `.square {
  width: 60px;
  height: 60px;
  background: ${BLUE};
}`,
  },
  {
    html: `<div class="square-rounded"></div>`,
    defaultCSS: `.square-rounded {
  width: 60px;
  height: 60px;
  background: ${GREEN};
}`,
    solutionCSS: `.square-rounded {
  width: 60px;
  height: 60px;
  border-radius: 5px;
  background: ${GREEN};
}`,
  },

  {
    html: `<div class="circle"></div>`,
    defaultCSS: `.circle {
  width: 60px;
  height: 60px;
  background: ${RED};
}`,
    solutionCSS: `.circle {
  width: 60px;
  height: 60px;
  border-radius: 60px;
  background: ${RED};
}`,
  },

  {
    html: `<div class="square-with-border"></div>`,
    defaultCSS: `.square {
  width: 60px;
  height: 60px;
  background: ${BLUE};
}`,
    solutionCSS: `.square-with-border {
  width: 24px;
  height: 24px;
  padding: 8px;
  border: 4px solid ${BLUE};
}`,
  },
];

export default PUZZLES;
