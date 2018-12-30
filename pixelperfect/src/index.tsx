import 'react-app-polyfill/ie9';
import 'core-js/es6/array';

import React from 'react';
import ReactDOM from 'react-dom';
import './style/index.less';
import App from './App';
import * as serviceWorker from './serviceWorker';

if (process.env.NODE_ENV === 'production') {
  const disableReactDevTools = (): void => {
    const noop = (): void => undefined;
    const DEV_TOOLS = (window as any).__REACT_DEVTOOLS_GLOBAL_HOOK__;

    if (typeof DEV_TOOLS === 'object') {
      for (const key of Object.keys(DEV_TOOLS)) {
        const value = DEV_TOOLS[key];
        DEV_TOOLS[key] = typeof value === 'function' ? noop : null;
      }
    }
  };
  disableReactDevTools();
}

import decryptPuzzles from './puzzles.enc';
const PUZZLES = decryptPuzzles();

ReactDOM.render(<App puzzles={PUZZLES} />, document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: http://bit.ly/CRA-PWA
serviceWorker.unregister();
