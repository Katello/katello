import React from 'react';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';
import { Tabs, Tab, TabTitleText, PageSection } from '@patternfly/react-core';
import { useSelector } from 'react-redux';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import SecondaryTabRoutes from './SecondaryTabsRoutes';
import { activeTab } from './helpers';
import SECONDARY_TABS from './constants';

const ContentTab = ({ location: { pathname } }) => {
  const hashHistory = useHistory();
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const filteredTabs =
    SECONDARY_TABS?.filter(tab => !tab.hideTab?.({ hostDetails })) ?? [];
  return (
    <PageSection
      variant="light"
      padding={{ default: 'noPadding' }}
      className="host-content-tabs-section"
    >
      <Tabs
        id="host-content-tabs"
        ouiaId="host-content-tabs"
        className="margin-0-24"
        onSelect={(evt, subTab) => hashHistory.push(subTab)}
        isSecondary
        activeKey={activeTab(pathname)}
      >
        {filteredTabs.map(({ key, title }) => (
          <Tab
            ouiaId={`host-content-tabs-tab-${key}`}
            key={key}
            eventKey={key}
            title={<TabTitleText>{title}</TabTitleText>}
          />
        ))}
      </Tabs>
      <SecondaryTabRoutes />
    </PageSection>

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
