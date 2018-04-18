import React, { Component } from 'react';
import ReactDOMServer from 'react-dom/server';
import _ from 'lodash';
import PropTypes from 'prop-types';
import { LinkContainer } from 'react-router-bootstrap';
import { Grid, Row, Col } from 'react-bootstrap';
import { bindMethods, Button, Spinner } from 'patternfly-react';
import Table from '../../../move_to_foreman/components/common/table';
import { notify } from '../../../move_to_foreman/foreman_toast_notifications';
import helpers from '../../../move_to_foreman/common/helpers';
import PaginationRow from '../../../components/PaginationRow/index';
import { columns } from './UpstreamSubscriptionsTableSchema';

class UpstreamSubscriptionsPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      selectedRows: [],
    };

    bindMethods(this, [
      'onSelectAllRows',
      'onSelectRow',
      'onChange',
      'saveUpstreamSubscriptions',
    ]);
  }

  componentDidMount() {
    this.loadData();
  }

  onSelectAllRows(event) {
    const { checked } = event.target;
    const { upstreamSubscriptions } = this.props;

    if (checked) {
      this.setState({
        selectedRows: [...upstreamSubscriptions.results],
      });
    } else {
      this.setState({
        selectedRows: [],
      });
    }
  }

  onSelectRow(event, row) {
    const { selectedRows } = this.state;

    if (this.poolInSelectedRows(row)) {
      this.setState({
        selectedRows: selectedRows.filter(e => e.id !== row.id),
      });
    } else {
      selectedRows.push(row);
      this.setState({
        selectedRows,
      });
    }
  }

  onChange(value, rowData) {
    const { selectedRows } = this.state;
    const newValue = parseInt(value, 10);
    const pool = {
      ...rowData,
      id: rowData.pool_id,
      updatedQuantity: newValue,
      selected: true,
    };

    const match = this.poolInSelectedRows(pool);
    const index = _.indexOf(selectedRows, match);

    if (newValue > 0) {
      if (match) {
        selectedRows.splice(index, 1, pool);
      } else {
        selectedRows.push(pool);
      }
    } else if (match) {
      selectedRows.splice(index, 1);
    }

    this.setState({ selectedRows });
  }

  poolInSelectedRows(pool) {
    const { selectedRows } = this.state;

    return _.find(
      selectedRows,
      foundPool => pool.id === foundPool.id,
    );
  }

  saveUpstreamSubscriptions() {
    const updatedPools = _.map(
      this.state.selectedRows,
      pool => ({ ...pool, quantity: pool.updatedQuantity }),
    );

    const updatedSubscriptions = { pools: updatedPools };

    this.props.saveUpstreamSubscriptions(updatedSubscriptions).then(() => {
      const { task, error } = this.props.upstreamSubscriptions;

      // TODO: could probably factor this out into a task response component
      if (task) {
        const message = (
          <span>
            <span>{__('Subscriptions have been saved and are being updated. ')}</span>
            <a href={helpers.urlBuilder('foreman_tasks/tasks', '', task.id)}>
              {__('Click here to go to the tasks page for the task.')}
            </a>
          </span>
        );

        notify({ message: ReactDOMServer.renderToStaticMarkup(message), type: 'success' });
        this.props.history.push('/xui/subscriptions');
      } else {
        let errorMessages = [];

        if (error.errors) {
          errorMessages = error.errors;
        } else if (error.message) {
          errorMessages.push(error.message);
        }

        for (let i = 0; i < errorMessages.length; i += 1) {
          notify({ message: errorMessages[i], type: 'error' });
        }
      }
    });
  }

  loadData() {
    this.props.loadUpstreamSubscriptions();
  }

  render() {
    const { upstreamSubscriptions } = this.props;

    const getSubscriptionActions = () => {
      let actions = '';

      if (upstreamSubscriptions.results.length > 0) {
        actions = (
          <Row>
            <Col sm={12}>
              <Button
                bsStyle="primary"
                type="submit"
                disabled={upstreamSubscriptions.loading}
                onClick={this.saveUpstreamSubscriptions}
              >
                {__('Submit')}
              </Button>

              <LinkContainer to="/xui/subscriptions">
                <Button>
                  {__('Cancel')}
                </Button>
              </LinkContainer>
            </Col>
          </Row>
        );
      }

      return actions;
    };

    const onPaginationChange = (pagination) => {
      this.props.loadUpstreamSubscriptions({
        ...pagination,
      });
    };

    const getSelectedUpstreamSubscriptions = () => {
      const newUpstreamSubscriptions = [];

      upstreamSubscriptions.results.forEach((sub) => {
        let row = this.poolInSelectedRows(sub);

        if (row) {
          row.selected = true;
        } else {
          const foundRow = _.find(
            upstreamSubscriptions.results,
            foundSub => sub.id === foundSub.id,
          );

          row = { ...foundRow, selected: false };
        }

        newUpstreamSubscriptions.push(row);
      });

      return newUpstreamSubscriptions;
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

        <Spinner loading={upstreamSubscriptions.loading} className="small-spacer">
          <Row>
            <Col sm={12}>
              <Table
                rows={getSelectedUpstreamSubscriptions()}
                columns={columns(this)}
                emptyState={emptyStateData()}
                onSelectAllRows={this.onSelectAllRows}
              />
              <PaginationRow
                viewType="table"
                itemCount={upstreamSubscriptions.itemCount}
                pagination={upstreamSubscriptions.pagination}
                onChange={onPaginationChange}
              />
            </Col>
          </Row>
          {getSubscriptionActions()}
        </Spinner>
      </Grid>
    );
  }
}

UpstreamSubscriptionsPage.propTypes = {
  history: PropTypes.shape({ push: PropTypes.func }).isRequired,
  loadUpstreamSubscriptions: PropTypes.func.isRequired,
  saveUpstreamSubscriptions: PropTypes.func.isRequired,
  upstreamSubscriptions: PropTypes.shape({
    task: PropTypes.shape({}),
    error: PropTypes.shape({}),
  }).isRequired,
};

export default UpstreamSubscriptionsPage;
