---
title: "2018 Bitcoin Programming Challenge: Cubes"
slug: 2018-bitcoin-programming-challenge-cubes
date: 2018-12-30T04:32:08+07:00
draft: true
---

## Cubes

> *This challenge was inspired by the [3%](https://en.wikipedia.org/wiki/3%25) television series.*

You are given a set of 3-dimensional blocks with different shapes. You must find the correct orientation and position for each block so that they form an 8x8x8 cube. Blocks cannot overlap with other blocks, and there must be no empty cells in the 8x8x8 grid.

* [Download `blocks.json`](/blog/posts/2018-bitcoin-programming-challenge/eab75cf16b878ce659a3c3d7b8a71cad2ea48a508f9333ef37807a3c8ff3f531/blocks.json)

**The first block in the array has the correct orientation, and must be placed at `0, 0, 0`.** The rest of the blocks have been shuffled and randomly rotated around the X, Y, and Z axis. Rotations are a multiple of 90 degrees. Any empty space around the blocks has been trimmed.

Here's how the blocks are encoded:

* The outermost array contains the list of blocks.
* Each block is a nested array with 3 levels:
  * The first level is an array of "planes" along the Z axis (depth).
  * The second level is an array of "rows" along the Y axis (height).
  * The third level is an array of "cells" along the X axis (width).

Example:

```js
// Get the second block
const block = blocks[1]

// Get the value at {x: 2, y: 3, z: 4}
const value = block[4][3][2]
```


Each "cell" contains one of three values:

* `-1`: This is an empty cell.
* `0`: This cell encodes a single bit with a value of `0`.
* `1`: This cell encodes a single bit with a value of `1`.

Empty cells (`-1`) can overlap with the empty cells of other blocks.
`0` and `1` values must never overlap with other blocks.



<br/>

Here's a `2x1x1` block (`width: 2, height: 1, depth: 1`):

```js
[[[1, 0]]]
```

<img src="/blog/images/bitcoin-puzzle-2018/puzzle-piece-2x1x1.jpg" alt="2x1x1 Block" style="box-shadow: none; max-width: 400px;">

*In these visualizations, the lighter color represents a `1` bit, and the darker color represents a `0` bit.*

Here's a `1x2x2` block (`width: 1, height: 2, depth: 2`):

```js
[[[0], [0]], [[-1], [0]]]
```

<img src="/blog/images/bitcoin-puzzle-2018/puzzle-piece-1x2x2.jpg" alt="1x2x2 Block" style="box-shadow: none; max-width: 400px;">


Blocks can be rotated `0°`, `90°`, `180°`, or `270°` around the `X`, `Y` and `Z` axes:

<video width="100%" autoplay muted loop style="max-width: 400px;">
  <source src="/blog/videos/bitcoin-puzzle-2018/cube-solver-rotation.mp4" type="video/mp4">
</video>


Here's a `4x7x8` block that has been rotated:

<img src="/blog/images/bitcoin-puzzle-2018/puzzle-piece-rotation.jpg" alt="Rotated block" style="box-shadow: none; max-width: 400px;">

This is the block's original orientation and position:

<img src="/blog/images/bitcoin-puzzle-2018/puzzle-piece-correct.jpg" alt="Block with correct orientation" style="box-shadow: none; max-width: 400px;">

Here's all of the other blocks that form this `8x8x8` cube:

<video width="100%" autoplay muted loop style="max-width: 400px;">
  <source src="/blog/videos/bitcoin-puzzle-2018/cube-solver-pieces.mp4" type="video/mp4">
</video>

<br/>


Once you've solved the cube, concatenate all the bits from `0, 0, 0` to `7, 7, 7` in this order: `x, y, z`

```
x: 0, y: 0, z: 0
x: 1, y: 0, z: 0
x: 2, y: 0, z: 0
...
x: 6, y: 0, z: 0
x: 7, y: 0, z: 0
x: 0, y: 1, z: 0
x: 1, y: 1, z: 0
...
x: 6, y: 7, z: 0
x: 7, y: 7, z: 0
x: 0, y: 0, z: 1
x: 1, y: 0, z: 1
...
x: 5, y: 7, z: 7
x: 6, y: 7, z: 7
x: 7, y: 7, z: 7
```

The result will be 512 bits. Split this into two 256-bit values (the first 256 bits, and the last 256 bits). `XOR` these 256-bit values together to produce a single 256-bit value. This is the private key for a Bitcoin address that contains
**0.005 BTC**.

You will need to convert this private key to the wallet import format (WIF), so that you can import it into a Bitcoin wallet. First, encode the 256-bit value as a hex string.

Then you can do use the [bitcoin-explorer](https://github.com/libbitcoin/libbitcoin-explorer)
command-line tool:

```bash
$ echo <hex-encoded-private-key> | bx base58check-encode -v 128
```

Or you can use [this Ruby script](https://gist.github.com/ndbroadbent/522c374d18e6a5d592465ff83d49efe0):

```bash
$ private_key_to_wif.rb <hex-encoded-private-key>
```

Now you can import the private key and transfer the 0.005 BTC to your own address.

<br/>

---

## Stage 3

Now that you've solved the cube, you can proceed to the next stage by visiting this URL:

```
https://formapi.io/blog/posts/2018-bitcoin-programming-challenge/
<hex-encoded-private-key>
```

*(Replace `<hex-encoded-private-key>` with the 256-bit hex-encoded string.)*
