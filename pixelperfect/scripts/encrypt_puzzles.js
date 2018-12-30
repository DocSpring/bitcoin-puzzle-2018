#!/usr/bin/env node
const fs = require('fs');
const CryptoJS = require('crypto-js');

const PUZZLES = require('../puzzles.js');

const k = 'ddc8312a4af4eb8652620c33152366bab3de8ffa36d9a08c1a';
const k2 = '330b5ee77929f0';
const encryptedPuzzles = CryptoJS.AES.encrypt(
  JSON.stringify(PUZZLES),
  k + k2
).toString();

const filename = 'src/puzzles.enc.ts';
console.log(`Writing encrypted puzzles to: ${filename}`);
fs.writeFileSync(
  filename,
  `\
import CryptoJS from 'crypto-js';

const k = '${k}';
const encryptedPuzzles = '${encryptedPuzzles}';
const decryptPuzzles = (): any[] =>
  JSON.parse(
    CryptoJS.AES.decrypt(encryptedPuzzles, k + '${k2}').toString(
      CryptoJS.enc.Utf8
    )
  );

export default decryptPuzzles;
`
);
