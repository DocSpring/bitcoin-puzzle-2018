import React, { Component } from 'react';
import { createSelector } from 'reselect';
import classNames from 'classnames';
import $ from 'jquery';
import { debounce, bind } from 'lodash-es';
import CryptoJS from 'crypto-js';

import html2canvas from 'html2canvas';
import pixelmatch from 'pixelmatch';

import {
  Button,
  Layout,
  Menu,
  Modal,
  Icon,
  Card,
  List,
  Progress,
  Alert,
  notification,
} from 'antd';
import Editor from 'react-simple-code-editor';
import { highlight, languages } from 'prismjs/components/prism-core';
import 'prismjs/themes/prism-solarizedlight.css';
import 'prismjs/components/prism-clike';
import 'prismjs/components/prism-javascript';
import 'prismjs/components/prism-css';

import Highlight, {
  defaultProps as prismDefaultProps,
} from 'prism-react-renderer';

import { ReactComponent as TargetIcon } from './icons/target.svg';
import { ReactComponent as ResultIcon } from './icons/magnifying-glass.svg';
import { ReactComponent as DiffIcon } from './icons/diff.svg';

import LogoImage from './images/logo.svg';

const { Header, Content, Footer, Sider } = Layout;
const SubMenu = Menu.SubMenu;

import './style/AntDesign/index.less';
import './style/app.less';
import './style/prism.less';

import PUZZLES from './puzzles';

const PUZZLE_LIST: string[] = PUZZLES.map((_, i) => `Puzzle ${i}`);

// Not sure why this library is so verbose :/
const highlightHTML = (html: string) => {
  return (
    <Highlight
      {...prismDefaultProps}
      code={html}
      language="html"
      theme={undefined}
    >
      {({
        className,
        style,
        tokens,
        getLineProps,
        getTokenProps,
      }: {
        className: any;
        style: any;
        tokens: any;
        getLineProps: any;
        getTokenProps: any;
      }) => (
        <pre className={className} style={style}>
          {tokens.map((line: any, i: any) => (
            <div {...getLineProps({ line, key: i })}>
              {line.map((token: any, key: any) => (
                <span {...getTokenProps({ token, key })} />
              ))}
            </div>
          ))}
        </pre>
      )}
    </Highlight>
  );
};

// Show the default CSS for an unsolved puzzle.
// Show the solution if it has already been solved.
const defaultCSSForCurrentPuzzleSelector = ({
  currentPuzzleIndex,
  unlockedPuzzleIndex,
  completed,
}: {
  currentPuzzleIndex: number;
  unlockedPuzzleIndex: number;
  completed: boolean;
}) => {
  const puzzle = PUZZLES[currentPuzzleIndex];
  return currentPuzzleIndex < unlockedPuzzleIndex ||
    (completed && unlockedPuzzleIndex == PUZZLES.length - 1)
    ? puzzle.solutionCSS
    : puzzle.defaultCSS;
};

const solutionCSSSelector = (state: State) =>
  PUZZLES[state.currentPuzzleIndex].solutionCSS;

type State = {
  currentPuzzleIndex: number;
  unlockedPuzzleIndex: number;
  completed: boolean;
  cssCode: string;
  diffPixels: number;
  diffPercentage: number;
  successVisible: boolean;
  completedModalVisible: boolean;
};

const DEFAULT_STATE: State = {
  currentPuzzleIndex: 0,
  unlockedPuzzleIndex: 0,
  completed: false,
  cssCode: '',
  diffPixels: 0,
  diffPercentage: 0,
  successVisible: false,
  completedModalVisible: false,
};

// const DEBUG = process.env.NODE_ENV === 'development';
const log = process.env.NODE_ENV === 'development' ? console.log : () => {};

const saveStateToLocalStorage = (state: State) => {
  const { currentPuzzleIndex, unlockedPuzzleIndex, completed } = state;
  const savedState = {
    currentPuzzleIndex,
    unlockedPuzzleIndex,
    completed,
  };
  const encryptedState = CryptoJS.AES.encrypt(
    JSON.stringify(savedState),
    PUZZLES[4].html + PUZZLES[2].solutionCSS + PUZZLES[0].html
  ).toString();
  // Update the saved state in localStorage
  localStorage.setItem('state', encryptedState);
};

