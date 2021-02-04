import React, { useEffect } from 'react';
import { shape, string, number, element, arrayOf } from 'prop-types';
import { Tab, Tabs, TabTitleText } from '@patternfly/react-core';
import { useHistory, useLocation } from 'react-router-dom';
import paramsFromHash from '../../utils/paramsFromHash';

/*
  Creates tabs that change url hash based on the tab selected.
  Also can show a subpage within a tab based on query params.
  The url format is: "/my/base/url#currentTab?subContentId=1"
  Influenced by https://github.com/ansible/awx/blob/devel/awx/ui_next/src/components/RoutedTabs/RoutedTabs.jsx
*/
const RoutedTabs = ({
  tabs, baseUrl, defaultTabIndex, titleComponent,
}) => {
  const history = useHistory();
  const { hash } = useLocation();
  const { hash: tabFromUrl, params: { subContentId } } = paramsFromHash(hash);

  const buildLink = tabKey => `${baseUrl}#${tabKey}`;

  const changeTab = (eventKey) => {
    const matchedTab = tabs.find(tab => tab.key === eventKey);
    if (matchedTab) {
      history.push(buildLink(matchedTab.key));
    } else {
      history.push(buildLink(tabs[defaultTabIndex].key)); // go to first tab if no tab selected
    }
  };

  const handleTabSelect = (_event, eventKey) => changeTab(eventKey);

  const getActiveTab = () => {
    const matchedTab = tabs.find(tab => tab.key === tabFromUrl);
    if (matchedTab) return matchedTab.key;

    return tabs[defaultTabIndex].key; // Default to first tab
  };

  // Useful when first navigating to the page, switches to default tab in url
  useEffect(() => {
    if (tabFromUrl !== getActiveTab()) changeTab(tabFromUrl);
  }, [tabFromUrl]);

  // Handle subroutes to show item's detail content while staying on a tab
  const showContent = (tab) => {
    const { content, detailContent } = tab;
    if (subContentId && detailContent) return detailContent;

    return content; // show main content if no subroute
  };

  return (
    <Tabs activeKey={getActiveTab()} onSelect={handleTabSelect}>
      {tabs.map((tab) => {
        const { key, title } = tab;

        return (
          <Tab
            aria-label={title}
            eventKey={key}
            key={key}
            title={titleComponent || <TabTitleText>{title}</TabTitleText>}
          >
            <div className="tab-body-with-spacing">
              {showContent(tab)}
            </div>
          </Tab>
        );
})}
    </Tabs>
  );
};

RoutedTabs.propTypes = {
  tabs: arrayOf(shape({
    key: string.isRequired,
    title: string.isRequired,
    content: element.isRequired,
  })).isRequired,
  baseUrl: string.isRequired,
  defaultTabIndex: number,
  titleComponent: element, // when you want to a custom tab title
};

RoutedTabs.defaultProps = {
  defaultTabIndex: 0,
  titleComponent: null,
};

export default RoutedTabs;
