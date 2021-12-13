import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { lowerCase, upperFirst } from 'lodash';
import { useSelector, shallowEqual, useDispatch } from 'react-redux';
import {
  Bullseye,
  Split,
  SplitItem,
  Button,
  ActionList,
  ActionListItem,
  Dropdown,
  DropdownItem,
  KebabToggle,
} from '@patternfly/react-core';
import { TableVariant, fitContent } from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import PropTypes from 'prop-types';

import TableWrapper from '../../../../components/Table/TableWrapper';
import onSelect from '../../../../components/Table/helpers';
import { getContentViewRepositories, getRepositoryTypes, updateContentView } from '../ContentViewDetailActions';
import {
  selectCVRepos,
  selectCVReposStatus,
  selectCVReposError,
  selectRepoTypes,
  selectRepoTypesStatus,
} from '../ContentViewDetailSelectors';
import { ADDED, NOT_ADDED, ALL_STATUSES } from '../../ContentViewsConstants';
import ContentCounts from './ContentCounts';
import LastSync from './LastSync';
import RepoIcon from './RepoIcon';
import AddedStatusLabel from '../../../../components/AddedStatusLabel';
import SelectableDropdown from '../../../../components/SelectableDropdown';
import { hasPermission } from '../../helpers';

const allRepositories = 'All repositories';

// Add any exceptions to the display names here
// [API_value]: displayed_value
const repoTypeNames = {
  docker: 'Container',
  ostree: 'OSTree',
};

