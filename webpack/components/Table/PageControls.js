import React from 'react';
import PropTypes from 'prop-types';
import { Pagination, PaginationVariant, FlexItem } from '@patternfly/react-core';
import { usePaginationOptions } from 'foremanReact/components/Pagination/PaginationHooks';

import { getPageStats } from './helpers';

const PageControls = ({
  variant, total, page, perPage, onPaginationUpdate,
}) => {
  const { firstIndex, lastIndex } = getPageStats({ total, page, perPage });
  return (
    <FlexItem align={{ default: 'alignRight' }}>
      <Pagination
        key={variant}
        itemCount={total}
        itemsStart={firstIndex}
        itemsEnd={lastIndex}
        page={page}
        perPage={perPage}
        isCompact={variant === PaginationVariant.top}
        onSetPage={(_evt, updated) => onPaginationUpdate({ page: updated })}
        onPerPageSelect={(_evt, updated) => onPaginationUpdate({ per_page: updated })}
        perPageOptions={usePaginationOptions().map(p => ({ title: p.toString(), value: p }))}
        variant={variant}
      />
    </FlexItem>
  );
};

export default PageControls;

PageControls.propTypes = {
  variant: PropTypes.string.isRequired,
  total: PropTypes.number,
  page: PropTypes.number,
  perPage: PropTypes.number,
  onPaginationUpdate: PropTypes.func.isRequired,
};

PageControls.defaultProps = {
  total: 0,
  page: 1,
  perPage: 20,
};
