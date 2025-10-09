import React, { useState } from 'react';
import {
  Title,
  Grid,
  GridItem,
  Flex,
  FlexItem,
  Tabs,
  Tab,
  TabTitleText,
} from '@patternfly/react-core';
import { SyncAltIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import FontAwesomeImageModeIcon from '../../components/extensions/Hosts/FontAwesomeImageModeIcon';

const ContainerImagesPage = () => {
  const [activeTabKey, setActiveTabKey] = useState(0);

  const handleTabClick = (event, tabIndex) => {
    setActiveTabKey(tabIndex);
  };

  return (
    <Grid hasGutter span={12} style={{ padding: '24px' }}>
      <GridItem span={12}>
        <Flex alignItems={{ default: 'alignItemsCenter' }} spaceItems={{ default: 'spaceItemsSm' }}>
          <FlexItem>
            <Title headingLevel="h1" size="2xl" ouiaId="container-images-title">
              Container images
            </Title>
          </FlexItem>
        </Flex>
      </GridItem>
      <GridItem span={12}>
        <Tabs
          activeKey={activeTabKey}
          onSelect={handleTabClick}
          ouiaId="container-images-tabs"
        >
          <Tab
            eventKey={0}
            title={<TabTitleText><SyncAltIcon style={{ marginRight: '10px' }} />{__('Synced')}</TabTitleText>}
            ouiaId="container-images-synced-tab"
          />
          <Tab
            eventKey={1}
            title={<TabTitleText><span style={{ marginRight: '10px' }}><FontAwesomeImageModeIcon /></span>{__('Booted')}</TabTitleText>}
            ouiaId="container-images-booted-tab"
          />
        </Tabs>
      </GridItem>
      <GridItem span={12}>
        {activeTabKey === 0 && (
        <div>{__('Synced container images content')}</div>
        )}
        {activeTabKey === 1 && (
        <div>{__('Booted container images content')}</div>
        )}
      </GridItem>
    </Grid>
  );
};

export default ContainerImagesPage;
