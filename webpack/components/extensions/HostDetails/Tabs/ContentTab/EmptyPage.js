import React from 'react';
import PropTypes from 'prop-types';
import PFEmptyPage from 'foremanReact/components/common/EmptyState/EmptyStatePattern';

const EmptyPage = ({ header }) => (
  <div className="host-details-tab-item">
    <PFEmptyPage
      icon="enterprise"
      header={header}
      description="This is a demo for adding content to the new host details page"
    />
  </div>
);

EmptyPage.propTypes = {
  header: PropTypes.string.isRequired,
};

export default EmptyPage;
