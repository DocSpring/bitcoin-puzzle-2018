import React, { Component } from 'react';
import { createSelector } from 'reselect';
import classNames from 'classnames';
import $ from 'jquery';
import { debounce } from 'lodash-es';

import html2canvas from 'html2canvas';
import pixelmatch from 'pixelmatch';

import { Layout, Menu, Breadcrumb, Icon, Card } from 'antd';
import { List, Progress } from 'antd';
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
  puzzleIndex: number;
  cssCode: string;
  diffPixels: number;
  diffPercentage: number;
};

class App extends Component {
  targetCanvas: HTMLCanvasElement | null = null;
  resultCanvas: HTMLCanvasElement | null = null;
  diffCanvas: HTMLCanvasElement | null = null;

  targetImageSelector: (state: State) => ImageData | null;
  resultImageSelector: (state: State) => ImageData | null;
  diffPixelsFormattedSelector: (state: State) => string;

  state: State = {
    collapsed: false,
    puzzleIndex: 0,
    cssCode: PUZZLES[0].defaultCSS,
    diffPixels: 0,
    diffPercentage: 0,
  };

  constructor(props: any) {
    super(props);

    this.checkForCSSUpdates = debounce(this.checkForCSSUpdates, 300);

    this.targetImageSelector = createSelector(
      (state: State) => state.puzzleIndex,
      () => {
        const canvas = this.targetCanvas;
        const context = canvas && canvas.getContext('2d');
        if (!canvas || !context) return null;
        return context.getImageData(0, 0, canvas.width, canvas.height);
      }
    );

    this.resultImageSelector = createSelector(
      (state: State) => state.puzzleIndex,
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

    const targetPixelCountSelector = createSelector(
      () => this.targetCanvas == null,
      (state: State) => state.puzzleIndex,
      () => {
        const canvas = this.targetCanvas;
        const context = canvas && canvas.getContext('2d');
        if (!canvas || !context) return null;
        return canvas.width * canvas.height;
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
    const solutionCSS = PUZZLES[this.state.puzzleIndex].solutionCSS;
    this.renderCSSToTargetCanvas(solutionCSS)
      .then(() => this.renderCSSToResultCanvas(this.state.cssCode))
      .then(() => this.updateImageDiff());
  }

  componentDidUpdate(prevProps: any, prevState: State) {
    this.checkForCSSUpdates(prevState);
  }

  checkForCSSUpdates(prevState: State) {
    const promises = [];
    if (this.state.cssCode !== prevState.cssCode) {
      promises.push(this.renderCSSToResultCanvas(this.state.cssCode));
    }

    if (this.state.puzzleIndex !== prevState.puzzleIndex) {
      const solutionCSS = PUZZLES[this.state.puzzleIndex].solutionCSS;
      promises.push(this.renderCSSToTargetCanvas(solutionCSS));
    }

    if (promises.length === 0) return;

    Promise.all(promises).then(() => {
      this.updateImageDiff();
    });
  }

  renderCSSToTargetCanvas(css: string) {
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
    // Whenever we update the result canvas,
    // we also need to update the diff image.
    return this.renderCSSToCanvas(css, this.resultCanvas).then(() =>
      this.updateImageDiff()
    );
  }

  renderCSSToCanvas(css: string, canvas: HTMLCanvasElement | null) {
    return new Promise((resolve, reject) => {
      if (!canvas) {
        reject();
        return;
      }
      const puzzleHTML = PUZZLES[this.state.puzzleIndex].html;
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
      setTimeout(() => {
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
        });
      }, 10);
    });
  }

  updateImageDiff() {
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

    console.log({ diffPixels, diffTotalPixels, diffPercentage });

    if (window.devicePixelRatio === 2) {
      diffPixels = diffPixels / 4;
    }

    this.setState({
      diffPercentage,
      diffPixels,
    });
  }

  onCollapse = (collapsed: Boolean) => {
    const b = <div />;
    console.log(collapsed);
    this.setState({ collapsed });
  };

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
              Write some CSS that produces the target image. The puzzle is
              solved when your CSS is 100% pixel perfect.
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
            renderItem={(item: string, i: number) => {
              return (
                <div
                  className={classNames(
                    'ant-list-item',
                    'ant-list-item-clickable',
                    {
                      'ant-list-item-disabled': i > this.state.puzzleIndex,
                    }
                  )}
                  onClick={() => {
                    console.log('clicked');
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
                    <Highlight
                      {...prismDefaultProps}
                      code={PUZZLES[0].html}
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
                          cssCode: PUZZLES[this.state.puzzleIndex].defaultCSS,
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
