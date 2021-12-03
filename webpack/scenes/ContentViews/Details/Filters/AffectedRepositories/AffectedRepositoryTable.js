import React, { useState, useCallback } from 'react';
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
import { omit } from 'lodash';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import PropTypes from 'prop-types';
import onSelect from '../../../../../components/Table/helpers';
import { editCVFilter, getCVFilterDetails, getFilterRepositories } from '../../ContentViewDetailActions';
import { selectCVFilterRepos, selectCVFilterReposStatus, selectCVFilterReposError, selectCVFilterDetails } from '../../ContentViewDetailSelectors';
import ContentCounts from '../../Repositories/ContentCounts';
import LastSync from '../../Repositories/LastSync';
import AddedStatusLabel from '../../../../../components/AddedStatusLabel';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import RepoIcon from '../../Repositories/RepoIcon';
import SelectableDropdown from '../../../../../components/SelectableDropdown/SelectableDropdown';
import { hasPermission } from '../../../helpers';

const allProducts = 'All products';

const AffectedRepositoryTable = ({
  cvId, filterId, repoType, setShowAffectedRepos, details,
}) => {
  const dispatch = useDispatch();
  const response = useSelector(state => selectCVFilterRepos(state, filterId), shallowEqual);
  const [initialResponse, setInitialResponse] = useState(response);
  const status = useSelector(state => selectCVFilterReposStatus(state, filterId), shallowEqual);
  const error = useSelector(state => selectCVFilterReposError(state, filterId), shallowEqual);
  const filterDetails = useSelector(state =>
    selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const { repositories = [] } = filterDetails;
  const [rows, setRows] = useState([]);
  const [searchQuery, updateSearchQuery] = useState('');
  const [productSelected, setProductSelected] = useState(allProducts);
  const [repoProducts, setRepoProducts] = useState({});
  const [bulkActionOpen, setBulkActionOpen] = useState(false);
  const hasAddedSelected = rows.some(({ selected, added }) => selected && added);
  const hasNotAddedSelected = rows.some(({ selected, added }) => selected && !added);
  const deselectAll = () => setRows(rows.map(row => ({ ...row, selected: false })));
  const metadata = omit(response, ['results']);
  const { permissions } = details;

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
    const isAddedToFilter = repoId => (!!repositories.filter(repo => repo.id === repoId).length);
    const newRows = [];
    results.forEach((repo) => {
      const {
        id,
        content_type: contentType,
        name,
        product: { id: productId, name: productName },
        content_counts: counts,
        last_sync_words: lastSyncWords,
        last_sync: lastSync,
      } = repo;

      const addedToFilter = isAddedToFilter(id);

      const cells = [
        { title: <Bullseye><RepoIcon type={contentType} /></Bullseye> },
        { title: <a href={urlBuilder(`products/${productId}/repositories`, '', id)}>{name}</a> },
        productName,
        { title: <LastSync {...{ lastSyncWords, lastSync }} /> },
        { title: <ContentCounts {...{ counts, productId }} repoId={id} /> },
        {
          title: <AddedStatusLabel added={addedToFilter} />,
        },
      ];
      newRows.push({
        repoId: id,
        cells,
        added: addedToFilter,
      });
    });
    return newRows.sort(({ added: addedA }, { added: addedB }) => {
      if (addedA === addedB) return 0;
      return addedA ? -1 : 1;
    });
  }, [repositories]);

  useDeepCompareEffect(() => {
    const { results } = response;
    if (!loading && results) {
      if (Object.keys(initialResponse).length === 0 || !Object.keys(repoProducts).length) {
        setInitialResponse(response);
        const allRepoProducts = {};
        allRepoProducts[allProducts] = 'all';
        results.forEach((repo) => {
          const { product = {} } = repo;
          const { name, id } = product;
          allRepoProducts[name] = id;
        });
        setRepoProducts(allRepoProducts);
      }
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [response, loading, buildRows, initialResponse,
    setInitialResponse, repoProducts, setRepoProducts]);

  const toggleBulkAction = () => {
    setBulkActionOpen(!bulkActionOpen);
  };

  const onAdd = (repos) => {
    const repositoryIds = repositories.map(repo => repo.id);
    dispatch(editCVFilter(
      filterId,
      { id: filterId, repository_ids: repositoryIds.concat(repos) }, () => {
        dispatch(getCVFilterDetails(cvId, filterId));
      },
    ));
  };

  const onRemove = (repos) => {
    const reposToDelete = [].concat(repos);
    const repositoryIds = repositories.map(repo => repo.id);
    const deletedRepos = repositoryIds.filter(x => !reposToDelete.includes(x));
    dispatch(editCVFilter(
      filterId,
      { id: filterId, repository_ids: deletedRepos },
      () => dispatch(getCVFilterDetails(cvId, filterId, {})),
    ));
    if (deletedRepos.length === 0) setShowAffectedRepos(false);
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
    allParams.content_type = repoType;
    if (productSelected !== allProducts) {
      allParams.product_id = repoProducts[productSelected];
    }
    return getFilterRepositories(cvId, filterId, allParams);
  }, [cvId, filterId, repoType, productSelected, repoProducts]);

  const emptyContentTitle = __("You currently don't have any repositories to add to this filter.");
  const emptyContentBody = __('Please add some repositories.');
  const emptySearchTitle = __('No matching repositories found');
  const emptySearchBody = __('Try changing your search settings.');
  const activeFilters = [productSelected];
  const defaultFilters = [allProducts];
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
        activeFilters,
        defaultFilters,
        error,
        status,
      }}
      onSelect={hasPermission(permissions, 'edit_content_views') ? onSelect(rows, setRows) : null}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/repositories/auto_complete_search"
      fetchItems={useCallback(params => getCVReposWithOptions(params), [getCVReposWithOptions])}
      additionalListeners={[productSelected]}
      actionButtons={
        <>
          <Split hasGutter>
            <SplitItem>
              <SelectableDropdown
                items={Object.keys(repoProducts)}
                title={__('Product')}
                selected={productSelected}
                setSelected={setProductSelected}
                placeholderText={__('Product')}
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
        </>
      }
    />
  );
};

AffectedRepositoryTable.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  repoType: PropTypes.string.isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default AffectedRepositoryTable;
