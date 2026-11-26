import React from 'react';
import PropTypes from 'prop-types';
import { FlexItem } from '@patternfly/react-core';
import Pagination from 'foremanReact/components/Pagination';

// PatternFly treats itemsStart as the first page number. Passing the first
// item index disables the previous control when one entry per page makes
// that index equal the current page. The visible range is derived from
// page, perPage, and itemCount.
const PageControls = ({
  variant, total, page, perPage, onPaginationUpdate,
}) => (
  <FlexItem align={{ default: 'alignRight' }}>
    <Pagination
      ouiaId={`pagination-${variant}`}
      key={variant}
      itemCount={total}
      page={page}
      perPage={perPage}
      onChange={onPaginationUpdate}
      variant={variant}
      updateParamsByUrl={false}
    />
  </FlexItem>
);

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
