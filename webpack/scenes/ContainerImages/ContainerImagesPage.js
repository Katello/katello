import React, { useState } from 'react';
import { useHistory, useLocation } from 'react-router-dom';
import {
  Title,
  PageSection,
  PageSectionVariants,
  Tabs,
  Tab,
  TabTitleText,
  TabTitleIcon,
  Popover,
  Button,
} from '@patternfly/react-core';
import { SyncAltIcon, OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import FontAwesomeImageModeIcon from '../../components/extensions/Hosts/FontAwesomeImageModeIcon';
import BootedContainerImagesPage from './Booted/BootedContainerImagesPage';
import SyncedContainerImagesPage from './Synced/SyncedContainerImagesPage';
import './ContainerImagesPage.scss';

const ContainerImagesPage = () => {
  const [activeTabKey, setActiveTabKey] = useState(0);
  const history = useHistory();
  const location = useLocation();

  const handleTabClick = (event, tabIndex) => {
    setActiveTabKey(tabIndex);
    history.replace(location.pathname);
  };

  return (
    <>
      <PageSection
        id="container-images-title-section"
        variant={PageSectionVariants.light}
      >
        <Title headingLevel="h1" size="2xl" ouiaId="container-images-title">
          {__('Container Images')}
          <Popover
            headerContent={<div>{__('Container Images')}</div>}
            bodyContent={
              <div>
                {__('View container images in the local registry using the Synced tab. View container images booted by image mode hosts using the Booted tab. The Booted tab also shows images outside of the local container registry.')}
              </div>
            }
          >
            <Button variant="plain" aria-label="Help" isInline icon={<OutlinedQuestionCircleIcon size="sm" />} ouiaId="container-images-help-button" />
          </Popover>
        </Title>
      </PageSection>
      <PageSection
        id="container-images-tabs-section"
        variant={PageSectionVariants.light}
      >
        <Tabs
          activeKey={activeTabKey}
          onSelect={handleTabClick}
          ouiaId="container-images-tabs"
        >
          <Tab
            eventKey={0}
            title={
              <>
                <TabTitleIcon><SyncAltIcon /></TabTitleIcon>
                <TabTitleText>{__('Synced')}</TabTitleText>
              </>
            }
            ouiaId="container-images-synced-tab"
          />
          <Tab
            eventKey={1}
            title={
              <>
                <TabTitleIcon><FontAwesomeImageModeIcon /></TabTitleIcon>
                <TabTitleText>{__('Booted')}</TabTitleText>
              </>
            }
            ouiaId="container-images-booted-tab"
          />
        </Tabs>
      </PageSection>
      <PageSection
        id="container-images-content-section"
        variant={PageSectionVariants.light}
        className="container-images-page"
      >
        {activeTabKey === 0 && <SyncedContainerImagesPage />}
        {activeTabKey === 1 && <BootedContainerImagesPage />}
      </PageSection>
    </>
  );
};

export default ContainerImagesPage;
