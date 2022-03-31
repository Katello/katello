import React from 'react';
import { shape, string, number, element, arrayOf } from 'prop-types';
import { Tab, Tabs, TabTitleText } from '@patternfly/react-core';
import { Switch, Route, Redirect, useHistory, useLocation, withRouter, HashRouter } from 'react-router-dom';
import { head, last } from 'lodash';

const RoutedTabs = ({
  tabs, defaultTabIndex,
}) => {
  const { push } = useHistory();
  const {
    hash, key: locationKey,
  } = useLocation();

  // The below transforms #/history/6 to history
  const currentTabFromUrl = head(last(hash.split('#/')).split('/'));
  // Allows navigation back to mainTab
  const onSubTab = currentTabFromUrl !== last(last(hash.split('#/')).split('/'));

  const onSelect = (e, key) => {
    e.preventDefault();
    // See the below links for understanding of this mouseEvent
    // https://www.w3schools.com/jsref/event_which.asp
    // https://www.w3schools.com/jsref/event_button.asp
    const middleMouseButtonNotUsed = !(e.button === 1 || e.buttons === 4 || e.which === 2);
    const notCurrentTab = currentTabFromUrl !== key;
    if (middleMouseButtonNotUsed && (notCurrentTab || !!onSubTab)) {
      push(`#/${key}`);
    }
  };

  return (
    <>
      <Tabs
        activeKey={currentTabFromUrl}
        className="margin-0-24"
      >
        {tabs.map(({ key, title }) => (
          <a
            key={key}
            href={`#/${key}`}
            onMouseUp={e => onSelect(e, key)}
            style={{ textDecoration: 'none' }}
          >
            <Tab
              eventKey={key}
              aria-label={title}
              title={<TabTitleText>{title}</TabTitleText>}
            />
          </a>
        ))}
      </Tabs>
      <div className="margin-16-0">
        <HashRouter key={locationKey}>
          <Switch>
            {tabs.map(({ key, content }) => (
              <Route key={`${key}-route`} path={`/${key}`}>
                {content}
              </Route>))}
            <Redirect to={`/${currentTabFromUrl || tabs[defaultTabIndex]?.key}`} />
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
};

RoutedTabs.defaultProps = {
  defaultTabIndex: 0,
};

export default withRouter(RoutedTabs);

