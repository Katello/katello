import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Nav, NavItem, TabPane, TabContent, TabContainer, Grid, Row, Col } from 'patternfly-react';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import SubscriptionDetailInfo from './SubscriptionDetailInfo';
import SubscriptionDetailAssociations from './SubscriptionDetailAssociations';
import SubscriptionDetailProducts from './SubscriptionDetailProducts';
import SubscriptionDetailProductContent from './SubscriptionDetailProductContent';
import { LoadingState } from '../../../move_to_pf/LoadingState';
import { notify } from '../../../move_to_foreman/foreman_toast_notifications';
import api, { orgId } from '../../../services/api';

class SubscriptionDetails extends Component {
  constructor() {
    super();
    this.handleBreadcrumbSwitcherItem = this.handleBreadcrumbSwitcherItem.bind(this);
  }
  componentDidMount() {
    // eslint-disable-next-line react/prop-types
    const routerParams = this.props.match.params;
    this.props.loadSubscriptionDetails(parseInt(routerParams.id, 10));
    this.props.loadProducts({
      subscription_id: parseInt(routerParams.id, 10),
      include_available_content: true,
      enabled: true,
    });
  }

  componentDidUpdate(prevProps) {
    const routerParams = this.props.match.params;
    if (routerParams.id !== prevProps.match.params.id) {
      this.props.loadSubscriptionDetails(parseInt(routerParams.id, 10));
      this.props.loadProducts({
        subscription_id: parseInt(routerParams.id, 10),
        include_available_content: true,
        enabled: true,
      });
    }
  }

  handleBreadcrumbSwitcherItem(e, url) {
    this.props.history.push(url);
    e.preventDefault();
  }

  render() {
    const { subscriptionDetails } = this.props;


    const resource = {
      nameField: 'name',
      resourceUrl: api.getApiUrl(`/organizations/${orgId()}/subscriptions`),
      switcherItemUrl: '/subscriptions/:id',
    };

    if (subscriptionDetails.error) {
      notify({ message: subscriptionDetails.error });
    }

    return (
      <div>
        {!subscriptionDetails.loading && <BreadcrumbsBar
          onSwitcherItemClick={(e, url) => this.handleBreadcrumbSwitcherItem(e, url)}
          data={{
            isSwitchable: true,
            breadcrumbItems: [
              {
                caption: __('Subscriptions'),
                onClick: () =>
                  this.props.history.push('/subscriptions'),
              },
              {
                caption: String(subscriptionDetails.name),
              },
            ],
            resource,
          }}
        />}

        <TabContainer id="subscription-tabs-container" defaultActiveKey={1}>
          <div>
            <LoadingState loading={subscriptionDetails.loading} loadingText={__('Loading')}>
              <Nav bsClass="nav nav-tabs">
                <NavItem eventKey={1}>
                  <div>{__('Details')}</div>
                </NavItem>
                <NavItem eventKey={2}>
                  <div>{__('Product Content')}</div>
                </NavItem>
              </Nav>
              <Grid bsClass="container-fluid">
                <TabContent animation={false}>
                  <TabPane eventKey={1}>
                    <div>
                      <Row>
                        <Col sm={6}>
                          <SubscriptionDetailInfo
                            subscriptionDetails={subscriptionDetails}
                          />
                        </Col>
                        <Col sm={6}>
                          <SubscriptionDetailAssociations
                            subscriptionDetails={subscriptionDetails}
                          />
                          <SubscriptionDetailProducts
                            subscriptionDetails={subscriptionDetails}
                          />
                        </Col>
                      </Row>
                    </div>
                  </TabPane>

                  <TabPane eventKey={2}>
                    <div>
                      <Row>
                        <Col sm={12}>
                          <SubscriptionDetailProductContent
                            productContent={subscriptionDetails.productContent}
                          />
                        </Col>
                      </Row>
                    </div>
                  </TabPane>
                </TabContent>
              </Grid>
            </LoadingState>
          </div>
        </TabContainer>
      </div>
    );
  }
}

SubscriptionDetails.propTypes = {
  loadSubscriptionDetails: PropTypes.func.isRequired,
  loadProducts: PropTypes.func.isRequired,
  subscriptionDetails: PropTypes.shape({
    error: PropTypes.shape({}),
    loading: PropTypes.bool,
    name: PropTypes.string,
    productContent: PropTypes.shape({}),
  }).isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
};

export default SubscriptionDetails;
