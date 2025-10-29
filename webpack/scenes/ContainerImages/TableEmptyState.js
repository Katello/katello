import React from 'react';
import PropTypes from 'prop-types';
import { Tbody, Tr, Td } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import EmptyPage from 'foremanReact/routes/common/EmptyPage';
import { STATUS } from './containerImagesHelpers';

const TableEmptyState = ({
  status, results, errorMessage, colSpan,
}) => {
  if (results.length > 0 && !errorMessage) {
    return null;
  }

  return (
    <Tbody>
      {status === STATUS.PENDING && results.length === 0 && (
        <Tr ouiaId="table-loading">
          <Td colSpan={colSpan}>
            <EmptyPage
              message={{
                type: 'loading',
                text: __('Loading...'),
              }}
            />
          </Td>
        </Tr>
      )}
      {status !== STATUS.PENDING &&
        results.length === 0 &&
        !errorMessage && (
          <Tr ouiaId="table-empty">
            <Td colSpan={colSpan}>
              <EmptyPage
                message={{
                  type: 'empty',
                }}
              />
            </Td>
          </Tr>
      )}
      {errorMessage && (
        <Tr ouiaId="table-error">
          <Td colSpan={colSpan}>
            <EmptyPage message={{ type: 'error', text: errorMessage }} />
          </Td>
        </Tr>
      )}
    </Tbody>
  );
};

TableEmptyState.propTypes = {
  status: PropTypes.string,
  results: PropTypes.arrayOf(PropTypes.shape({})),
  errorMessage: PropTypes.string,
  colSpan: PropTypes.number,
};

TableEmptyState.defaultProps = {
  status: STATUS.PENDING,
  results: [],
  errorMessage: null,
  colSpan: 100,
};

export default TableEmptyState;