const fetchStateFromLocalStorage = () => {
  const encryptedState = localStorage.getItem('state');
  if (!encryptedState) return {};
  try {
    const stateJSON = CryptoJS.AES.decrypt(
      encryptedState,
      PUZZLES[4].html + PUZZLES[2].solutionCSS + PUZZLES[0].html
    ).toString(CryptoJS.enc.Utf8);
    const state = JSON.parse(stateJSON);
    log('Decrypted state from local storage', state);
    return state;
  } catch (err) {
    log('Error fetching state from local storage!', err);
    return {};
  }
};

// const encryptedData = CryptoJS.AES.encrypt(
//   JSON.stringify([
//     '5Kbf6NSm6SABiMHwDcuZKY17fmCsnsKRYxR4hcnGqfzPsTeZnEj',
//     'https://formapi.io/blog/posts/2018-bitcoin-programming-challenge/eab75cf16b878ce659a3c3d7b8a71cad2ea48a508f9333ef37807a3c8ff3f531/',
//   ]),
//   PUZZLES[1].html + PUZZLES[5].solutionCSS + PUZZLES[2].html + PUZZLES[3].html
// ).toString();
// console.log({ encryptedData });

const ENCRYPTED_DATA =
  'U2FsdGVkX1/NARMbPXWPT95Fr4K9LXzCSkiB0dSed/4AL7H39G9q4hW88Ae3H7IyHw3A7xMF7/fX6dDlukPwiA1lhJdPEQHluwO9p+QTVtpeBW9jNiu9vdBHgOdpZ5XmVG1hztEztbkIa6zKkAdCclk7PtljZZApWJUwaFDx0LHKyjc9osUQXg2XPHyQCvC8wO39p6Wp/tKwauQABzNRwaL885ohUAaaJJ4wcog5neCTQjUq+tXLVhE6La81pJono1TxRhmoAIynpvYp9/+zkQ==';

// Important - Don't decrypt this until the puzzle is solved,
// so that it is never loaded into memory until required.
const decryptData = (): string[] =>
  JSON.parse(
    CryptoJS.AES.decrypt(
      ENCRYPTED_DATA,
      PUZZLES[1].html +
        PUZZLES[5].solutionCSS +
        PUZZLES[2].html +
        PUZZLES[3].html
    ).toString(CryptoJS.enc.Utf8)
  );

class App extends Component {
  targetCanvas: HTMLCanvasElement | null = null;
  resultCanvas: HTMLCanvasElement | null = null;
  diffCanvas: HTMLCanvasElement | null = null;

  targetImageData: ImageData | undefined;
  resultImageData: ImageData | undefined;
  diffImageData: ImageData | undefined;
  diffPixelsFormattedSelector: (state: State) => string;

  renderCSSTimeout: number | undefined;
  cancelCurrentCSSUpdate: Function | undefined;
  cancelCurrentCSSRender: Function | undefined;

  decryptedData: string[] | undefined;

  state = DEFAULT_STATE;

  constructor(props: any) {
    super(props);

    // Load the puzzle indexes from localStorage
    // Whoops, can't let the user modify these so easily.

    const loadedState = fetchStateFromLocalStorage();
    const currentPuzzleIndex = Math.min(
      PUZZLES.length - 1,
      loadedState.currentPuzzleIndex || 0
    );
    const unlockedPuzzleIndex = Math.min(
      PUZZLES.length - 1,
      loadedState.unlockedPuzzleIndex || 0
    );

    if (unlockedPuzzleIndex === PUZZLES.length - 1 && loadedState.completed) {
      this.state.completed = true;
    }
    this.state.currentPuzzleIndex = currentPuzzleIndex;
    this.state.unlockedPuzzleIndex = unlockedPuzzleIndex;
    this.state.cssCode = defaultCSSForCurrentPuzzleSelector(this.state);

    this.diffPixelsFormattedSelector = createSelector(
      (state: State) => state.diffPixels,
      (diffPixels: number) => {
        if (diffPixels >= 1000000) {
          return (diffPixels / 1000000).toFixed(1) + 'M px';
        } else if (diffPixels >= 1000) {
          return (diffPixels / 1000).toFixed(1) + 'K px';
        }
        return `${diffPixels}px`;
      }
    );
  }

