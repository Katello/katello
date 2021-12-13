import React from 'react';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import SecondaryTabRoutes from './SecondaryTabsRoutes';
import { activeTab } from './helpers';
import SECONDARY_TABS from './constants';

const ContentTab = ({ location: { pathname } }) => {
  const hashHistory = useHistory();
  return (
    <>
      <Tabs
        className="margin-0-24"
        onSelect={(evt, subTab) => hashHistory.push(subTab)}
        isSecondary
        activeKey={activeTab(pathname)}
      >
        {SECONDARY_TABS.map(({ key, title }) => (
          <Tab
            key={key}
            eventKey={key}
            title={<TabTitleText>{title}</TabTitleText>}
          />
        ))}
      </Tabs>
      <SecondaryTabRoutes />
    </>
  );
};

ContentTab.propTypes = {
  location: PropTypes.shape({
    pathname: PropTypes.string,
  }),
};
ContentTab.defaultProps = {
  location: { pathname: '' },
};

export default ContentTab;
