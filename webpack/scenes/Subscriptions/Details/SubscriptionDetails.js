import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Spinner, Grid, Row, Col } from 'patternfly-react';
import SubscriptionDetailInfo from './SubscriptionDetailInfo';
import SubscriptionDetailAssociations from './SubscriptionDetailAssociations';
import SubscriptionDetailProducts from './SubscriptionDetailProducts';
import { notify } from '../../../move_to_foreman/foreman_toast_notifications';

class SubscriptionDetails extends Component {
  componentDidMount() {
    // eslint-disable-next-line react/prop-types
    const routerParams = this.props.match.params;
    this.props.loadSubscriptionDetails(parseInt(routerParams.id, 10));
  }

  render() {
    const { subscriptionDetails } = this.props;

    if (subscriptionDetails.error) { notify({ message: subscriptionDetails.error }); }

    return (
      <Grid bsClass="container-fluid">
        <div>
          <Spinner loading={subscriptionDetails.loading}>
            <Row>
              <Col sm={12}>
                <h1>{subscriptionDetails.name}</h1>
              </Col>
            </Row>
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
          </Spinner>
        </div>
      </Grid>
    );
  }
}

SubscriptionDetails.propTypes = {
  loadSubscriptionDetails: PropTypes.func.isRequired,
  subscriptionDetails: PropTypes.shape({}).isRequired,
};

export default SubscriptionDetails;
