import React from 'react';
import { shape, string, number, arrayOf } from 'prop-types';
import { Tab, Tabs, TabTitleText } from '@patternfly/react-core';
import { useHistory, useParams } from 'react-router-dom';
import "./RoutedTabs.scss";

// Influenced by https://github.com/ansible/awx/blob/devel/awx/ui_next/src/components/RoutedTabs/RoutedTabs.jsx
const RoutedTabs = ({ tabs }) => {
  const history = useHistory();
  const { tab: routedTab, subContentId } = useParams();

  const getActiveTab = () => {
    const matchedTab = tabs.find(tab => tab.key === routedTab);
    if (matchedTab) return matchedTab.key;

    return tabs[0].key; // Default to first tab
  };

  const handleTabSelect = (_event, eventKey) => {
    const matchedTab = tabs.find(tab => tab.key === eventKey);
    if (matchedTab) {
      history.push(matchedTab.link);
    } else {
      history.push(tabs[0].link); // go to first tab if no tab selected
    }
  }

  // Handle subroutes to show item's detail content while staying on a tab
  const showContent = (tab) => {
    const { content, detailContent } = tab
    if (subContentId && detailContent) return detailContent;

    return content // show main content if no subroute
  }

  return (
    <Tabs activeKey={getActiveTab()} onSelect={handleTabSelect}>
      {tabs.map(tab => {
        const { key, link, title } = tab;

        return (
          <Tab
            aria-label={title}
            eventKey={key}
            key={key}
            link={link}
            title={<TabTitleText>{title}</TabTitleText>}
          >
            <div className="tab-body-with-spacing">
              {showContent(tab)}
            </div>
          </Tab>
        )}
      )}
    </Tabs>
  );
}

RoutedTabs.propTypes = {
  tabs: arrayOf(
    shape({
      key: string.isRequired,
      link: string.isRequired,
      title: string.isRequired,
    })
  ).isRequired,
  defaultTab: number,
};

RoutedTabs.defaultProps = {
  defaultTab: 0,
}

export default RoutedTabs;