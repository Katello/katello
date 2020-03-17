import React, { useState, useEffect } from 'react';
import ContentViewTable from './Table/ContentViewTable';

const contentViewIndexFakeData = require('./data/index');
// Uncomment and comment out above to see empty state
// const contentViewIndexFakeData = { results: [] };

const ContentViewPage = () => {
  const [contentViews, setContentViews] = useState(null);

  useEffect(() => {
    setTimeout(() => {
      setContentViews(contentViewIndexFakeData);
    }, 5000);
  }, []);

  return (
    <React.Fragment>
      <h1>Content Views</h1>
      <ContentViewTable contentViews={contentViews} />
    </React.Fragment>
  );
};

export default ContentViewPage;
