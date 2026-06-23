import React, { useState, useEffect, useCallback } from 'react';
import _ from 'lodash';
import { translate as __, sprintf } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { LinkContainer } from 'react-router-bootstrap';
import { Grid, GridItem, Button } from '@patternfly/react-core';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import { stringIsPositiveNumber } from 'foremanReact/common/helpers';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { LoadingState } from '../../../components/LoadingState';
import { Table } from '../../../components/pf3Table';
import { columns } from './UpstreamSubscriptionsTableSchema';

// Validates subscription quantity input
export const quantityValidation = (pool) => {
  const origQuantity = pool.updatedQuantity;
  if (origQuantity && stringIsPositiveNumber(origQuantity)) {
    const parsedQuantity = parseInt(origQuantity, 10);
    const aboveZeroMsg = [false, __('Please enter a positive number above zero')];

    if (parsedQuantity.toString().length > 10) return [false, __('Please limit number to 10 digits')];
    if (!pool.available) return [false, __('No pools available')];
    // handling unlimited subscriptions, they show as -1
    if (pool.available === -1) return parsedQuantity ? [true, ''] : aboveZeroMsg;
    if (parsedQuantity > pool.available) return [false, sprintf(__('Quantity must not be above %s'), pool.available)];
    if (parsedQuantity <= 0) return aboveZeroMsg;
  } else {
    return [false, __('Please enter digits only')];
  }
  return [true, ''];
};

const UpstreamSubscriptionsPage = ({
  loadUpstreamSubscriptions,
  saveUpstreamSubscriptions,
  upstreamSubscriptions,
  history,
}) => {
  const [selectedRows, setSelectedRows] = useState([]);

  useEffect(() => {
    loadUpstreamSubscriptions();
  }, [loadUpstreamSubscriptions]);

  const onChange = useCallback((value, rowData) => {
    const pool = {
      ...rowData,
      id: rowData.id,
      updatedQuantity: value,
      selected: true,
    };

    setSelectedRows((prevSelectedRows) => {
      const newSelectedRows = [...prevSelectedRows];
      const match = _.find(newSelectedRows, foundPool => pool.id === foundPool.id);
      const index = _.indexOf(newSelectedRows, match);

      if (value) {
        if (match) {
          newSelectedRows.splice(index, 1, pool);
        } else {
          newSelectedRows.push(pool);
        }
      } else if (match) {
        newSelectedRows.splice(index, 1);
      }

      return newSelectedRows;
    });
  }, []);

  const poolInSelectedRows = useCallback(pool => _.find(
    selectedRows,
    foundPool => pool.id === foundPool.id,
  ), [selectedRows]);

  const quantityValidationInput = useCallback((pool) => {
    if (!pool || pool.updatedQuantity === undefined) return null;
    if (quantityValidation(pool)[0]) {
      return 'success';
    }
    return 'error';
  }, []);

  const validateSelectedRows = useCallback(() => Array.isArray(selectedRows) &&
    selectedRows.length &&
    selectedRows.every(pool => quantityValidation(pool)[0]), [selectedRows]);

  const handleSaveUpstreamSubscriptions = useCallback(async () => {
    const updatedPools = _.map(
      selectedRows,
      pool => ({ ...pool, quantity: parseInt(pool.updatedQuantity, 10) }),
    );

    const updatedSubscriptions = { pools: updatedPools };

    const action = await saveUpstreamSubscriptions(updatedSubscriptions);
    const task = action?.response;

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
      history.push('/subscriptions');
    }
  }, [selectedRows, saveUpstreamSubscriptions, history]);

  const getSubscriptionActions = () => {
    if (upstreamSubscriptions.results.length > 0) {
      return (
        <Grid hasGutter style={{ marginTop: '10px' }}>
          <GridItem span={12}>
            <Button
              ouiaId="upstream-subscriptions-submit-button"
              style={{ marginRight: '5px' }}
              variant="primary"
              type="submit"
              isDisabled={upstreamSubscriptions.loading || !validateSelectedRows()}
              onClick={handleSaveUpstreamSubscriptions}
            >
              {__('Submit')}
            </Button>

            <LinkContainer to="/subscriptions">
              <Button ouiaId="upstream-subscriptions-cancel-button" variant="secondary">
                {__('Cancel')}
              </Button>
            </LinkContainer>
          </GridItem>
        </Grid>
      );
    }

    return null;
  };

  const onPaginationChange = useCallback((pagination) => {
    loadUpstreamSubscriptions({
      ...pagination,
    });
  }, [loadUpstreamSubscriptions]);

  const getSelectedUpstreamSubscriptions = useCallback(() => {
    const newUpstreamSubscriptions = [];

    upstreamSubscriptions.results.forEach((sub) => {
      let row = poolInSelectedRows(sub);

      if (row) {
        row = { ...row, selected: true };
      } else {
        const foundRow = upstreamSubscriptions.results.find(foundSub => sub.id === foundSub.id);
        row = { ...foundRow, selected: false };
      }

      newUpstreamSubscriptions.push(row);
    });

    return newUpstreamSubscriptions;
  }, [upstreamSubscriptions.results, poolInSelectedRows]);

  const emptyStateData = () => ({
    header: __('There are no Manifests to display'),
    description: __('Manifests allow you to find, access, synchronize, and download content ' +
      'from upstream Red Hat repositories for use in Red Hat Satellite.'),
    action: {
      title: __('Import a Manifest to Begin'),
      url: '/subscriptions',
    },
  });

  const componentRef = {
    onChange,
    quantityValidation,
    quantityValidationInput,
    saveUpstreamSubscriptions: handleSaveUpstreamSubscriptions,
  };

  const tableColumns = columns(componentRef);
  const rows = getSelectedUpstreamSubscriptions();

  return (
    <div className="container-fluid">
      {!upstreamSubscriptions.loading &&
      <div style={{ marginBottom: '10px' }}>
        <BreadcrumbsBar
          isLoadingResources={upstreamSubscriptions.loading}
          breadcrumbItems={[
            {
              caption: __('Subscriptions'),
              url: '/subscriptions/',
            },
            {
              caption: String(__('Add Subscriptions')),
            },
          ]}
        />
      </div>
      }

      <LoadingState loading={upstreamSubscriptions.loading} loadingText={__('Loading')}>
        <Grid hasGutter>
          <GridItem span={12}>
            <Table
              ouiaId="upstream-subscriptions-table"
              rows={rows}
              columns={tableColumns}
              emptyState={emptyStateData()}
              itemCount={upstreamSubscriptions.itemCount}
              pagination={upstreamSubscriptions.pagination}
              onPaginationChange={onPaginationChange}
            />
          </GridItem>
        </Grid>
        {getSubscriptionActions()}
      </LoadingState>
    </div>
  );
};

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
