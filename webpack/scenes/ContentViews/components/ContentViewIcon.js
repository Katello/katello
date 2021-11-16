import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { EnterpriseIcon, RegistryIcon } from '@patternfly/react-icons';
import './contentViewIcon.scss';

const ContentViewIcon = ({ composite, count, description }) => {
  const props = {
    title: composite ? __('Composite') : __('Component'),
    className: composite ? 'svg-icon-composite' : 'svg-icon-component',
  };
  return (
    <div aria-label="content_view_icon" className="svg-centered-container">
      {count && <span className="composite-component-count">{count}</span>}
      {composite ? <RegistryIcon size="md" {...props} /> : <EnterpriseIcon size="sm" {...props} />}
      <span>{description}</span>
    </div>
  );
};

ContentViewIcon.propTypes = {
  composite: PropTypes.bool,
  count: PropTypes.node,
  description: PropTypes.node,
};

ContentViewIcon.defaultProps = {
  composite: false,
  count: null,
  description: null,
};

export default ContentViewIcon;
