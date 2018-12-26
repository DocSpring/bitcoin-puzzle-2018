// From https://github.com/yixizhang/seed-shuffle

// similar to https://git.daplie.com/Daplie/knuth-shuffle/blob/master/index.js
// but use a more predictable random seed approach
function shuffle(array, seed) {
  var currentIndex = array.length;
  var temporaryValue;
  var randomIndex;
  seed = seed || 1;
  var random = function() {
    var x = Math.sin(seed++) * 10000;
    return x - Math.floor(x);
  };
  // While there remain elements to shuffle...
  while (0 !== currentIndex) {
    // Pick a remaining element...
    randomIndex = Math.floor(random() * currentIndex);
    currentIndex -= 1;
    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }
  return array;
}

module.exports = shuffle;
