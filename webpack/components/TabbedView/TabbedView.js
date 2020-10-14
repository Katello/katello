import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import './TabbedView.scss';

const TabbedView = ({ tabs }) => {
  const [activeTabKey, setActiveTabKey] = useState('details');
  const [openedTabs, setOpenedTabs] = useState([]);
  const handleTabClick = (_event, tabIndex) => {
    setOpenedTabs(origTabs => [...origTabs, tabIndex]);
    setActiveTabKey(tabIndex);
  };

  return (
    <Tabs activeKey={activeTabKey} onSelect={handleTabClick}>
      {tabs.map((tab) => {
        const { title, content } = tab;
        const lowerCaseTitle = title.toLowerCase();
        // Load if tab is clicked on and keep loaded to prevent re-loading tab content.
        const load = activeTabKey === lowerCaseTitle || openedTabs.includes(lowerCaseTitle);

        return (
          <Tab
            aria-label={`${lowerCaseTitle} tab`}
            key={lowerCaseTitle}
            eventKey={lowerCaseTitle}
            title={<TabTitleText>{title}</TabTitleText>}
          >
            <div className="tab-body-with-spacing">
              {load && content}
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
