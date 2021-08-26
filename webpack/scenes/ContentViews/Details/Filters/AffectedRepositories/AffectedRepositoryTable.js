import React, { useState, useEffect, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
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
import onSelect from '../../../../../components/Table/helpers';
import { getContentViewRepositories, getRepositoryTypes, updateContentView } from '../../ContentViewDetailActions';
import {
  selectCVRepos,
  selectCVReposStatus,
  selectCVReposError,
  selectRepoTypes,
  selectRepoTypesStatus,
  selectCVDetails,
} from '../../ContentViewDetailSelectors';
import { ADDED, NOT_ADDED, ALL_STATUSES } from '../../../ContentViewsConstants';
import ContentCounts from '../../Repositories/ContentCounts';
import LastSync from '../../Repositories/LastSync';
import AddedStatusLabel from '../../../../../components/AddedStatusLabel';
import SelectableDropdown from '../../../../../components/SelectableDropdown';
import { capitalize } from '../../../../../utils/helpers';
import TableWrapper from "../../../../../components/Table/TableWrapper";
import RepoIcon from "../../Repositories/RepoIcon";

const allRepositories = 'All repositories';
const allProducts = 'All products';

// Add any exceptions to the display names here
// [API_value]: displayed_value
const repoTypeNames = {
  docker: 'Container',
  ostree: 'OSTree',
};

const AffectedRepositoryTable = ({ cvId }) => {
  const dispatch = useDispatch();
  const response = useSelector(state => selectCVRepos(state, cvId), shallowEqual);
  const status = useSelector(state => selectCVReposStatus(state, cvId), shallowEqual);
  const error = useSelector(state => selectCVReposError(state, cvId), shallowEqual);
  const repoTypesResponse = useSelector(state => selectRepoTypes(state), shallowEqual);
  const repoTypesStatus = useSelector(state => selectRepoTypesStatus(state), shallowEqual);
  const details = useSelector(state => selectCVDetails(state, cvId), shallowEqual);

  const [rows, setRows] = useState([]);
  const deselectAll = () => setRows(rows.map(row => ({ ...row, selected: false })));
  const [metadata, setMetadata] = useState({});
  const [searchQuery, updateSearchQuery] = useState('');
  const statusSelected = ADDED;
  const [typeSelected, setTypeSelected] = useState(allRepositories);
  const [productSelected, setProductSelected] = useState(allProducts);

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

  const buildRows = useCallback((results) => {
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
        { title: <LastSync {...{ lastSyncWords, lastSync }} /> },
        { title: <ContentCounts {...{ counts, productId }} repoId={id} /> },
        {
          title: <AddedStatusLabel added={addedToCV} />,
        },
      ];
      newRows.push({
        repoId: id,
        cells,
        added: addedToCV || statusSelected === ADDED,
      });
    });
    return newRows;
  }, [statusSelected]);

  useDeepCompareEffect(() => {
    const { results, ...meta } = response;
    setMetadata(meta);

    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, loading, buildRows]);

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
        const typeFullName = Object.prototype.hasOwnProperty.call(repoTypeNames, name) ?
          repoTypeNames[name] : capitalize(name);
        allRepoTypes[`${typeFullName} Repositories`] = name;
      });
      console.log(allRepoTypes);
      setRepoTypes(allRepoTypes);
    }
  }, [repoTypesResponse, repoTypesStatus]);

  const toggleBulkAction = () => {
    setBulkActionOpen(!bulkActionOpen);
  };

  const onAdd = (repos) => {
    const { repository_ids: repositoryIds = [] } = details;
    dispatch(updateContentView(cvId, { repository_ids: repositoryIds.concat(repos) }));
  };

  const onRemove = (repos) => {
    const reposToDelete = [].concat(repos);
    const { repository_ids: repositoryIds = [] } = details;
    const deletedRepos = repositoryIds.filter(x => !reposToDelete.includes(x));
    dispatch(updateContentView(cvId, { repository_ids: deletedRepos }));
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

  const getCVReposWithOptions = useCallback((params = {}) => {
    const allParams = { ...params };
    if (typeSelected !== 'All repositories') allParams.content_type = repoTypes[typeSelected];

    return getContentViewRepositories(cvId, allParams, statusSelected);
  }, [cvId, repoTypes, statusSelected, typeSelected]);

  const emptyContentTitle = __("You currently don't have any repositories to add to this content view.");
  const emptyContentBody = __('Please add some repositories.'); // needs link
  const emptySearchTitle = __('No matching repositories found');
  const emptySearchBody = __('Try changing your search settings.');
  const activeFilters = (typeSelected && typeSelected !== allRepositories) ||
    (statusSelected && statusSelected !== ALL_STATUSES);

  const dropdownItems = [
    <DropdownItem aria-label="bulk_add" key="bulk_add" isDisabled={!hasNotAddedSelected} component="button" onClick={addBulk}>
      {__('Add')}
    </DropdownItem>,
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
      }}
      onSelect={onSelect(rows, setRows)}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/repositories/auto_complete_search"
      fetchItems={useCallback(params => getCVReposWithOptions(params), [getCVReposWithOptions])}
      additionalListeners={[typeSelected, statusSelected]}
    >
      <Split hasGutter>
        <SplitItem>
          <SelectableDropdown
            items={Object.keys(repoTypes)}
            title="Type"
            selected={typeSelected}
            setSelected={setTypeSelected}
            placeholderText="Type"
            loading={repoTypesStatus === STATUS.PENDING}
            error={repoTypesStatus === STATUS.ERROR}
          />
        </SplitItem>
        <SplitItem>
          <ActionList>
            <ActionListItem>
              <Button onClick={addBulk} isDisabled={!hasNotAddedSelected} variant="secondary" aria-label="add_repositories">
                Add repositories
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
      </Split>
    </TableWrapper>
  );
};

AffectedRepositoryTable.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default AffectedRepositoryTable;