  componentDidMount() {
    this.renderCSSToTargetCanvas(solutionCSSSelector(this.state)).then(() =>
      this.renderCSSToResultCanvas(this.state.cssCode)
    );

    // Takes a while for the containers to be positioned
    window.setTimeout(() => {
      this.resizeCanvases();
    }, 100);
    window.addEventListener('resize', this.resizeCanvasesDebounced);
  }

  componentWillUpdate(nextProps: any, nextState: State) {
    if (nextState.completed && !this.decryptedData) {
      // Decrypt the data now.
      this.decryptedData = decryptData();
    }
  }

  componentDidUpdate(prevProps: any, prevState: State) {
    if (this.state.currentPuzzleIndex !== prevState.currentPuzzleIndex) {
      // Render changes immediately when changing the puzzle
      this.renderCSSIfUpdated(prevState);
    } else {
      // Update after a delay when editing CSS
      this.renderCSSIfUpdatedDebounced(prevState);
    }

    if (
      this.state.currentPuzzleIndex !== prevState.currentPuzzleIndex ||
      this.state.unlockedPuzzleIndex !== prevState.unlockedPuzzleIndex ||
      this.state.completed !== prevState.completed
    ) {
      saveStateToLocalStorage(this.state);
    }

    if (this.state.diffPercentage === 100 && prevState.diffPercentage !== 100) {
      // The current puzzle was just solved.
      // Unlock the next puzzle (if not already unlocked.)
      const unlockedPuzzleIndex = Math.min(
        PUZZLES.length - 1,
        Math.max(
          this.state.currentPuzzleIndex + 1,
          this.state.unlockedPuzzleIndex
        )
      );
      let successVisible = this.state.successVisible;
      if (unlockedPuzzleIndex > this.state.unlockedPuzzleIndex) {
        // Always show the success message when we've unlocked a new puzzle.
        // (Otherwise, don't keep showing it if the player wants to adjust the CSS.)
        // Also don't show it at the end (we show the modal instead.)
        successVisible = true;
      }

      // Check if the whole puzzle is finished.
      let { completed, completedModalVisible } = this.state;
      if (this.state.currentPuzzleIndex === PUZZLES.length - 1) {
        // Show the completed modal only when completed changes to true
        if (!completed) completedModalVisible = true;
        completed = true;
      }

      this.setState({
        successVisible,
        unlockedPuzzleIndex,
        completed,
        completedModalVisible,
      });
    }

    // Sanity check to make sure we never show any unlocked puzzles,
    // even if we have a bug somewhere else.
    if (this.state.currentPuzzleIndex > this.state.unlockedPuzzleIndex) {
      this.setState({
        currentPuzzleIndex: this.state.unlockedPuzzleIndex,
      });
    }
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.resizeCanvasesDebounced);
  }

  changePuzzle(puzzleIndex: number) {
    const { currentPuzzleIndex, unlockedPuzzleIndex } = this.state;
    // Don't do anything if this is already the current puzzle.
    // (Otherwise we clear the diff percentage.)
    if (currentPuzzleIndex === puzzleIndex) return;

    if (puzzleIndex < 0) return;
    // Don't allow any unlocked puzzles
    if (puzzleIndex > unlockedPuzzleIndex) {
      notification.open({
        message: 'Whoops, something went wrong!',
        description: `You don't have access to Puzzle ${puzzleIndex}!`,
      });
      return;
    }
    // Always update the current CSS when changing the puzzle.
    const cssCode = defaultCSSForCurrentPuzzleSelector({
      currentPuzzleIndex: puzzleIndex,
      unlockedPuzzleIndex,
      completed: this.state.completed,
    });

    this.setState({
      currentPuzzleIndex: puzzleIndex,
      cssCode,
      diffPercentage: 0,
      successVisible: false,
    });
  }

  resizeCanvases() {
    log('Resizing canvases...');
    const devicePixelRatio = window.devicePixelRatio;

    [
      {
        canvas: this.targetCanvas,
        imageData: this.targetImageData,
      },
      {
        canvas: this.resultCanvas,
        imageData: this.resultImageData,
      },
      {
        canvas: this.diffCanvas,
        imageData: this.diffImageData,
      },
    ].forEach(({ canvas, imageData }) => {
      if (!canvas) return;
      const context = canvas.getContext('2d');
      if (!context) return;
      const cardBodyEl = $(canvas).parents('.ant-card-body')[0];
      if (!cardBodyEl) return;
      const cardWidth = cardBodyEl.offsetWidth - 48;
      // Set a min height of 140px (enough for all the puzzles)
      const cardHeight = Math.max(cardBodyEl.offsetHeight - 48, 140);

      canvas.width = cardWidth * devicePixelRatio;
      canvas.height = cardHeight * devicePixelRatio;
      context.setTransform(devicePixelRatio, 0, 0, devicePixelRatio, 0, 0);

      canvas.style.width = `${cardWidth}px`;
      canvas.style.height = `${cardHeight}px`;

      if (!imageData) return;
      // Redraw the image data
      context.clearRect(0, 0, canvas.width, canvas.height);
      context.putImageData(imageData, 0, 0);
    });
  }
  resizeCanvasesDebounced = debounce(bind(this.resizeCanvases, this), 300);

  renderCSSIfUpdated(prevState: State) {
    const puzzleChanged =
      this.state.currentPuzzleIndex !== prevState.currentPuzzleIndex;
    const cssChanged = this.state.cssCode !== prevState.cssCode;

    if (!puzzleChanged && !cssChanged) return;

    // Only cancel the current render if we're about to start a new one.
    let cancelledPreviousRender = false;
    if (this.cancelCurrentCSSRender) {
      this.cancelCurrentCSSRender();
      this.cancelCurrentCSSRender = undefined;
      cancelledPreviousRender = true;
    }

    let promise = Promise.resolve();
    if (puzzleChanged) {
      promise = promise.then(() =>
        this.renderCSSToTargetCanvas(solutionCSSSelector(this.state))
      );
    }

    // If the CSS changed, OR if we just cancelled an in-progress render,
    // then update the results + image diff
    // Note: We ALWAYS have to rerender the result if the puzzle changes,
    // even if the the CSS doesn't change (because the HTML is different.)
    if (puzzleChanged || cssChanged) {
      promise = promise.then(() =>
        this.renderCSSToResultCanvas(this.state.cssCode)
      );
    }

    return promise
      .then(() => {
        log('Render completed!');
      })
      .catch(() => {
        log('Render was cancelled!');
      });
  }
  renderCSSIfUpdatedDebounced = debounce(
    bind(this.renderCSSIfUpdated, this),
    300
  );

  renderCSSToTargetCanvas(css: string) {
    log('Rendering target canvas...');

    return this.renderCSSToCanvas(css, this.targetCanvas).then(imageData => {
      this.targetImageData = imageData;
    });
  }

  renderCSSToResultCanvas(css: string) {
    log('Rendering result canvas...');
    // Whenever we update the result canvas,
    // we also need to update the diff image.
    return this.renderCSSToCanvas(css, this.resultCanvas).then(imageData => {
      this.resultImageData = imageData;
      return this.updateImageDiff();
    });
  }

  renderCSSToCanvas(
    css: string,
    canvas: HTMLCanvasElement | null
  ): Promise<ImageData> {
    return new Promise((resolve, reject) => {
      if (!canvas) {
        reject();
        return;
      }
      const puzzleHTML = PUZZLES[this.state.currentPuzzleIndex].html;
      const renderHTML = `<html>
  <head>
    <style>html, body { margin: 0; padding: 0; }</style>
    <style>${css}</style>
  </head>
  <body>
    ${puzzleHTML}
  </body>
</html>`;
      const iframe = document.createElement('iframe');
      const $iframe = $(iframe);
      $iframe.css({
        position: 'absolute',
        left: '-10000px',
      });

      let promiseRejected = false;
      this.cancelCurrentCSSRender = () => {
        log('Cancelling current render...');
        promiseRejected = true;
        reject();
      };

      const iframeLoaded = () => {
        if (promiseRejected) {
          $iframe.remove();
          return;
        }
        var iframedoc =
          iframe.contentDocument ||
          (iframe.contentWindow && iframe.contentWindow.document);
        if (!iframedoc) {
          reject(new Error('Sorry, your browser is not supported!'));
          return;
        }
        $('body', $(iframedoc)).html(renderHTML);
        // Use default scale of 2 (devicePixelRatio)
        html2canvas(iframedoc.body).then((renderCanvas: HTMLCanvasElement) => {
          const renderContext = renderCanvas.getContext('2d');
          const canvasContext = canvas.getContext('2d');
          if (!canvasContext || !renderContext) {
            $iframe.remove();
            reject();
            return null;
          }
          const { width, height } = renderCanvas;
          const imageData = renderContext.getImageData(0, 0, width, height);

          // Display the image on the canvas
          canvasContext.clearRect(0, 0, canvas.width, canvas.height);
          canvasContext.putImageData(imageData, 0, 0);

          $iframe.remove();
          if (promiseRejected) return;
          this.cancelCurrentCSSRender = undefined;
          resolve(imageData);
        });
      };

      const iframeLoadTimer = setInterval(function() {
        var iframedoc =
          iframe.contentDocument ||
          (iframe.contentWindow && iframe.contentWindow.document);
        if (!iframedoc) {
          reject(new Error('Sorry, your browser is not supported!'));
          return;
        }
        if (iframedoc.readyState == 'complete') {
          clearInterval(iframeLoadTimer);
          iframeLoaded();
        }
      }, 50);

      // Load event isn't fired on Safari.
      // See: https://stackoverflow.com/a/23552375/304706
      // $iframe.on('load', () => {});

      $('body').append($iframe);
    });
  }

  updateImageDiff() {
    log('Rendering image diff...');
    if (!this.targetImageData || !this.resultImageData) return;

    if (!this.diffCanvas) return;
    const diffContext = this.diffCanvas.getContext('2d');
    if (!diffContext) return;

    const { width, height } = this.targetImageData;

    const diffImage = diffContext.createImageData(width, height);
    let diffPixels = pixelmatch(
      this.resultImageData.data,
      this.targetImageData.data,
      diffImage.data,
      width,
      height,
      {
        threshold: 0.01,
      }
    );
    // diffContext.clearRect(0, 0, width, height);
    diffContext.putImageData(diffImage, 0, 0);
    this.diffImageData = diffImage;

    // Calculate the bounds of the diff image,
    // and use this to calculate the diff percentage.
    // From: https://stackoverflow.com/a/22267731/304706
    // ImageData is an array of R,G,B,A bytes.
    // See: https://www.w3schools.com/tags/canvas_imagedata_data.asp
    let x, y, index;
    const pixels: { x: number[]; y: number[] } = { x: [], y: [] };

    for (y = 0; y < height; y++) {
      for (x = 0; x < width; x++) {
        index = (y * width + x) * 4;
        // A is always 255 in the pixelmatch result.
        // Ignore white pixels by checking RGB
        if (
          diffImage.data[index] < 255 ||
          diffImage.data[index + 1] < 255 ||
          diffImage.data[index + 2] < 255
        ) {
          pixels.x.push(x);
          pixels.y.push(y);
        }
      }
    }

    // Sanity check - There were some anti-aliasing issues
    // with a previous version of the code.
    let offset;
    let unmatched = 0;
    let matched = 0;
    for (y = 0; y < height; y++) {
      for (x = 0; x < width; x++) {
        for (offset = 0; offset < 4; offset++) {
          index = y * width + x + offset;
          if (
            this.targetImageData.data[index] ===
            this.resultImageData.data[index]
          ) {
            matched++;
          } else {
            unmatched++;
          }
        }
      }
    }
    log('Matched pixel values for target / result: ', { matched, unmatched });

    pixels.x.sort((a, b) => a - b);
    pixels.y.sort((a, b) => a - b);
    const maxXY = pixels.x.length - 1;
    const diffWidth = pixels.x[maxXY] - pixels.x[0] + 1;
    const diffHeight = pixels.y[maxXY] - pixels.y[0] + 1;

    const diffTotalPixels = diffWidth * diffHeight;
    const diffPercentage = (1 - diffPixels / diffTotalPixels) * 100;

    // Canvas is scaled up 2x on Retina displays, etc.
    if (window.devicePixelRatio === 2) {
      diffPixels = diffPixels / 4;
    }

    this.setState({
      diffPercentage,
      diffPixels,
    });
  }

  cardTitle(label: any, icon?: JSX.Element, rightIconType?: string) {
    return (
      <div style={{ color: '#aaa', display: 'flex', alignItems: 'center' }}>
        {icon}
        <span style={{ marginLeft: '10px', textTransform: 'uppercase' }}>
          {label}
        </span>
        {rightIconType ? <Icon type={rightIconType} /> : null}
        <div />
      </div>
    );
  }

  highlightedHTMLSelector = createSelector(
    (state: State) => state.currentPuzzleIndex,
    puzzleIndex => highlightHTML(PUZZLES[puzzleIndex].html)
  );

  render() {
    const cardStyle = { flex: 1, margin: '5px' };

    return (
      <Layout style={{ minHeight: '100vh' }}>
        <Sider width={240} style={{ background: '#fff' }}>
          <Content style={{ padding: '21px' }}>
            <div className="logo-container">
              <img className="logo" src={LogoImage} alt="PixelPerfect Logo" />
              <h2>PixelPerfect</h2>
            </div>

            <p>
              Write CSS that matches the target image. The puzzle is solved when
              your CSS is 100% pixel perfect.
            </p>
            <p>
              PixelPerfect uses{' '}
              <a href="http://html2canvas.hertzen.com">HTML2Canvas</a> to render
              HTML/CSS to an image.{' '}
              <a href="http://html2canvas.hertzen.com/features">
                Please check the list of supported CSS properties.
              </a>
            </p>

            {this.state.completed && (
              <Button
                type="primary"
                onClick={() => {
                  this.setState({
                    completedModalVisible: true,
                  });
                }}
              >
                Show Completed Popup
              </Button>
            )}

            {process.env.NODE_ENV === 'development' && (
              <div>
                <br />
                <Button.Group size="default">
                  <Button
                    type="primary"
                    onClick={() => {
                      const lastPuzzleIndex = PUZZLES.length - 1;
                      this.setState({
                        currentPuzzleIndex: lastPuzzleIndex,
                        unlockedPuzzleIndex: lastPuzzleIndex,
                        cssCode: PUZZLES[lastPuzzleIndex].solutionCSS,
                        completed: true,
                      });
                    }}
                  >
                    Complete
                  </Button>

                  <Button
                    type="danger"
                    onClick={() => {
                      localStorage.clear();
                      this.setState({
                        currentPuzzleIndex: 0,
                        unlockedPuzzleIndex: 0,
                        completed: false,
                        cssCode: PUZZLES[0].defaultCSS,
                        successVisible: false,
                        completedModalVisible: false,
                      });
                    }}
                  >
                    Reset
                  </Button>
                </Button.Group>
              </div>
            )}
          </Content>

          <List
            size="small"
            className="no-outside-border"
            bordered
            dataSource={PUZZLE_LIST}
            renderItem={(item: string, puzzleIndex: number) => {
              return (
                <div
                  className={classNames(
                    'ant-list-item',
                    'ant-list-item-clickable',
                    {
                      'ant-list-item-active':
                        puzzleIndex === this.state.currentPuzzleIndex,
                      'ant-list-item-disabled':
                        puzzleIndex > this.state.unlockedPuzzleIndex,
                    }
                  )}
                  onClick={() => {
                    if (puzzleIndex <= this.state.unlockedPuzzleIndex) {
                      this.changePuzzle(puzzleIndex);
                    }
                  }}
                >
                  <div className="ant-list-item-content ant-list-item-content-single">
                    {item}
                  </div>
                </div>
              );
            }}
          />
        </Sider>
        <Layout style={{ height: '100vh' }}>
          <Content
            style={{
              margin: cardStyle.margin,
              height: '100vh',
              display: 'flex',
              flexDirection: 'column',
            }}
          >
            <div style={{ display: 'flex', flexDirection: 'row', flex: 1 }}>
              <div
                style={{ display: 'flex', flexDirection: 'column', flex: 1 }}
              >
                <Card
                  className="ant-card-small ant-card-overflow"
                  title={this.cardTitle('HTML', <Icon type="html5" />)}
                  bordered={true}
                  style={{ ...cardStyle, flex: 1 }}
                >
                  <div className="static-code-wrapper overflow-wrapper">
                    {this.highlightedHTMLSelector(this.state)}
                  </div>
                </Card>

                <Card
                  className="ant-card-small ant-card-overflow"
                  title={this.cardTitle('CSS', <Icon type="code" />)}
                  extra={
                    <Button
                      size="small"
                      onClick={() => {
                        this.setState({
                          cssCode:
                            PUZZLES[this.state.currentPuzzleIndex].defaultCSS,
                        });
                      }}
                    >
                      Reset
                    </Button>
                  }
                  bordered={true}
                  // Padding aligns the margins
                  style={{ ...cardStyle, flex: 2, paddingBottom: '12px' }}
                >
                  <div className="overflow-wrapper">
                    <Editor
                      value={this.state.cssCode}
                      onValueChange={cssCode => this.setState({ cssCode })}
                      highlight={cssCode => highlight(cssCode, languages.css)}
                      padding={18}
                      style={{
                        fontFamily: '"Fira Mono", monospace',
                        fontSize: 12,
                      }}
                    />
                  </div>

                  {this.state.diffPercentage === 100 &&
                    this.state.successVisible && (
                      <div className="solved-message">
                        <Alert
                          message="Puzzle Solved"
                          description={
                            <div>
                              <p>
                                Nice work, you've completed Puzzle{' '}
                                {this.state.currentPuzzleIndex}!
                              </p>
                              {this.state.currentPuzzleIndex <
                                PUZZLES.length - 1 && (
                                <Button
                                  type="primary"
                                  size="small"
                                  className="next-button"
                                  onClick={() => {
                                    const nextPuzzleIndex =
                                      this.state.currentPuzzleIndex + 1;
                                    this.changePuzzle(nextPuzzleIndex);
                                  }}
                                >
                                  Next Puzzle <Icon type="right" />
                                </Button>
                              )}
                            </div>
                          }
                          type="success"
                          closable
                          afterClose={() => {
                            this.setState({ successVisible: false });
                          }}
                          showIcon
                        />
                      </div>
                    )}
                </Card>
              </div>
              <div
                style={{ display: 'flex', flexDirection: 'column', flex: 1 }}
              >
                <Card
                  className="ant-card-small ant-card-overflow"
                  title={this.cardTitle('Target', <TargetIcon />)}
                  bordered={true}
                  style={cardStyle}
                >
                  <div className="overflow-wrapper canvas-wrapper">
                    <canvas
                      className="render"
                      ref={ref => {
                        this.targetCanvas = ref;
                      }}
                    />
                  </div>
                </Card>
                <Card
                  className="ant-card-small ant-card-overflow"
                  title={this.cardTitle('Result', <ResultIcon />)}
                  bordered={true}
                  style={cardStyle}
                >
                  <div className="overflow-wrapper canvas-wrapper">
                    <canvas
                      className="render"
                      ref={ref => {
                        this.resultCanvas = ref;
                      }}
                    />
                  </div>
                </Card>
                <Card
                  className="ant-card-small ant-card-overflow difference"
                  title={this.cardTitle(
                    'Difference',

                    <DiffIcon />
                  )}
                  extra={
                    <Progress
                      percent={this.state.diffPercentage}
                      size="small"
                      format={percent => {
                        if (percent == null) return '-';
                        if (percent === 100) {
                          return <Icon type="check-circle" theme="filled" />;
                        }
                        if (this.state.diffPixels < 1000) {
                          return `${this.state.diffPixels}px`;
                        }
                        return `${percent.toFixed(1)}%`;
                      }}
                    />
                  }
                  bordered={true}
                  style={cardStyle}
                >
                  <div className="overflow-wrapper canvas-wrapper">
                    <canvas
                      className="render"
                      ref={ref => {
                        this.diffCanvas = ref;
                      }}
                    />
                  </div>
                </Card>
              </div>
            </div>

            <Modal
              title="Congratulations, you've completed the first stage!"
              visible={
                this.state.completed &&
                this.state.completedModalVisible &&
                this.decryptedData != null
              }
              footer={null}
              onCancel={() => {
                this.setState({ completedModalVisible: false });
              }}
            >
              {this.state.completed && this.decryptedData ? (
                <div>
                  <p>
                    Here's the first private key for an address that contains{' '}
                    <strong>0.005 BTC</strong>:
                  </p>
                  <code>{this.decryptedData[0]}</code>
                  <br />
                  <br />
                  <p>Are you ready for a real programming challenging?</p>
                  <p>
                    <a href={this.decryptedData[1]}>Here's Stage 2.</a>
                  </p>
                  <p></p>
                </div>
              ) : null}
            </Modal>
          </Content>
        </Layout>
      </Layout>
    );
  }
}

export default App;
