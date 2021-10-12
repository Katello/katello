import React from 'react';
import { shape, string, number, element, arrayOf } from 'prop-types';
import { Tab, Tabs, TabTitleText } from '@patternfly/react-core';
import { Switch, Route, Redirect, useHistory, useLocation, withRouter, HashRouter } from 'react-router-dom';
import { head, last } from 'lodash';

const RoutedTabs = ({
  tabs, defaultTabIndex, titleComponent,
}) => {
  const { push } = useHistory();
  const {
    hash, key: locationKey,
  } = useLocation();

  // The below transforms #/filters/6 to filters
  const currentTabFromUrl = head(last(hash.split('#/')).split('/'));

  const onSelect = (_e, eventKey) => {
    // This prevents needless pushing on repeated clicks of a tab
    if (hash.slice(2) !== eventKey) {
      push(`#/${eventKey}`);
    }
  };

  return (
    <>
      <Tabs
        activeKey={currentTabFromUrl}
        onSelect={onSelect}
      >
        {tabs.map(({ key, title }) =>
        (
          <Tab
            aria-label={title}
            eventKey={key}
            key={key}
            title={titleComponent || <TabTitleText>{title}</TabTitleText>}
          />
        ))}
      </Tabs>
      <div className="tab-body-with-spacing">
        <HashRouter key={locationKey}>
          <Switch>
            {tabs.map(({ key, content }) => (
              <Route key={`${key}-route`} path={`/${key}`}>
                {content}
              </Route>))}
            <Redirect to={`/${currentTabFromUrl || tabs[defaultTabIndex].key}`} />
          </Switch>
        </HashRouter>
      </div>
    </>
  );
};

RoutedTabs.propTypes = {
  tabs: arrayOf(shape({
    key: string.isRequired,
    title: string.isRequired,
    content: element.isRequired,
  })).isRequired,
  defaultTabIndex: number,
  titleComponent: element, // when you want to add a custom tab title
};

RoutedTabs.defaultProps = {
  defaultTabIndex: 0,
  titleComponent: null,
};

export default withRouter(RoutedTabs);