const ContentViewRepositories = ({ cvId, details }) => {
  const dispatch = useDispatch();
  const response = useSelector(state => selectCVRepos(state, cvId), shallowEqual);
  const { results, ...metadata } = response;
  const status = useSelector(state => selectCVReposStatus(state, cvId), shallowEqual);
  const error = useSelector(state => selectCVReposError(state, cvId), shallowEqual);
  const repoTypesResponse = useSelector(state => selectRepoTypes(state), shallowEqual);
  const repoTypesStatus = useSelector(state => selectRepoTypesStatus(state), shallowEqual);
  const { permissions } = details;

  const [rows, setRows] = useState([]);
  const deselectAll = () => setRows(rows.map(row => ({ ...row, selected: false })));
  const [searchQuery, updateSearchQuery] = useState('');
  const [typeSelected, setTypeSelected] = useState(allRepositories);
  const [statusSelected, setStatusSelected] = useState(ALL_STATUSES);
  // repoTypes object format: [displayed_value]: API_value
  const [repoTypes, setRepoTypes] = useState({});
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const hasAddedSelected = rows.some(({ selected, added }) => selected && added);
  const hasNotAddedSelected = rows.some(({ selected, added }) => selected && !added);

  const columnHeaders = [
    { title: __('Type'), transforms: [fitContent] },
    __('Name'),
    __('Product'),
    __('Sync state'),
    __('Content'),
    { title: __('Status') },
  ];
  const loading = status === STATUS.PENDING;

  const buildRows = useCallback(() => {
    const newRows = [];
    results.forEach((repo) => {
      const {
        id,
        content_type: contentType,
        name,
        added_to_content_view: addedToCV,
        product: { id: productId, name: productName },
        content_counts: counts,
        last_sync_words: lastSyncWords,
        last_sync: lastSync,
      } = repo;

      const cells = [
        { title: <Bullseye><RepoIcon type={contentType} /></Bullseye> },
        { title: <a href={urlBuilder(`products/${productId}/repositories`, '', id)}>{name}</a> },
        productName,
        { title: <LastSync {...{ startedAt: lastSync?.started_at, lastSyncWords, lastSync }} /> },
        { title: <ContentCounts {...{ counts, productId }} repoId={id} /> },
        {
          title: <AddedStatusLabel added={addedToCV || statusSelected === ADDED} />,
        },
      ];
      newRows.push({
        repoId: id,
        cells,
        added: addedToCV || statusSelected === ADDED,
      });
    });
    return newRows;
  }, [statusSelected, results]);

  useDeepCompareEffect(() => {
    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, loading, buildRows, results]);

  useEffect(() => {
    dispatch(getRepositoryTypes());
  }, []); // eslint-disable-line react-hooks/exhaustive-deps


  // Get repo type filter selections dynamically from the API
  useDeepCompareEffect(() => {
    if (repoTypesStatus === STATUS.RESOLVED && repoTypesResponse) {
      const allRepoTypes = {};
      allRepoTypes[allRepositories] = 'all';
      repoTypesResponse.forEach((type) => {
        const { name } = type;
        const typeFullName = name in repoTypeNames ?
          repoTypeNames[name] : upperFirst(lowerCase(name));
        allRepoTypes[`${typeFullName} Repositories`] = name;
      });
      setRepoTypes(allRepoTypes);
    }
  }, [repoTypesResponse, repoTypesStatus]);

  const toggleBulkAction = () => {
    setBulkActionOpen(!bulkActionOpen);
  };

  const onAdd = (repos) => {
    const { repository_ids: repositoryIds = [] } = details;
    dispatch(updateContentView(
      cvId,
      { repository_ids: repositoryIds.concat(repos) },
      () =>
        dispatch(getContentViewRepositories(
          cvId,
          typeSelected !== 'All repositories' ? {
            content_type: repoTypes[typeSelected],
          } : {},
          statusSelected,
        )),
    ));
  };

  const onRemove = (repos) => {
    const reposToDelete = [].concat(repos);
    const { repository_ids: repositoryIds = [] } = details;
    const deletedRepos = repositoryIds.filter(x => !reposToDelete.includes(x));
    dispatch(updateContentView(
      cvId, { repository_ids: deletedRepos },
      () =>
        dispatch(getContentViewRepositories(
          cvId,
          typeSelected !== 'All repositories' ? {
            content_type: repoTypes[typeSelected],
          } : {},
          statusSelected,
        )),
    ));
  };

  const addBulk = () => {
    setBulkActionOpen(false);
    const reposToAdd = rows.filter(({ selected, added }) =>
      selected && !added).map(({ repoId }) => repoId);
    deselectAll();
    onAdd(reposToAdd);
  };

  const removeBulk = () => {
    setBulkActionOpen(false);
    const reposToDelete = rows.filter(({ selected, added }) =>
      selected && added).map(({ repoId }) => repoId);
    deselectAll();
    onRemove(reposToDelete);
  };

  const actionResolver = ({
    parent,
    compoundParent,
    noactions,
    added,
  }) => {
    if (parent || compoundParent || noactions) return null;
    return [
      {
        title: 'Add',
        isDisabled: added,
        onClick: (_event, _rowId, rowInfo) => {
          onAdd(rowInfo.repoId);
        },
      },
      {
        title: 'Remove',
        isDisabled: !added,
        onClick: (_event, _rowId, rowInfo) => {
          onRemove(rowInfo.repoId);
        },
      },
    ];
  };

  const getCVReposWithOptions = useCallback((params = {}) => {
    const allParams = { ...params };
    if (typeSelected !== 'All repositories') allParams.content_type = repoTypes[typeSelected];

    return getContentViewRepositories(cvId, allParams, statusSelected);
  }, [cvId, repoTypes, statusSelected, typeSelected]);

  const emptyContentTitle = __("You currently don't have any repositories to add to this content view.");
  const emptyContentBody = __('Please add some repositories.'); // needs link
  const emptySearchTitle = __('No matching repositories found');
  const emptySearchBody = __('Try changing your search settings.');
  const activeFilters = [typeSelected, statusSelected];
  const defaultFilters = [allRepositories, ALL_STATUSES];

  const dropdownItems = [
    <DropdownItem aria-label="bulk_remove" key="bulk_remove" isDisabled={!hasAddedSelected} component="button" onClick={removeBulk}>
      {__('Remove')}
    </DropdownItem>,
  ];

  return (
    <TableWrapper
      {...{
        rows,
        metadata,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        searchQuery,
        updateSearchQuery,
        error,
        status,
        activeFilters,
        defaultFilters,
      }}
      actionResolver={hasPermission(permissions, 'edit_content_views') ? actionResolver : null}
      onSelect={hasPermission(permissions, 'edit_content_views') ? onSelect(rows, setRows) : null}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/repositories/auto_complete_search"
      fetchItems={useCallback(params => getCVReposWithOptions(params), [getCVReposWithOptions])}
      additionalListeners={[typeSelected, statusSelected]}
      actionButtons={
        <Split hasGutter>
          <SplitItem>
            <SelectableDropdown
              items={Object.keys(repoTypes)}
              title={__('Type')}
              selected={typeSelected}
              setSelected={setTypeSelected}
              placeholderText={__('Type')}
              loading={repoTypesStatus === STATUS.PENDING}
              error={repoTypesStatus === STATUS.ERROR}
            />
          </SplitItem>
          <SplitItem>
            <SelectableDropdown
              items={[ALL_STATUSES, ADDED, NOT_ADDED]}
              title={__('Status')}
              selected={statusSelected}
              setSelected={setStatusSelected}
              placeholderText={__('Status')}
            />
          </SplitItem>
          {hasPermission(permissions, 'edit_content_views') &&
            <SplitItem>
              <ActionList>
                <ActionListItem>
                  <Button onClick={addBulk} isDisabled={!hasNotAddedSelected} variant="secondary" aria-label="add_repositories">
                    {__('Add repositories')}
                  </Button>
                </ActionListItem>
                <ActionListItem>
                  <Dropdown
                    toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
                    isOpen={bulkActionOpen}
                    isPlain
                    dropdownItems={dropdownItems}
                  />
                </ActionListItem>
              </ActionList>
            </SplitItem>
          }
        </Split>
      }
    />
  );
};

ContentViewRepositories.propTypes = {
  cvId: PropTypes.number.isRequired,
  details: PropTypes.shape({
    repository_ids: PropTypes.arrayOf(PropTypes.number),
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default ContentViewRepositories;
