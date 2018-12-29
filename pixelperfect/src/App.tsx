import React, { Component } from 'react';
import { createSelector } from 'reselect';
import classNames from 'classnames';
import $ from 'jquery';
import { debounce } from 'lodash-es';

import html2canvas from 'html2canvas';
import pixelmatch from 'pixelmatch';

import {
  Button,
  Layout,
  Menu,
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
import { number } from 'prop-types';

const PUZZLE_LIST: string[] = PUZZLES.map((_, i) => `Puzzle ${i}`);

type State = {
  collapsed: boolean;
  currentPuzzleIndex: number;
  unlockedPuzzleIndex: number;
  cssCode: string;
  diffPixels: number;
  diffPercentage: number;
  successVisible: boolean;
};

const DEBUG = process.env.NODE_ENV === 'development';
const log = process.env.NODE_ENV === 'development' ? console.log : () => {};

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

class App extends Component {
  targetCanvas: HTMLCanvasElement | null = null;
  resultCanvas: HTMLCanvasElement | null = null;
  diffCanvas: HTMLCanvasElement | null = null;

  targetImageSelector: (state: State) => ImageData | null;
  resultImageSelector: (state: State) => ImageData | null;
  diffPixelsFormattedSelector: (state: State) => string;

  renderCSSTimeout: number | undefined;
  cancelCurrentCSSRender: Function | undefined;

  state: State = {
    collapsed: false,
    currentPuzzleIndex: 0,
    unlockedPuzzleIndex: 0,
    cssCode: PUZZLES[0].defaultCSS,
    diffPixels: 0,
    diffPercentage: 0,
    successVisible: false,
  };

  constructor(props: any) {
    super(props);

    // Load the previous puzzle index from localStorage
    const unlockedPuzzleIndex = parseInt(
      localStorage.getItem('unlockedPuzzleIndex') || '0',
      10
    );
    this.state.currentPuzzleIndex = unlockedPuzzleIndex;
    this.state.unlockedPuzzleIndex = unlockedPuzzleIndex;

    this.targetImageSelector = createSelector(
      (state: State) => state.currentPuzzleIndex,
      () => {
        const canvas = this.targetCanvas;
        const context = canvas && canvas.getContext('2d');
        if (!canvas || !context) return null;
        return context.getImageData(0, 0, canvas.width, canvas.height);
      }
    );

    this.resultImageSelector = createSelector(
      (state: State) => state.currentPuzzleIndex,
      (state: State) => state.cssCode,
      () => {
        const canvas = this.resultCanvas;
        const targetCanvas = this.targetCanvas;
        const context = canvas && canvas.getContext('2d');
        if (!targetCanvas || !canvas || !context) return null;
        // Must use the target canvas size (and just crop anything else)
        return context.getImageData(
          0,
          0,
          targetCanvas.width,
          targetCanvas.height
        );
      }
    );

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
    const solutionCSS = PUZZLES[this.state.currentPuzzleIndex].solutionCSS;
    this.renderCSSToTargetCanvas(solutionCSS)
      .then(() => this.renderCSSToResultCanvas(this.state.cssCode))
      .then(() => this.updateImageDiff());
  }

  componentDidUpdate(prevProps: any, prevState: State) {
    if (this.state.currentPuzzleIndex !== prevState.currentPuzzleIndex) {
      // Set default CSS for new puzzle
      this.setState({
        cssCode: PUZZLES[this.state.currentPuzzleIndex].defaultCSS,
      });
      // Render changes immediately when changing the puzzle
      this.checkForCSSUpdates(prevState);
    } else {
      // Update after a delay when editing CSS
      this.checkForCSSUpdatesDebounced(prevState);
    }

    if (this.state.diffPercentage === 100 && prevState.diffPercentage !== 100) {
      // The current puzzle was just solved.
      // Unlock the next puzzle (if not already unlocked.)
      const unlockedPuzzleIndex = Math.max(
        this.state.currentPuzzleIndex + 1,
        this.state.unlockedPuzzleIndex
      );
      // Update the saved state in localStorage
      localStorage.setItem(
        'unlockedPuzzleIndex',
        unlockedPuzzleIndex.toString()
      );
      let successVisible = this.state.successVisible;
      if (unlockedPuzzleIndex > this.state.unlockedPuzzleIndex) {
        // Always show the success message when we've unlocked a new puzzle.
        // (Otherwise, don't keep showing it if the player wants to adjust the CSS.)
        successVisible = true;
      }

      this.setState({ successVisible, unlockedPuzzleIndex });
    }

    // Sanity check to make sure we never show any unlocked puzzles,
    // even if we have a bug somewhere else.
    if (this.state.currentPuzzleIndex > this.state.unlockedPuzzleIndex) {
      this.setState({
        currentPuzzleIndex: this.state.unlockedPuzzleIndex,
      });
    }
  }

  checkForCSSUpdates(prevState: State) {
    if (this.cancelCurrentCSSRender) {
      log('Cancelling current render...');
      this.cancelCurrentCSSRender();
      this.cancelCurrentCSSRender = undefined;
    }

    let promise = Promise.resolve();
    if (this.state.currentPuzzleIndex !== prevState.currentPuzzleIndex) {
      const solutionCSS = PUZZLES[this.state.currentPuzzleIndex].solutionCSS;
      promise = promise.then(() => this.renderCSSToTargetCanvas(solutionCSS));
    }
    if (this.state.cssCode !== prevState.cssCode) {
      promise = promise.then(() =>
        // This also updates the image diff.
        this.renderCSSToResultCanvas(this.state.cssCode)
      );
    }
    return promise;
  }
  checkForCSSUpdatesDebounced = debounce(this.checkForCSSUpdates, 300);

  renderCSSToTargetCanvas(css: string) {
    log('Rendering target canvas...');

    return this.renderCSSToCanvas(css, this.targetCanvas).then(() => {
      // After updating the target canvas, we need to update the
      // diff canvas so that the width and height are equal
      // (And the same scale. DeviceRatio is handled by html2canvas)
      const targetCanvas = this.targetCanvas;
      const diffCanvas = this.diffCanvas;
      if (!targetCanvas || !diffCanvas) return;
      diffCanvas.width = targetCanvas.width;
      diffCanvas.height = targetCanvas.height;
      diffCanvas.style.width = targetCanvas.style.width;
      diffCanvas.style.height = targetCanvas.style.height;
    });
  }

  renderCSSToResultCanvas(css: string) {
    log('Rendering result canvas...');
    // Whenever we update the result canvas,
    // we also need to update the diff image.
    return this.renderCSSToCanvas(css, this.resultCanvas).then(() =>
      this.updateImageDiff()
    );
  }

  renderCSSToCanvas(css: string, canvas: HTMLCanvasElement | null) {
    return new Promise((resolve, reject) => {
      this.cancelCurrentCSSRender = () => {
        window.clearTimeout(this.renderCSSTimeout);
        reject();
      };

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
        left: '-9999px',
      });
      $('body').append($iframe);

      this.renderCSSTimeout = window.setTimeout(() => {
        var iframedoc =
          iframe.contentDocument ||
          (iframe.contentWindow && iframe.contentWindow.document);
        if (!iframedoc) {
          reject(new Error('Sorry, your browser is not supported!'));
          return;
        }
        $('body', $(iframedoc)).html(renderHTML);
        html2canvas(iframedoc.body, { canvas }).then(() => {
          $iframe.remove();
          resolve();
          this.cancelCurrentCSSRender = undefined;
        });
      }, 10);
    });
  }

  updateImageDiff() {
    log('Rendering image diff...');
    const targetImage = this.targetImageSelector(this.state);
    const resultImage = this.resultImageSelector(this.state);
    if (!targetImage || !resultImage) return;

    const diffContext = this.diffCanvas && this.diffCanvas.getContext('2d');
    if (!this.targetCanvas || !this.diffCanvas || !diffContext) return;

    const { width, height } = this.targetCanvas;

    const diffImage = diffContext.createImageData(width, height);
    let diffPixels = pixelmatch(
      resultImage.data,
      targetImage.data,
      diffImage.data,
      width,
      height,
      {
        threshold: 0.005,
      }
    );
    diffContext.clearRect(0, 0, width, height);
    diffContext.putImageData(diffImage, 0, 0);

    // Calculate the bounds of the diff image,
    // and use this to calculate the diff percentage.
    // From: https://stackoverflow.com/a/22267731/304706
    // ImageData is an array of R,G,B,A bytes.
    // See: https://www.w3schools.com/tags/canvas_imagedata_data.asp
    let x, y, index;
    const pixels: { x: number[]; y: number[] } = { x: [], y: [] };

    // debugger;
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
                    // Don't allow any unlocked puzzles
                    if (puzzleIndex > this.state.unlockedPuzzleIndex) return;
                    this.setState({
                      currentPuzzleIndex: puzzleIndex,
                    });
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
                  style={cardStyle}
                >
                  <div className="static-code-wrapper overflow-wrapper">
                    {this.highlightedHTMLSelector(this.state)}
                  </div>
                </Card>

                <Card
                  className="ant-card-small ant-card-overflow"
                  title={this.cardTitle('CSS', <Icon type="code" />)}
                  extra={
                    <a
                      href="#"
                      onClick={() => {
                        this.setState({
                          cssCode:
                            PUZZLES[this.state.currentPuzzleIndex].defaultCSS,
                        });
                      }}
                    >
                      Reset
                    </a>
                  }
                  bordered={true}
                  style={cardStyle}
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
                          message="Puzzle Solved!"
                          description={
                            <div>
                              <p>
                                Nice work, you've completed Puzzle{' '}
                                {this.state.currentPuzzleIndex}!
                              </p>
                              <Button
                                type="primary"
                                className="next-button"
                                onClick={() => {
                                  const nextPuzzleIndex =
                                    this.state.currentPuzzleIndex + 1;

                                  if (
                                    nextPuzzleIndex >
                                    this.state.unlockedPuzzleIndex
                                  ) {
                                    notification.open({
                                      message: 'Whoops, something went wrong!',
                                      description: `You don't have access to Puzzle ${nextPuzzleIndex}!`,
                                    });
                                  }
                                  this.setState({
                                    currentPuzzleIndex: nextPuzzleIndex,
                                  });
                                }}
                              >
                                Next Puzzle <Icon type="right" />
                              </Button>
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
                  <div className="overflow-wrapper">
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
                  title={this.cardTitle('Render', <ResultIcon />)}
                  bordered={true}
                  style={cardStyle}
                >
                  <div className="overflow-wrapper">
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
                  <div className="overflow-wrapper">
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
          </Content>
        </Layout>
      </Layout>
    );
  }
}

export default App;
