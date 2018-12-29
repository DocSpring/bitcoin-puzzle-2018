import React, { Component } from 'react';
import logo from './logo.svg';

import { Layout, Menu, Breadcrumb, Icon, Card } from 'antd';
import { Row, Col } from 'antd';
import { List } from 'antd';
import { ReactComponent as TargetIcon } from './icons/target.svg';
import { ReactComponent as ResultIcon } from './icons/magnifying-glass.svg';
import { ReactComponent as DiffIcon } from './icons/diff.svg';

const data: string[] = Array<string>(10)
  .fill('')
  .map((_, i) => `Puzzle ${i + 1}`);

const { Header, Content, Footer, Sider } = Layout;
const SubMenu = Menu.SubMenu;

import './style/AntDesign/index.less';

class App extends Component {
  state = {
    collapsed: false,
  };

  onCollapse = (collapsed: Boolean) => {
    const b = <div />;
    console.log(collapsed);
    this.setState({ collapsed });
  };

  cardTitle(label: string, icon?: JSX.Element, rightIconType?: string) {
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

  testFunction() {
    return <div />;
  }

  render() {
    const cardStyle = { flex: 1, margin: '5px' };

    return (
      <Layout style={{ minHeight: '100vh' }}>
        <Sider width={240} style={{ background: '#fff' }}>
          <Content style={{ padding: '21px' }}>
            <h2>PixelPerfect</h2>
            <p>
              Write some HTML and CSS that matches the target image. The puzzle
              isn't solved until your CSS is 100% pixel perfect.
            </p>
            <p>
              (<a href="https://stackoverflow.com/">You might need this</a>.)
            </p>
          </Content>

          <List
            size="small"
            bordered
            dataSource={data}
            renderItem={(item: String) => <List.Item>{item}</List.Item>}
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
                  className="ant-card-small"
                  title={this.cardTitle('HTML', <Icon type="html5" />)}
                  bordered={true}
                  style={{ flex: 1, margin: '5px' }}
                >
                  <p>HTML Code</p>
                </Card>

                <Card
                  className="ant-card-small"
                  title={this.cardTitle('CSS', <Icon type="code" />)}
                  bordered={true}
                  style={cardStyle}
                >
                  <p>Card editor</p>
                </Card>
              </div>
              <div
                style={{ display: 'flex', flexDirection: 'column', flex: 1 }}
              >
                <Card
                  className="ant-card-small"
                  title={this.cardTitle('Target', <TargetIcon />)}
                  bordered={true}
                  style={cardStyle}
                >
                  <p>Card editor</p>
                </Card>
                <Card
                  className="ant-card-small"
                  title={this.cardTitle('Result', <ResultIcon />)}
                  bordered={true}
                  style={cardStyle}
                >
                  <p>Card editor</p>
                </Card>
                <Card
                  className="ant-card-small"
                  title={this.cardTitle('Difference', <DiffIcon />)}
                  bordered={true}
                  style={cardStyle}
                >
                  <p>Card editor</p>
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
