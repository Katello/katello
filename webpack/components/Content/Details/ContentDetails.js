import React from 'react';
import { Nav, NavItem, TabPane, TabContent, TabContainer, Grid, Row, Col } from 'patternfly-react';
import { PropTypes } from 'prop-types';
import { LoadingState } from '../../../move_to_pf/LoadingState/index';

const ContentDetails = props => {
  const { contentDetails, schema} = props;
  const {
    loading, repositories,
  } = contentDetails;

  const tabHeaders = () => {
    const tabs = schema.map((node, index) =>
      <NavItem eventKey={index+1}>
        <div>{node.tabHeader}</div>
      </NavItem>
    );
    return (
      tabs
    );
  };

  const tabPanes = () => {
    const tabPanes = schema.map((node, index) =>
      <TabPane eventKey={index+1}>
        <Row>
          <Col sm={12}>
            {node.tabContent}
          </Col>
        </Row>
      </TabPane>
    );
    return (
      tabPanes
    );
  };

  return (
    <div>
      <LoadingState
        loading={loading}
        loadingText={__('Loading')}
      >
        <TabContainer id="content-tabs-container" defaultActiveKey={1}>
          <Grid bsClass="container-fluid">
            <Row>
              <Col sm={12}>
                <Nav bsClass="nav nav-tabs">
                  {schema && tabHeaders()}
                </Nav>
              </Col>
            </Row>
            <TabContent animation={false}>
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
    profiles: PropTypes.array,
    repositories: PropTypes.array,
    artifacts: PropTypes.array,
    stream: PropTypes.string,
  }).isRequired,
};

export default ContentDetails;
