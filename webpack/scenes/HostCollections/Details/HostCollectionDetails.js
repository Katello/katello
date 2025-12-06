import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useParams } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import {
  Breadcrumb,
  BreadcrumbItem,
  Grid,
  GridItem,
  Label,
  Panel,
  PageSection,
  Flex,
  FlexItem,
  Split,
  SplitItem,
  Tabs,
  Tab,
  TabTitleText,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  DropdownToggle,
  DropdownSeparator,
} from '@patternfly/react-core/deprecated';
import { CaretDownIcon } from '@patternfly/react-icons';
import { getHostCollection } from './HostCollectionDetailsActions';
import DetailsTab from './DetailsTab/DetailsTab';
import HostsTab from './HostsTab/HostsTab';
import InactiveText from '../../ContentViews/components/InactiveText';
import CopyHostCollectionModal from '../Copy/CopyHostCollectionModal';
import DeleteHostCollectionModal from '../Delete/DeleteHostCollectionModal';
import './HostCollectionDetails.scss';

const HostCollectionDetails = () => {
  const dispatch = useDispatch();
  const { id } = useParams();
  const [activeTabKey, setActiveTabKey] = useState(() => {
    const hash = window.location.hash.replace('#', '');
    return hash || 'details';
  });
  const [isActionsOpen, setIsActionsOpen] = useState(false);
  const [isCopyModalOpen, setIsCopyModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);

  const hostCollectionResponse = useSelector(state =>
    selectAPIResponse(state, `HOST_COLLECTION_DETAILS_${id}`));
  const hostCollection = propsToCamelCase(hostCollectionResponse);

  useEffect(() => {
    if (id) {
      dispatch(getHostCollection(id));
    }
  }, [id, dispatch]);

  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash.replace('#', '');
      if (hash) {
        setActiveTabKey(hash);
      }
    };

    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  const handleTabSelect = (_event, tabKey) => {
    setActiveTabKey(tabKey);
    window.location.hash = tabKey;
  };

  const hostCountLabel = () => {
    const total = hostCollection?.totalHosts || 0;
    const max = hostCollection?.unlimitedHosts ? __('Unlimited') : hostCollection?.maxHosts;
    return `${total}/${max}`;
  };

  return (
    <div id="host-collection-details">
      <Panel className="host-collection-details-header">
        <div className="breadcrumb-bar-pf4">
          <Breadcrumb ouiaId="host-collection-breadcrumbs">
            <BreadcrumbItem to="/labs/host_collections">
              {__('Host Collections')}
            </BreadcrumbItem>
            <BreadcrumbItem isActive>
              {hostCollection?.name || '...'}
            </BreadcrumbItem>
          </Breadcrumb>
        </div>
        <Grid hasGutter>
          <GridItem span={8}>
            <Flex
              alignItems={{ default: 'alignItemsCenter' }}
              spaceItems={{ default: 'spaceItemsSm' }}
            >
              <FlexItem>
                <h2>{hostCollection?.name}</h2>
              </FlexItem>
              <FlexItem>
                <Label color="blue">
                  {hostCountLabel()}
                </Label>
              </FlexItem>
            </Flex>
          </GridItem>
          <GridItem span={4}>
            <Flex justifyContent={{ default: 'justifyContentFlexEnd' }}>
              <FlexItem>
                <Dropdown
                  onSelect={() => setIsActionsOpen(false)}
                  isOpen={isActionsOpen}
                  toggle={
                    <DropdownToggle
                      onToggle={(_event, isOpen) => setIsActionsOpen(isOpen)}
                      toggleIndicator={CaretDownIcon}
                      ouiaId="host-collection-actions-dropdown"
                    >
                      {__('Actions')}
                    </DropdownToggle>
                  }
                  dropdownItems={[
                    <DropdownItem
                      key="copy"
                      onClick={() => {
                        setIsCopyModalOpen(true);
                        setIsActionsOpen(false);
                      }}
                      ouiaId="copy-action"
                    >
                      {__('Copy')}
                    </DropdownItem>,
                    <DropdownSeparator key="separator" ouiaId="actions-separator" />,
                    <DropdownItem
                      key="delete"
                      onClick={() => {
                        setIsDeleteModalOpen(true);
                        setIsActionsOpen(false);
                      }}
                      ouiaId="delete-action"
                    >
                      {__('Delete')}
                    </DropdownItem>,
                  ]}
                  ouiaId="host-collection-actions"
                />
              </FlexItem>
            </Flex>
          </GridItem>
        </Grid>
        <div className="host-collection-description">
          {hostCollection?.description ?
            <TextContent>
              <Text component={TextVariants.p} ouiaId="host-collection-description">
                {hostCollection.description}
              </Text>
            </TextContent> :
            <InactiveText text={__('No description')} />
          }
        </div>
      </Panel>

      <PageSection className="host-collection-tabs-section">
        <Tabs
          activeKey={activeTabKey}
          onSelect={handleTabSelect}
          ouiaId="host-collection-tabs"
        >
          <Tab
            eventKey="details"
            title={<TabTitleText>{__('Details')}</TabTitleText>}
            ouiaId="details-tab"
          >
            <DetailsTab hostCollection={hostCollection} hostCollectionId={id} />
          </Tab>
          <Tab
            eventKey="hosts"
            title={<TabTitleText>{__('Hosts')}</TabTitleText>}
            ouiaId="hosts-tab"
          >
            <HostsTab hostCollectionId={id} />
          </Tab>
        </Tabs>
      </PageSection>

      {/* Modals */}
      {hostCollection?.name && (
        <>
          <CopyHostCollectionModal
            isOpen={isCopyModalOpen}
            onClose={() => setIsCopyModalOpen(false)}
            hostCollection={{ id: parseInt(id, 10), name: hostCollection.name }}
          />
          <DeleteHostCollectionModal
            isOpen={isDeleteModalOpen}
            onClose={() => setIsDeleteModalOpen(false)}
            hostCollection={{ id: parseInt(id, 10), name: hostCollection.name }}
          />
        </>
      )}
    </div>
  );
};

export default HostCollectionDetails;
