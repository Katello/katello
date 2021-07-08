import React, { useState } from 'react';
import EmptyPage from 'foremanReact/components/common/EmptyState/EmptyStatePattern';
import { Tabs, Tab, TabTitleText } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const tabs = [
  {
    key: 'packages',
    title: __('Packages'),
    content: <EmptyPage
      icon="enterprise"
      header="WIP Packages"
      description="This is a demo for adding content to the new host details page"
    />,
  },
  {
    key: 'errata',
    title: __('Errata'),
    content: <EmptyPage
      icon="enterprise"
      header="WIP Errata"
      description="This is a demo for adding content to the new host details page"
    />,
  },
  {
    key: 'modulestreams',
    title: __('Module Streams'),
    content: <EmptyPage
      icon="enterprise"
      header="WIP Module Streams"
      description="This is a demo for module streams on new host details page"
    />,
  },
];

const ContentTab = () => {
  const [activeTab, setActiveTab] = useState(tabs[0].key);
  const handleTabClick = (event, tabIndex) => setActiveTab(tabIndex);
  return (
    <Tabs
      isSecondary
      activeKey={activeTab}
      onSelect={handleTabClick}
    >

      { tabs.map(tab => (
        <Tab eventKey={tab.key} title={<TabTitleText>{tab.title}</TabTitleText>}>
          {tab.content}
        </Tab>
            ))
          }
    </Tabs>
  );
};

export default ContentTab;
