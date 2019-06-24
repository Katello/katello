import React, { Component } from 'react';
import { Nav, NavItem, TabPane, TabContent, TabContainer, Grid, Row, Col } from 'patternfly-react';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import { PropTypes } from 'prop-types';
import { LoadingState } from '../../../move_to_pf/LoadingState';
import api from '../../../services/api';
import ModuleStreamDetailInfo from './ModuleStreamDetailInfo';
import ModuleStreamDetailRepositories from './Repositories/ModuleStreamDetailRepositories';
import ModuleStreamDetailArtifacts from './ModuleStreamDetailArtifacts';
import ModuleStreamDetailProfiles from './Profiles/ModuleStreamDetailProfiles';

class ModuleStreamDetails extends Component {
  componentDidMount() {
    this.updateModuleStream();
  }

  componentDidUpdate(prevProps) {
    const { match: { params: prevRouterParams } } = this.props;
    const { match: { params: currentRouterParams } } = prevProps;
    if (prevRouterParams.id && (prevRouterParams.id !== currentRouterParams.id)) {
      this.updateModuleStream();
    }
  }

  updateModuleStream = () => {
    const moduleStreamId = parseInt(this.props.match.params.id, 10);
    this.props.loadModuleStreamDetails(moduleStreamId);
  };

  handleBreadcrumbSwitcherItem = (e, url) => {
    this.props.history.push(url);
    e.preventDefault();
  };

  render() {
    const { moduleStreamDetails } = this.props;
    const {
      loading, name, stream, profiles, repositories, artifacts,
    } = moduleStreamDetails;

    const resource = {
      nameField: 'name',
      resourceUrl: api.getApiUrl('/module_streams'),
      switcherItemUrl: '/module_streams/:id',
    };

    return (
      <div>
        {!loading && <BreadcrumbsBar
          onSwitcherItemClick={(e, url) => this.handleBreadcrumbSwitcherItem(e, url)}
          data={{
            isSwitchable: true,
            breadcrumbItems: [
              {
                caption: __('Module Streams'),
                onClick: () =>
                  this.props.history.push('/module_streams'),
              },
              {
                caption: `${name} ${stream}`,
              },
            ],
            resource,
          }}
        />}

        <LoadingState
          loading={loading}
          loadingText={__('Loading')}
        >
          <TabContainer id="module-stream-tabs-container" defaultActiveKey={1}>
            <Grid bsClass="container-fluid">
              <Row>
                <Col sm={12}>
                  <Nav bsClass="nav nav-tabs">
                    <NavItem eventKey={1}>
                      <div>{__('Details')}</div>
                    </NavItem>
                    <NavItem eventKey={2}>
                      <div>{__('Repositories')}</div>
                    </NavItem>
                    <NavItem eventKey={3}>
                      <div>{__('Profiles')}</div>
                    </NavItem>
                    <NavItem eventKey={4}>
                      <div>{__('Artifacts')}</div>
                    </NavItem>
                  </Nav>
                </Col>
              </Row>
              <TabContent animation={false}>
                <TabPane eventKey={1}>
                  <Row>
                    <Col sm={12}>
                      <ModuleStreamDetailInfo moduleStreamDetails={moduleStreamDetails} />
                    </Col>
                  </Row>
                </TabPane>
                <TabPane eventKey={2}>
                  <Row>
                    <Col sm={12}>
                      {repositories && repositories.length ?
                        <ModuleStreamDetailRepositories repositories={repositories} /> :
                        __('No repositories to show')}
                    </Col>
                  </Row>
                </TabPane>
                <TabPane eventKey={3}>
                  <Row>
                    <Col sm={12}>
                      {profiles && profiles.length ?
                        <ModuleStreamDetailProfiles profiles={profiles} /> :
                        __('No profiles to show')}
                    </Col>
                  </Row>
                </TabPane>
                <TabPane eventKey={4}>
                  <Row>
                    <Col sm={12}>
                      {artifacts && artifacts.length ?
                        <ModuleStreamDetailArtifacts artifacts={artifacts} /> :
                        __('No artifacts to show')}
                    </Col>
                  </Row>
                </TabPane>
              </TabContent>
            </Grid>
          </TabContainer>
        </LoadingState>
      </div>
    );
  }
}

ModuleStreamDetails.propTypes = {
  loadModuleStreamDetails: PropTypes.func.isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
  location: PropTypes.shape({}).isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
  moduleStreamDetails: PropTypes.shape({
    loading: PropTypes.bool,
    name: PropTypes.string,
    profiles: PropTypes.array,
    repositories: PropTypes.array,
    artifacts: PropTypes.array,
    stream: PropTypes.string,
  }).isRequired,
};

export default ModuleStreamDetails;
