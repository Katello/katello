import React, { useState, useCallback, useMemo } from 'react';
import _ from 'lodash';
import { useSelector, useDispatch } from 'react-redux';
import {
  ToolbarGroup,
  ToolbarItem,
  Button,
  Spinner,
} from '@patternfly/react-core';
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
  SAVE_UPSTREAM_SUBSCRIPTIONS_KEY,
} from './UpstreamSubscriptionsConstants';
import useUpstreamSubscriptionsColumns from './hooks/useUpstreamSubscriptionsColumns';
import { saveUpstreamSubscriptions } from './UpstreamSubscriptionsActions';
import quantityValidation from './upstreamSubscriptionsHelpers';
import './UpstreamSubscriptions.scss';

const UpstreamSubscriptionsPage = () => {
  const history = useHistory();
  const dispatch = useDispatch();
  const [selectedRows, setSelectedRows] = useState([]);

  const apiUrl = `${api.getApiUrl(`/organizations/${orgId()}/upstream_subscriptions`)}?attachable=true`;

  const upstreamSubscriptionsSelector = state =>
    selectAPIResponse(state, UPSTREAM_SUBSCRIPTIONS_KEY);
  const apiResponse = useSelector(upstreamSubscriptionsSelector) || {};
  const status = useSelector(state => selectAPIStatus(state, UPSTREAM_SUBSCRIPTIONS_KEY));
  const saveStatus = useSelector(state => selectAPIStatus(state, SAVE_UPSTREAM_SUBSCRIPTIONS_KEY));
  const { results = [], message: errorMessage } = apiResponse;
  const isLoading = status === STATUS.PENDING;
  const isSaving = saveStatus === STATUS.PENDING;

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

  const handleSaveUpstreamSubscriptions = useCallback(() => {
    if (!validateSelectedRows()) {
      return;
    }

    const pools = _.map(
      selectedRows,
      pool => ({ id: pool.id, quantity: parseInt(pool.updatedQuantity, 10) }),
    );

    dispatch(saveUpstreamSubscriptions({ pools }, () => history.push('/subscriptions')));
  }, [dispatch, selectedRows, history, validateSelectedRows]);

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
            isDisabled={isLoading || !validateSelectedRows()}
          >
            {__('Submit')}
          </Button>
        </ToolbarItem>
        <ToolbarItem>
          <Button
            ouiaId="upstream-subscriptions-cancel-button"
            variant="secondary"
            onClick={() => history.push('/subscriptions')}
            isDisabled={isLoading}
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
    validateSelectedRows,
    handleSaveUpstreamSubscriptions,
    history,
  ]);

  const customEmptyState = status === STATUS.RESOLVED && results.length === 0 && !errorMessage ? (
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
      replacementResponse={isSaving ? {
        response: {
          results: [],
          total: 0,
          page: 1,
          per_page: 10,
        },
      } : undefined}
      columns={columns}
      customToolbarItems={customToolbarItems}
      customEmptyState={customEmptyState}
    >
      {isSaving && (
        <div className="upstream-subscriptions-saving-container">
          <DefaultEmptyState
            header={__('Saving...')}
            description={__('Saving subscriptions quantities...')}
          />
        </div>
      )}
    </TableIndexPage>
  );
};

export default UpstreamSubscriptionsPage;
