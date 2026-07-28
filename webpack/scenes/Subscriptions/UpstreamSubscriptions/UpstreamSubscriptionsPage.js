import React, { useState, useCallback, useMemo } from 'react';
import _ from 'lodash';
import { useSelector } from 'react-redux';
import { Tr, Td } from '@patternfly/react-table';
import { useHistory } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import {
  selectAPIResponse,
  selectAPIStatus,
} from 'foremanReact/redux/API/APISelectors';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import DefaultEmptyState from 'foremanReact/components/common/EmptyState/DefaultEmptyState';
import api, { orgId } from '../../../services/api';
import {
  UPSTREAM_SUBSCRIPTIONS_KEY,
} from './UpstreamSubscriptionsConstants';
import useUpstreamSubscriptionsColumns from './hooks/useUpstreamSubscriptionsColumns';
import useSaveUpstreamSubscriptions from './hooks/useSaveUpstreamSubscriptions';
import quantityValidation from './upstreamSubscriptionsHelpers';
import './UpstreamSubscriptions.scss';
import {
  ToolbarGroup,
  ToolbarItem,
  Button,
  Spinner,
} from '@patternfly/react-core';

const UpstreamSubscriptionsPage = () => {
  const history = useHistory();
  const [selectedRows, setSelectedRows] = useState([]);

  const apiUrl = `${api.getApiUrl(`/organizations/${orgId()}/upstream_subscriptions`)}?attachable=true`;

  const upstreamSubscriptionsSelector = state =>
    selectAPIResponse(state, UPSTREAM_SUBSCRIPTIONS_KEY);
  const apiResponse = useSelector(upstreamSubscriptionsSelector) || {};
  const status = useSelector(state => selectAPIStatus(state, UPSTREAM_SUBSCRIPTIONS_KEY));
  const { results = [], message: errorMessage } = apiResponse;
  const isLoading = status === STATUS.PENDING;

  const onChange = useCallback((value, rowData) => {
    const pool = {
      ...rowData,
      id: rowData.id,
      updatedQuantity: value,
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

  const poolInSelectedRows = useCallback(
    pool => _.find(selectedRows, foundPool => pool.id === foundPool.id),
    [selectedRows],
  );

  const getRowDataWithQuantity = useCallback((rowData) => {
    const selected = poolInSelectedRows(rowData);

    if (selected) {
      return selected;
    }

    return rowData;
  }, [poolInSelectedRows]);

  const quantityValidationInput = useCallback((pool) => {
    if (!pool || pool.updatedQuantity === undefined) {
      return null;
    }

    if (quantityValidation(pool)[0]) {
      return 'success';
    }

    return 'error';
  }, []);

  const validateSelectedRows = useCallback(() => (
    Array.isArray(selectedRows) &&
    selectedRows.length &&
    selectedRows.every(pool => quantityValidation(pool)[0])
  ), [selectedRows]);

  const { saveUpstreamSubscriptions, isSaving } = useSaveUpstreamSubscriptions({
    selectedRows,
    history,
  });

  const handleSaveUpstreamSubscriptions = useCallback(() => {
    if (!validateSelectedRows()) {
      return;
    }

    saveUpstreamSubscriptions();
  }, [validateSelectedRows, saveUpstreamSubscriptions]);

  const columns = useUpstreamSubscriptionsColumns({
    getRowDataWithQuantity,
    quantityValidationInput,
    poolInSelectedRows,
    onChange,
    handleSaveUpstreamSubscriptions,
  });

  const customToolbarItems = useMemo(() => (
    results.length > 0 ? (
      <ToolbarGroup align={{ default: 'alignLeft' }}>
        <ToolbarItem>
          <Button
            ouiaId="upstream-subscriptions-submit-button"
            variant="primary"
            onClick={handleSaveUpstreamSubscriptions}
            isDisabled={isLoading || isSaving || !validateSelectedRows()}
          >
            {__('Submit')}
          </Button>
        </ToolbarItem>
        <ToolbarItem>
          <Button
            ouiaId="upstream-subscriptions-cancel-button"
            variant="secondary"
            onClick={() => history.push('/subscriptions')}
          >
            {__('Cancel')}
          </Button>
        </ToolbarItem>
        {isLoading && <Spinner size="lg" />}
      </ToolbarGroup>
    ) : null
  ), [
    results.length,
    isLoading,
    isSaving,
    validateSelectedRows,
    handleSaveUpstreamSubscriptions,
    history,
  ]);

  const customEmptyState = !isLoading && results.length === 0 && !errorMessage ? (
    <Tr ouiaId="table-empty">
      <Td colSpan={100}>
        <DefaultEmptyState
          header={__('There are no Manifests to display')}
          description={__('Manifests allow you to find, access, synchronize, and download content ' +
            'from upstream Red Hat repositories for use in Red Hat Satellite.')}
          action={{
            title: __('Import a Manifest to Begin'),
            url: '/subscriptions',
          }}
        />
      </Td>
    </Tr>
  ) : null;

  return (
    <TableIndexPage
      apiUrl={apiUrl}
      apiOptions={{ key: UPSTREAM_SUBSCRIPTIONS_KEY }}
      searchable={false}
      creatable={false}
      ouiaId="upstream-subscriptions-table"
      breadcrumbOptions={{
        breadcrumbItems: [
          {
            caption: __('Subscriptions'),
            url: '/subscriptions/',
          },
          {
            caption: __('Add Subscriptions'),
          },
        ],
      }}
      columns={columns}
      customToolbarItems={customToolbarItems}
      customEmptyState={customEmptyState}
    />
  );
};

export default UpstreamSubscriptionsPage;
