import React, { Component } from 'react';
import _ from 'lodash';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { LinkContainer } from 'react-router-bootstrap';
import { Grid, Row, Col } from 'react-bootstrap';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import { Button } from 'patternfly-react';
import { stringIsPositiveNumber } from 'foremanReact/common/helpers';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { LoadingState } from '../../../components/LoadingState';
import { Table } from '../../../components/pf3Table';
import { columns } from './UpstreamSubscriptionsTableSchema';

class UpstreamSubscriptionsPage extends Component {
  constructor(props) {
    super(props);

    this.state = {
      selectedRows: [],
    };
  }

  componentDidMount() {
    this.loadData();
  }

  onChange = (value, rowData) => {
    const { selectedRows } = this.state;
    const pool = {
      ...rowData,
      id: rowData.id,
      updatedQuantity: value,
      selected: true,
    };

    const match = this.poolInSelectedRows(pool);
    const index = _.indexOf(selectedRows, match);

    if (value) {
      if (match) {
        selectedRows.splice(index, 1, pool);
      } else {
        selectedRows.push(pool);
      }
    } else if (match) {
      selectedRows.splice(index, 1);
    }

    this.setState({ selectedRows });
  };

  // eslint-disable-next-line class-methods-use-this
  quantityValidation(pool) {
    const origQuantity = pool.updatedQuantity;
    if (origQuantity && stringIsPositiveNumber(origQuantity)) {
      const parsedQuantity = parseInt(origQuantity, 10);
      const aboveZeroMsg = [false, __('Please enter a positive number above zero')];

      if (parsedQuantity.toString().length > 10) return [false, __('Please limit number to 10 digits')];
      if (!pool.available) return [false, __('No pools available')];
      // handling unlimited subscriptions, they show as -1
      if (pool.available === -1) return parsedQuantity ? [true, ''] : aboveZeroMsg;
      if (parsedQuantity > pool.available) return [false, __(`Quantity must not be above ${pool.available}`)];
      if (parsedQuantity <= 0) return aboveZeroMsg;
    } else {
      return [false, __('Please enter digits only')];
    }
    return [true, ''];
  }

  poolInSelectedRows(pool) {
    const { selectedRows } = this.state;

    return _.find(
      selectedRows,
      foundPool => pool.id === foundPool.id,
    );
  }

  quantityValidationInput = (pool) => {
    if (!pool || pool.updatedQuantity === undefined) return null;
    if (this.quantityValidation(pool)[0]) {
      return 'success';
    }
    return 'error';
  };

  validateSelectedRows = () => Array.isArray(this.state.selectedRows) &&
    this.state.selectedRows.length &&
    this.state.selectedRows.every(pool => this.quantityValidation(pool)[0]);

  saveUpstreamSubscriptions = async () => {
    const updatedPools = _.map(
      this.state.selectedRows,
      pool => ({ ...pool, quantity: parseInt(pool.updatedQuantity, 10) }),
    );

    const updatedSubscriptions = { pools: updatedPools };

    await this.props.saveUpstreamSubscriptions(updatedSubscriptions);
    const { task } = this.props.upstreamSubscriptions;

    // TODO: could probably factor this out into a task response component
    if (task) {
      const message = (
        <span>
          <span>{__('Subscriptions have been saved and are being updated. ')}</span>
          <a href={urlBuilder('foreman_tasks/tasks', '', task.id)}>
            {__('Click here to go to the tasks page for the task.')}
          </a>
        </span>
      );

      window.tfm.toastNotifications.notify({ message, type: 'success' });
      this.props.history.push('/subscriptions');
    }
  };

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
                style={{ marginTop: '10px', marginRight: '5px' }}
                bsStyle="primary"
                type="submit"
                disabled={upstreamSubscriptions.loading ||
                  !this.validateSelectedRows()}
                onClick={this.saveUpstreamSubscriptions}
              >
                {__('Submit')}
              </Button>

              <LinkContainer to="/subscriptions" style={{ marginTop: '10px' }}>
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
          row = { ...row, selected: true };
        } else {
          const foundRow = upstreamSubscriptions.results.find(foundSub => sub.id === foundSub.id);
          row = { ...foundRow, selected: false };
        }

        newUpstreamSubscriptions.push(row);
      });

      return newUpstreamSubscriptions;
    };

    const emptyStateData = () => ({
      header: __('There are no Manifests to display'),
      description: __('Manifests allow you to find, access, synchronize, and download content ' +
        'from upstream Red Hat repositories for use in Red Hat Satellite.'),
      action: {
        title: __('Import a Manifest to Begin'),
        url: '/subscriptions',
      },
    });

    const checkAllRowsSelected = () =>
      upstreamSubscriptions.results.length === this.state.selectedRows.length;

    const selectionController = {
      allRowsSelected: () => checkAllRowsSelected(),
      selectAllRows: () => {
        if (checkAllRowsSelected()) {
          this.setState({ selectedRows: [] });
        } else {
          this.setState({ selectedRows: [...upstreamSubscriptions.results] });
        }
      },
      selectRow: ({ rowData }) => {
        let { selectedRows } = this.state;
        if (selectedRows.find(r => r.id === rowData.id)) {
          selectedRows = selectedRows.filter(e => e.id !== rowData.id);
        } else {
          selectedRows.push(rowData);
        }

        this.setState({ selectedRows });
      },
      isSelected: ({ rowData }) => (
        this.state.selectedRows.find(r => r.id === rowData.id) !== undefined
      ),
    };

    const tableColumns = columns(this, selectionController);
    const rows = getSelectedUpstreamSubscriptions();

    return (
      <Grid bsClass="container-fluid">
        <BreadcrumbsBar data={{
          isSwitchable: false,
          breadcrumbItems: [
            {
              caption: __('Subscriptions'),
              onClick: () => this.props.history.push('/subscriptions'),
            },
            {
              caption: __('Add Subscriptions'),
            },
          ],
        }}
        />

        <LoadingState loading={upstreamSubscriptions.loading} loadingText={__('Loading')}>
          <Row>
            <Col sm={12}>
              <Table
                rows={rows}
                columns={tableColumns}
                emptyState={emptyStateData()}
                itemCount={upstreamSubscriptions.itemCount}
                pagination={upstreamSubscriptions.pagination}
                onPaginationChange={onPaginationChange}
              />
            </Col>
          </Row>
          {getSubscriptionActions()}
        </LoadingState>
      </Grid>
    );
  }
}

UpstreamSubscriptionsPage.propTypes = {
  loadUpstreamSubscriptions: PropTypes.func.isRequired,
  saveUpstreamSubscriptions: PropTypes.func.isRequired,
  upstreamSubscriptions: PropTypes.shape({
    loading: PropTypes.bool,
    itemCount: PropTypes.number,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    results: PropTypes.array,
    pagination: PropTypes.shape({}),
    task: PropTypes.shape({
      id: PropTypes.string,
    }),
  }).isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
};

export default UpstreamSubscriptionsPage;
