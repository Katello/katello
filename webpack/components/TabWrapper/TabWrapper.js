import React from 'react';
import PropTypes from 'prop-types';
import { Tab, TabTitleText } from '@patternfly/react-core';
import './TabWrapper.scss';

// Wrapper for patternfly 4 tabs for styling and consistency purposes
const TabWrapper = ({ children, title, index }) => (
  <Tab
    aria-label={`${title} tab`}
    key={`${title}`}
    eventKey={index}
    title={<TabTitleText>{title}</TabTitleText>}
  >
    <div className="tab-body-with-spacing">
      {children}
    </div>
  </Tab>
);

TabWrapper.propTypes = {
  children: PropTypes.element.isRequired,
  title: PropTypes.string.isRequired,
  index: PropTypes.number.isRequired,
};

export default TabWrapper;
