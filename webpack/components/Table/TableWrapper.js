import React, { useEffect, useState } from 'react';
import { Pagination, Flex, FlexItem } from '@patternfly/react-core';

import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { usePaginationOptions, useForemanSettings } from 'foremanReact/Root/Context/ForemanContext';

import MainTable from './MainTable';
import Search from '../../components/Search';
import { orgId } from '../../services/api';

/* Patternfly 4 table wrapper */
const TableWrapper = ({
  metadata, fetchItems, autocompleteEndpoint, ...allTableProps
}) => {
  const { search: currentSearch } = metadata;
  const dispatch = useDispatch();
  const { foremanPerPage = 20 } = useForemanSettings();
  // setting pagination to local state so it doesn't disappear when page reloads
  const [perPage, setPerPage] = useState(foremanPerPage);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);

  const updatePagination = (data) => {
    const { total: newTotal, page: newPage, per_page: newPerPage } = data;
    if (newTotal) setTotal(parseInt(newTotal, 10));
    if (newPage) setPage(parseInt(newPage, 10));
    if (newPerPage) setPerPage(parseInt(newPerPage, 10));
  };

  useEffect(() => updatePagination(metadata), [metadata]);

  const paginationParams = () => ({ per_page: perPage, page });

  const getAutoCompleteParams = search => ({
    endpoint: autocompleteEndpoint,
    params: {
      organization_id: orgId(),
      search,
    },
  });

  const onSearch = search => dispatch(fetchItems({ ...paginationParams(), search }));

  const onPaginationUpdate = (updatedPagination) => {
    updatePagination(updatedPagination);
    dispatch(fetchItems({ ...paginationParams(), ...updatedPagination, search: currentSearch }));
  };

  return (
    <React.Fragment>
      <Flex>
        <FlexItem>
          <Search patternfly4 {...{ onSearch, getAutoCompleteParams }} />
        </FlexItem>
        <FlexItem align={{ default: 'alignRight' }}>
          <Pagination
            itemCount={total}
            page={page}
            perPage={perPage}
            onSetPage={(_evt, updated) => onPaginationUpdate({ page: updated })}
            onPerPageSelect={(_evt, updated) => onPaginationUpdate({ per_page: updated })}
            perPageOptions={usePaginationOptions().map(p => ({ title: p.toString(), value: p }))}
            variant="top"
          />
        </FlexItem>
      </Flex>
      <MainTable searchIsActive={!!currentSearch} {...allTableProps} />
    </React.Fragment>
  );
};

TableWrapper.propTypes = {
  fetchItems: PropTypes.func.isRequired,
  metadata: PropTypes.shape({
    total: PropTypes.number,
    page: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string, // The API can sometimes return strings
    ]),
    per_page: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]),
    search: PropTypes.string,
  }),
  autocompleteEndpoint: PropTypes.string.isRequired,
};

TableWrapper.defaultProps = {
  metadata: {},
};

export default TableWrapper;
