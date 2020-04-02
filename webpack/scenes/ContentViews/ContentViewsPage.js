import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import ContentViewsTable from './Table/ContentViewsTable';

const ContentViewsPage = ({ loadContentViews, loadContentViewDetails, ...tableProps }) => {
  useEffect(() => {
    loadContentViews();
  }, []);

  return (
    <React.Fragment>
      <h1>{__('Content Views')}</h1>
      <ContentViewsTable loadContentViewDetails={loadContentViewDetails} {...tableProps} />
    </React.Fragment>
  );
};

ContentViewsPage.propTypes = {
  tableProps: PropTypes.shape({
    results: PropTypes.arrayOf(PropTypes.shape({})),
    loading: PropTypes.bool,
    detailsMap: PropTypes.shape({}),
  }),
  loadContentViews: PropTypes.func.isRequired,
  loadContentViewDetails: PropTypes.func.isRequired,
};

ContentViewsPage.defaultProps = {
  tableProps: {
    results: [],
    loading: true,
    detailsMap: {},
  },
};

export default ContentViewsPage;
