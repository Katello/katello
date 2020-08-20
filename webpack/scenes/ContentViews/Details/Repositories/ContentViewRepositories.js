import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import { Bullseye } from '@patternfly/react-core';
import { TableVariant, fitContent } from '@patternfly/react-table';
import { Link } from 'react-router-dom';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import PropTypes from 'prop-types';

import TableWrapper from '../../../../components/Table/TableWrapper';
import { getContentViewRepositories } from '../ContentViewDetailActions';
import { selectCVRepos, selectCVReposStatus, selectCVReposError } from '../ContentViewDetailSelectors';
import { ADDED, NOT_ADDED } from '../../ContentViewsConstants';
import ContentCounts from './ContentCounts';
import LastSync from './LastSync';
import RepoAddedStatus from './RepoAddedStatus';
import RepoIcon from './RepoIcon';
import CheckableDropdown from './CheckableDropdown';

// checkbox_name: API_name
const repoTypes = {
  'Yum repositories': 'yum',
  'File repositories': 'file',
  'Container repositories': 'docker',
  'OSTree repositories': 'ostree', // ostree is deprecated?
};

const ContentViewRepositories = ({ cvId }) => {
  const dispatch = useDispatch();
  const response = useSelector(state => selectCVRepos(state, cvId), shallowEqual);
  const status = useSelector(state => selectCVReposStatus(state, cvId), shallowEqual);
  const error = useSelector(state => selectCVReposError(state, cvId), shallowEqual);
  const baseTypeState = {};
  Object.keys(repoTypes).forEach((type) => {
    baseTypeState[type] = true;
  });

  const [rows, setRows] = useState([]);
  const [metadata, setMetadata] = useState({});
  const [typeChecked, setTypeChecked] = useState(baseTypeState);
  const [statusChecked, setStatusChecked] = useState({ [ADDED]: true, [NOT_ADDED]: true });

  const columnHeaders = [
    { title: __('Type'), transforms: [fitContent] },
    __('Name'), __('Product'), __('Sync state'), __('Content'),
    { title: __('Status') },
  ];
  const loading = status === STATUS.PENDING;

  const buildRows = (results) => {
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
        { title: <Link to={urlBuilder(`products/${productId}/repositories`, '', id)}>{name}</Link> },
        productName,
        { title: <LastSync {...{ lastSyncWords, lastSync }} /> },
        { title: <ContentCounts {...{ counts, productId }} repoId={id} /> },
        {
          title: <RepoAddedStatus
            added={addedToCV || (statusChecked[ADDED] && !statusChecked[NOT_ADDED])}
          />,
        },
      ];

      newRows.push({ cells });
    });
    return newRows;
  };

  const onSelect = (_event, isSelected, rowId) => {
    let newRows;
    if (rowId === -1) {
      newRows = rows.map(row => ({ ...row, selected: isSelected }));
    } else {
      newRows = [...rows];
      newRows[rowId].selected = isSelected;
    }

    setRows(newRows);
  };

  const getCVReposWithOptions = (params = {}) => {
    const contentTypeParam = [];
    Object.keys(typeChecked).forEach((type) => {
      if (typeChecked[type]) contentTypeParam.push(repoTypes[type]);
    });
    const allParams = { ...params, content_type: contentTypeParam };
    return getContentViewRepositories(cvId, allParams, statusChecked);
  };

  useEffect(() => {
    dispatch(getCVReposWithOptions());
  }, [statusChecked, typeChecked]);

  useEffect(() => {
    const { results, ...meta } = response;
    setMetadata(meta);

    if (!loading && results) {
      const newRows = buildRows(results);
      setRows(newRows);
    }
  }, [JSON.stringify(response)]);

  useEffect(() => {
    if (!statusChecked[ADDED] && !statusChecked[NOT_ADDED]) setStatusChecked({ [ADDED]: true });
  }, [statusChecked]);

  const emptyContentTitle = __("You currently don't have any repositories to add to this content view.");
  const emptyContentBody = __('Please add some repositories.'); // needs link
  const emptySearchTitle = __('No matching repositories found');
  const emptySearchBody = __('Try changing your search settings.');

  return (
    <TableWrapper
      {...{
        rows,
        metadata,
        onSelect,
        emptyContentTitle,
        emptyContentBody,
        emptySearchTitle,
        emptySearchBody,
        error,
        status,
      }}
      cells={columnHeaders}
      variant={TableVariant.compact}
      autocompleteEndpoint="/repositories/auto_complete_search"
      fetchItems={params => getCVReposWithOptions(params)}
    >
      <CheckableDropdown items={Object.keys(repoTypes)} title="Type" checked={typeChecked} setChecked={setTypeChecked} />
      <CheckableDropdown items={[ADDED, NOT_ADDED]} title="Status" checked={statusChecked} setChecked={setStatusChecked} />
    </TableWrapper>
  );
};

ContentViewRepositories.propTypes = {
  cvId: PropTypes.number.isRequired,
};

export default ContentViewRepositories;
