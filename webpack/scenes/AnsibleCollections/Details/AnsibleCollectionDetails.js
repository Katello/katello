import React, { Component } from 'react';
import { Nav, NavItem, TabPane, TabContent, TabContainer, Grid, Row, Col } from 'patternfly-react';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import { PropTypes } from 'prop-types';
import { LoadingState } from '../../../move_to_pf/LoadingState';
import api from '../../../services/api';
import AnsibleCollectionDetailsInfo from './AnsibleCollectionDetailsInfo';
import AnsibleCollectionDetailRepositories from '../../ModuleStreams/Details/Repositories/ModuleStreamDetailRepositories';

class AnsibleCollectionDetails extends Component {
  componentDidMount() {
    this.updateAnsibleCollection();
  }

  componentDidUpdate(prevProps) {
    const { match: { params: prevRouterParams } } = this.props;
    const { match: { params: currentRouterParams } } = prevProps;
    if (prevRouterParams.id && (prevRouterParams.id !== currentRouterParams.id)) {
      this.updateAnsibleCollection();
    }
  }

  updateAnsibleCollection = () => {
    const ansibleCollectionId = parseInt(this.props.match.params.id, 10);
    this.props.getAnsibleCollectionDetails(ansibleCollectionId);
  };

  handleBreadcrumbSwitcherItem = (e, url) => {
    this.props.history.push(url);
    e.preventDefault();
  };

  render() {
    const { ansibleCollectionDetails } = this.props;
    const {
      loading, name, namespace, version, repositories,
    } = ansibleCollectionDetails;

    const resource = {
      nameField: 'name',
      resourceUrl: api.getApiUrl('/ansible_collections'),
      switcherItemUrl: '/ansible_collections/:id',
    };

    return (
      <div>
        {!loading && <BreadcrumbsBar
          onSwitcherItemClick={(e, url) => this.handleBreadcrumbSwitcherItem(e, url)}
          data={{
            isSwitchable: true,
            breadcrumbItems: [
              {
                caption: __('Ansible Collection Details'),
                onClick: () =>
                  this.props.history.push('/ansible_collections'),
              },
              {
                caption: `${name}-${namespace}-${version}`,
              },
            ],
            resource,
          }}
        />}

        <LoadingState
          loading={loading}
          loadingText={__('Loading')}
        >
          <TabContainer id="ansible-collections-tabs-container" defaultActiveKey={1}>
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
                  </Nav>
                </Col>
              </Row>
              <TabContent animation={false}>
                <TabPane eventKey={1}>
                  <Row>
                    <Col sm={12}>
                      {/* eslint-disable-next-line max-len */}
                      <AnsibleCollectionDetailsInfo ansibleCollectionDetails={ansibleCollectionDetails} />
                    </Col>
                  </Row>
                </TabPane>
                <TabPane eventKey={2}>
                  <Row>
                    <Col sm={12}>
                      {repositories && repositories.length ?
                        <AnsibleCollectionDetailRepositories repositories={repositories} /> :
                        __('No repositories to show')}
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

AnsibleCollectionDetails.propTypes = {
  getAnsibleCollectionDetails: PropTypes.func.isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
  location: PropTypes.shape({}).isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
  ansibleCollectionDetails: PropTypes.shape({
    loading: PropTypes.bool,
    name: PropTypes.string,
    namespace: PropTypes.string,
    version: PropTypes.string,
    repositories: PropTypes.array,
  }).isRequired,
};

export default AnsibleCollectionDetails;
