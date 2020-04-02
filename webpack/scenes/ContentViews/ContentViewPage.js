import React, { useEffect } from 'react';
import PropTypes from 'prop-types';

import ContentViewTable from './Table/ContentViewTable';

const ContentViewPage = ({ loadContentViews, contentViews }) => {
  useEffect(
    () => {
      loadContentViews();
    }, []
  );

  return (
    <React.Fragment>
      <h1>Content Views</h1>
      <ContentViewTable contentViews={contentViews} />
  </React.Fragment>
  );
};

ContentViewPage.propTypes = {
  contentViews: PropTypes.shape({
    results: PropTypes.array,
  }),
};

ContentViewPage.defaultProps = {
  contentViews: null,
};

export default ContentViewPage;
