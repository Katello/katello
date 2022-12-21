import React, {
  useCallback,
  useEffect,
  useState,
} from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { STATUS } from 'foremanReact/constants';
import {
  lowerCase,
  upperFirst,
} from 'lodash';
import PropTypes from 'prop-types';
import {
  shallowEqual,
  useDispatch,
  useSelector,
} from 'react-redux';
import useDeepCompareEffect from 'use-deep-compare-effect';

import {
  ActionList,
  ActionListItem,
  Bullseye,
  Button,
  Dropdown,
  DropdownItem,
  KebabToggle,
  Split,
  SplitItem,
  Checkbox,
} from '@patternfly/react-core';
import {
  TableVariant,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
} from '@patternfly/react-table';
import AddedStatusLabel from '../../../../components/AddedStatusLabel';
import SelectableDropdown from '../../../../components/SelectableDropdown';
import TableWrapper from '../../../../components/Table/TableWrapper';
import {
  ADDED,
  ALL_STATUSES,
  NOT_ADDED,
} from '../../ContentViewsConstants';
import { hasPermission } from '../../helpers';
import {
  getContentViewRepositories,
  getRepositoryTypes,
  updateContentView,
} from '../ContentViewDetailActions';
import {
  selectCVRepos,
  selectCVReposError,
  selectCVReposStatus,
  selectRepoTypes,
  selectRepoTypesStatus,
} from '../ContentViewDetailSelectors';
import ContentCounts from './ContentCounts';
import LastSync from './LastSync';
import RepoIcon from './RepoIcon';
import { useSelectionSet } from '../../../../components/Table/TableHooks';

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
  const { permissions, generated_for: generatedFor, import_only: importOnly } = details;
  const generatedContentView = generatedFor !== 'none';
  const [searchQuery, updateSearchQuery] = useState('');
  const [typeSelected, setTypeSelected] = useState(allRepositories);
  const [statusSelected, setStatusSelected] = useState(ALL_STATUSES);
  // repoTypes object format: [displayed_value]: API_value
  const [repoTypes, setRepoTypes] = useState({});
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const { repository_ids: repositoryIds = [] } = details;
  const resetFilters = () => {
    setTypeSelected(allRepositories);
    setStatusSelected(ALL_STATUSES);
  };
  const {
    isSelected,
    selectOne,
    selectNone,
    selectedCount,
    selectedResults,
    selectionSet,
    isSelectable,
    ...selectAll
  } = useSelectionSet({
    results,
    metadata,
  });

  const hasAddedSelected = selectedResults.some(({ id }) => repositoryIds.includes(id));
  const hasNotAddedSelected = selectedResults.some(({ id }) => !repositoryIds.includes(id));

  const columnHeaders = [
    __('Type'),
    __('Name'),
    __('Product'),
    __('Sync state'),
    __('Content'),
    __('Status'),
  ];

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
    const reposToAdd = selectedResults.filter(selectedRepo =>
      !repositoryIds.includes(selectedRepo.id)).map(({ id }) => id);
    selectNone();
    onAdd(reposToAdd);
  };

  const removeBulk = () => {
    setBulkActionOpen(false);
    const reposToDelete = selectedResults.filter(selectedRepo =>
      repositoryIds.includes(selectedRepo.id)).map(({ id }) => id);
    selectNone();
    onRemove(reposToDelete);
  };

  const rowDropdownItems = ({ id }) => [
    {
      title: 'Add',
      ouiaId: `add-repository-${id}`,
      isDisabled: importOnly || generatedContentView || repositoryIds.includes(id),
      onClick: () => {
        onAdd(id);
      },
    },
    {
      title: 'Remove',
      ouiaId: `remove-repository-${id}`,
      isDisabled: importOnly || generatedContentView || !repositoryIds.includes(id),
      onClick: () => {
        onRemove(id);
      },
    },
  ];

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
    <DropdownItem ouiaId="bulk-remove-repositories" aria-label="bulk_remove" key="bulk_remove" isDisabled={!hasAddedSelected} component="button" onClick={removeBulk}>
      {__('Remove')}
    </DropdownItem>,
  ];

  return (
    <TableWrapper
      {...{
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
        selectedCount,
        selectNone,
        resetFilters,
      }}
      ouiaId="content-view-repositories-table"
      {...selectAll}
      variant={TableVariant.compact}
      autocompleteEndpoint="/katello/api/v2/repositories"
      bookmarkController="katello_content_view_repositories"
      fetchItems={useCallback(params => getCVReposWithOptions(params), [getCVReposWithOptions])}
      additionalListeners={[typeSelected, statusSelected]}
      displaySelectAllCheckbox={hasPermission(permissions, 'edit_content_views')}
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
                  <Button ouiaId="add-repositories" onClick={addBulk} isDisabled={!hasNotAddedSelected || importOnly || generatedContentView} variant="primary" aria-label="add_repositories">
                    {__('Add repositories')}
                  </Button>
                </ActionListItem>
                <ActionListItem>
                  <Dropdown
                    ouiaId="repositoies-bulk-actions"
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
    >
      <Thead>
        <Tr key="version-header" ouiaId="version-header">
          {hasPermission(permissions, 'edit_content_views') && <Th key="select-all" />}
          {columnHeaders.map((title, index) => {
            if (index === 0) {
              return <Th modifier="fitContent" key={`col-header-${title}`}>{title}</Th>;
            }
            return <Th key={`col-header-${title}`}>{title}</Th>;
          })}
        </Tr>
      </Thead>
      <Tbody>
        {results?.map((repo) => {
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
          return (
            <Tr key={id} ouiaId={`repositories-table-row-${productName}-${name}`}>
              {hasPermission(permissions, 'edit_content_views') &&
                <Td>
                  <Checkbox
                    id={id}
                    ouiaId={`repository-checkbox-${id}`}
                    isChecked={isSelected(id)}
                    onChange={selected =>
                      selectOne(selected, id, repo)
                    }
                  />
                </Td>
              }
              <Td><Bullseye><RepoIcon type={contentType} /></Bullseye></Td>
              <Td>
                <a href={urlBuilder(`products/${productId}/repositories`, '', id)}>{name}</a>
              </Td>
              <Td>{productName}</Td>
              <Td>
                <LastSync {...{ startedAt: lastSync?.started_at, lastSyncWords, lastSync }} />
              </Td>
              <Td><ContentCounts {...{ counts, productId }} repoId={id} /></Td>
              <Td><AddedStatusLabel added={addedToCV || statusSelected === ADDED} /></Td>
              {hasPermission(permissions, 'edit_content_views') &&
              <Td
                actions={{
                  items: rowDropdownItems(repo),
                }}
              />}
            </Tr>
          );
        })}
      </Tbody>
    </TableWrapper>
  );
};

ContentViewRepositories.propTypes = {
  cvId: PropTypes.number.isRequired,
  details: PropTypes.shape({
    repository_ids: PropTypes.arrayOf(PropTypes.number),
    permissions: PropTypes.shape({}),
    import_only: PropTypes.bool,
    generated_for: PropTypes.string,
  }).isRequired,
};

export default ContentViewRepositories;
