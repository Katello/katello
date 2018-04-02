import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { LinkContainer } from 'react-router-bootstrap';
import { Grid, Row, Col } from 'react-bootstrap';
import { Button, Spinner } from 'patternfly-react';
import Table from '../../../move_to_foreman/components/common/table';
import PaginationRow from '../../../components/PaginationRow/index';
import { columns } from './UpstreamSubscriptionsTableSchema';

class UpstreamSubscriptionsPage extends Component {
  componentDidMount() {
    this.loadData();
  }

  loadData() {
    this.props.loadUpstreamSubscriptions();
  }

  render() {
    const { upstreamSubscriptions } = this.props;

    const onPaginationChange = (pagination) => {
      this.props.loadUpstreamSubscriptions({
        ...pagination,
      });
    };

    const emptyStateData = () => ({
      header: __('There are no Subscription Allocations to display'),
      description: __('Subscription Allocations allow you to export subscriptions from the Red Hat Customer Portal to ' +
          'an on-premise subscription management application such as Red Hat Satellite.'),
      docUrl: 'http://redhat.com',
      documentation: {
        title: __('Learn more about Subscription Allocations'),
        url: 'http://redhat.com',
      },
      action: {
        title: __('New Subscription Allocation'),
        url: 'http://redhat.com',
      },
    });

    return (
      <Grid bsClass="container-fluid">
        <h1>{__('Add Subscriptions')}</h1>

        <Row>
          <Col sm={12}>
            <Spinner loading={upstreamSubscriptions.loading} className="small-spacer">
              <Table
                rows={upstreamSubscriptions.results}
                columns={columns}
                emptyState={emptyStateData()}
              />
              <PaginationRow
                viewType="table"
                itemCount={upstreamSubscriptions.pagination.total}
                pagination={upstreamSubscriptions.pagination}
                onChange={onPaginationChange}
              />
            </Spinner>
          </Col>
        </Row>

        <Row>
          <Col sm={12}>
            <Button bsStyle="primary">
              {__('Submit')}
            </Button>

            <LinkContainer to="/xui/subscriptions">
              <Button>
                {__('Cancel')}
              </Button>
            </LinkContainer>
          </Col>
        </Row>
      </Grid>
    );
  }
}

UpstreamSubscriptionsPage.propTypes = {
  loadUpstreamSubscriptions: PropTypes.func.isRequired,
  upstreamSubscriptions: PropTypes.shape({}).isRequired,
};

export default UpstreamSubscriptionsPage;
