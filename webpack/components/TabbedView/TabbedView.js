import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import './TabbedView.scss';

const TabbedView = ({ tabs }) => {
  const [activeTabKey, setActiveTabKey] = useState(0);
  const handleTabClick = (_event, tabIndex) => setActiveTabKey(tabIndex);

  return (
    <Tabs activeKey={activeTabKey} onSelect={handleTabClick}>
      {tabs.map((tab, i) => {
        const { title, content } = tab;
        return (
          <Tab
            aria-label={`${title} tab`}
            key={`${title}`}
            eventKey={i}
            title={<TabTitleText>{title}</TabTitleText>}
          >
            <div className="tab-body-with-spacing">
              {content}
            </div>
          </Tab>
        );
      })}
    </Tabs>
  );
};

TabbedView.propTypes = {
  tabs: PropTypes.arrayOf(PropTypes.shape({
    title: PropTypes.string,
    content: PropTypes.element,
  })).isRequired,
};

export default TabbedView;
