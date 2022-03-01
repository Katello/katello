import React, { useState } from 'react';
import {
  Badge,
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  Dropdown,
  ExpandableSection,
  KebabToggle,
  Flex,
  FlexItem,
  GridItem,
  DropdownItem,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import { useSet } from '../../../Table/TableHooks';

const HostCollectionsDetails = ({
  hostCollections,
}) => {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const toggleBulkAction = () => setIsDropdownOpen(prev => !prev);

  const expandedHostCollections = useSet([]);
  const openAddHostCollectionsModal = () => {}; // TODO: implement
  const openRemoveHostCollectionsModal = () => {}; // TODO: implement

  const dropdownItems = [
    <DropdownItem
      aria-label="add_host_to_collections"
      key="add_host_to_collections"
      component="button"
      isDisabled
      onClick={openAddHostCollectionsModal}
    >
      {__('Add host to collections')}
    </DropdownItem>,
    <DropdownItem
      aria-label="remove_host_from_collections"
      key="remove_host_from_collections"
      component="button"
      isDisabled
      onClick={openRemoveHostCollectionsModal}
    >
      {__('Remove host from collections')}
    </DropdownItem>,
  ];

  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3} >
      <Card isHoverable>
        <CardHeader>
          <Flex
            alignItems={{ default: 'alignItemsCenter' }}
            justifyContent={{ default: 'justifyContentSpaceBetween' }}
            style={{ width: '100%' }}
          >
            <FlexItem>
              <Flex
                alignItems={{ default: 'alignItemsCenter' }}
                justifyContent={{ default: 'justifyContentSpaceBetween' }}
              >
                <FlexItem>
                  <CardTitle>{__('Host collections')}</CardTitle>
                </FlexItem>
                <FlexItem>
                  {!!hostCollections?.length && <Badge isRead>{hostCollections.length}</Badge>}
                </FlexItem>
              </Flex>
            </FlexItem>
            <FlexItem>
              <Dropdown
                toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
                isOpen={isDropdownOpen}
                isPlain
                position="right"
                dropdownItems={dropdownItems}
              />
            </FlexItem>
          </Flex>
        </CardHeader>
        <CardBody>
          {hostCollections?.map((hostCollection) => {
            const {
              id, name, description, maxHosts, unlimitedHosts, totalHosts,
            } = propsToCamelCase(hostCollection);
            const isExpanded = expandedHostCollections.has(id);
            return (
              <Flex
                alignItems={{ default: 'alignItemsBaseline' }}
                justifyContent={{ default: 'justifyContentSpaceBetween' }}
                direction={{ default: 'row' }}
                flexWrap={{ default: 'nowrap' }}
                key={id}
              >
                <FlexItem
                  grow={{ default: 'grow' }}
                  style={{ whiteSpace: 'pre-line' }}
                >
                  <ExpandableSection
                    toggleText={name}
                    onToggle={() => expandedHostCollections.onToggle(!isExpanded, id)}
                    isExpanded={isExpanded}
                    isIndented
                  >
                    <div style={{ fontSize: '14px' }}>
                      {description || <span style={{ color: '#c1c1c1' }}>{__('No description provided')}</span>}
                    </div>
                  </ExpandableSection>
                </FlexItem>
                <FlexItem component="span">
                  {totalHosts}/{unlimitedHosts ? 'unlimited' : maxHosts}
                </FlexItem>
              </Flex>
            );
          })}
        </CardBody>
      </Card>
    </GridItem>
  );
};

const HostCollectionsCard = ({ hostDetails }) => {
  if (hostDetails) {
    return <HostCollectionsDetails {...propsToCamelCase(hostDetails)} />;
  }
  return null;
};

HostCollectionsDetails.propTypes = {
  hostCollections: PropTypes.arrayOf(PropTypes.shape({})),
};

HostCollectionsDetails.defaultProps = {
  hostCollections: [],
};

HostCollectionsCard.propTypes = {
  hostDetails: PropTypes.shape({}),
};

HostCollectionsCard.defaultProps = {
  hostDetails: null,
};

export default HostCollectionsCard;
