import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Grid, Row, Col } from 'patternfly-react';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import SubscriptionDetailInfo from './SubscriptionDetailInfo';
import SubscriptionDetailAssociations from './SubscriptionDetailAssociations';
import SubscriptionDetailProducts from './SubscriptionDetailProducts';
import { LoadingState } from '../../../move_to_pf/LoadingState';
import { notify } from '../../../move_to_foreman/foreman_toast_notifications';
import api from '../../../services/api';

class SubscriptionDetails extends Component {
  constructor() {
    super();
    this.handleBreadcrumbSwitcherItem = this.handleBreadcrumbSwitcherItem.bind(this);
  }
  componentDidMount() {
    // eslint-disable-next-line react/prop-types
    const routerParams = this.props.match.params;
    this.props.loadSubscriptionDetails(parseInt(routerParams.id, 10));
  }

  componentDidUpdate(prevProps) {
    const routerParams = this.props.match.params;
    if (routerParams.id !== prevProps.match.params.id) {
      this.props.loadSubscriptionDetails(parseInt(routerParams.id, 10));
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
      resourceUrl: api.getApiUrl('/subscriptions'),
      switcherItemUrl: '/subscriptions/:id',
    };

    if (subscriptionDetails.error) {
      notify({ message: subscriptionDetails.error });
    }

    return (
      <Grid bsClass="container-fluid">
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
        <div>
          <LoadingState loading={subscriptionDetails.loading} loadingText={__('Loading')}>
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
          </LoadingState>
        </div>
      </Grid>
    );
  }
}

SubscriptionDetails.propTypes = {
  loadSubscriptionDetails: PropTypes.func.isRequired,
  subscriptionDetails: PropTypes.shape({}).isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
};

export default SubscriptionDetails;
