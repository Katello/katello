import React, { useState } from 'react';
import EmptyPage from 'foremanReact/components/common/EmptyState/EmptyStatePattern';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const ContentTab = () => {
  const [activeTab, setActiveTab] = useState('packages');
  const handleTabClick = (event, tabIndex) => setActiveTab(tabIndex);
  return (
    <Tabs
      isSecondary
      activeKey={activeTab}
      onSelect={handleTabClick}
    >
      <Tab eventKey="packages" title={<TabTitleText>{ __('Packages')}</TabTitleText>}>
        <EmptyPage
          icon="enterprise"
          header="WIP Packages"
          description="This is a demo for adding content to the new host details page"
        />
      </Tab>

      <Tab eventKey="errata" title={<TabTitleText>{ __('Errata')}</TabTitleText>}>
        <EmptyPage
          icon="enterprise"
          header="WIP Errata"
          description="This is a demo for adding content to the new host details page"
        />
      </Tab>

      <Tab eventKey="modulestreams" title={<TabTitleText>{ __('Module Streams')}</TabTitleText>}>
        <EmptyPage
          icon="enterprise"
          header="WIP Module Streams"
          description="This is a demo for module streams on new host details page"
        />
      </Tab>
    </Tabs>
  );
};

export default ContentTab;
