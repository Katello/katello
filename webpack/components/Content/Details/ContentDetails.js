import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Nav, NavItem, TabPane, TabContent, TabContainer, Grid, Row, Col } from 'patternfly-react';
import { PropTypes } from 'prop-types';
import { LoadingState } from '../../../components/LoadingState/index';

const ContentDetails = (props) => {
  const { contentDetails, schema } = props;
  const { loading } = contentDetails;

  const tabHeaders = () => {
    const tabs = schema.map(node => (
      <NavItem key={node.key} eventKey={node.key} ouiaId={`${node.key}-nav-item`}>
        <div>{node.tabHeader}</div>
      </NavItem>
    ));
    return tabs;
  };

  const tabPanes = () => {
    const tabPane = schema.map(node => (
      <TabPane key={node.key} eventKey={node.key}>
        <Row>
          <Col sm={12}>
            {node.tabContent}
          </Col>
        </Row>
      </TabPane>
    ));
    return tabPane;
  };

  return (
    <div>
      <LoadingState
        loading={loading}
        loadingText={__('Loading')}
      >
        <TabContainer id="content-tabs-container" defaultActiveKey={1} style={{ margin: '0', padding: '0' }}>
          <Grid>
            <Row>
              <Col sm={12}>
                <Nav id="content-nav-container" bsClass="nav nav-tabs" ouiaId="content-details-nav">
                  {schema && tabHeaders()}
                </Nav>
              </Col>
            </Row>
            <TabContent animation={false} ouiaId="content-details-tab-content">
              {schema && tabPanes()}
            </TabContent>
          </Grid>
        </TabContainer>
      </LoadingState>
    </div>
  );
};

ContentDetails.propTypes = {
  contentDetails: PropTypes.shape({
    loading: PropTypes.bool,
    name: PropTypes.string,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    /* eslint-disable react/forbid-prop-types */
    profiles: PropTypes.array,
    repositories: PropTypes.array,
    artifacts: PropTypes.array,
    /* eslint-enable react/forbid-prop-types */
    stream: PropTypes.string,
  }).isRequired,
  schema: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};

export default ContentDetails;
