import React from 'react';
import PropTypes from 'prop-types';
import { FlexItem } from '@patternfly/react-core';
import Pagination from 'foremanReact/components/Pagination';

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
        onChange={onPaginationUpdate}
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
