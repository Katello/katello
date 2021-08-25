import React from 'react';
import PropTypes from 'prop-types';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import SecondaryTabRoutes from './SecondaryTabsRoutes';
import { hashRoute, activeTab } from './helpers';
import SECONDARY_TABS from './constants';

const ContentTab = ({ location: { pathname } }) => (
  <>
    <Tabs isSecondary activeKey={activeTab(pathname)}>
      {SECONDARY_TABS.map(({ key, title }) => (
        <Tab
          key={key}
          eventKey={key}
          title={<TabTitleText>{title}</TabTitleText>}
          href={hashRoute(key)}
        />
      ))}
    </Tabs>
    <SecondaryTabRoutes />
  </>
);

ContentTab.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string,
  }),
};
ContentTab.defaultProps = {
  location: { pathname: '' },
};

export default ContentTab;
