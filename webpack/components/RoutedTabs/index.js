import React from 'react';
import { shape, string, number, element, arrayOf } from 'prop-types';
import { Tab, Tabs, TabTitleText } from '@patternfly/react-core';
import { Switch, Route, Redirect, useHistory, useLocation, withRouter } from 'react-router-dom';
import { head } from 'lodash';

const RoutedTabs = ({
  tabs, baseUrl, defaultTabIndex, titleComponent,
}) => {
  const history = useHistory();
  const { pathname } = useLocation();
  const getCurrentTabFromUrl = () =>
    head(pathname?.replace(`${baseUrl}/`, '').split('/'));

  return (
    <>
      <Tabs
        activeKey={getCurrentTabFromUrl()}
        onSelect={(_e, eventKey) => {
          history.push(`${baseUrl}/${eventKey}`);
        }}
      >
        {tabs.map((tab) => {
          const { key, title } = tab;
          return (
            <Tab
              aria-label={title}
              eventKey={key}
              key={key}
              title={titleComponent || <TabTitleText>{title}</TabTitleText>}
            />
          );
        })}
      </Tabs>
      <div className="tab-body-with-spacing">
        <Switch>
          {tabs.map(({ key, content }) => (
            <Route key={`${key}-route`} path={`/labs/content_views/:id([0-9]+)/${key}`}>
              {content}
            </Route>))}
          <Redirect exact to={`${baseUrl}/${tabs[defaultTabIndex].key}`} />
        </Switch>
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
  baseUrl: string.isRequired,
  defaultTabIndex: number,
  titleComponent: element, // when you want to a custom tab title
};

RoutedTabs.defaultProps = {
  defaultTabIndex: 0,
  titleComponent: null,
};

export default withRouter(RoutedTabs);

