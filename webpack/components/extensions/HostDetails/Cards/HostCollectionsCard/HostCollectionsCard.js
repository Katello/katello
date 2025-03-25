import React, { useState } from 'react';
import {
  Badge,
  Button,
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  ExpandableSection,
  Flex,
  FlexItem,
  GridItem,
} from '@patternfly/react-core';
import {
  Dropdown,
  KebabToggle,
  DropdownItem,
} from '@patternfly/react-core/deprecated';
import { PlusCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import { useSet } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { HostCollectionsAddModal, HostCollectionsRemoveModal } from './HostCollectionsModal';
import { hasRequiredPermissions, hostIsRegistered, userPermissionsFromHostDetails } from '../../hostDetailsHelpers';
import EmptyStateMessage from '../../../../Table/EmptyStateMessage';
import './HostCollectionsCard.scss';

const requiredPermissions = ['edit_hosts', 'view_host_collections'];

const HostCollectionsDetails = ({
  hostCollections, id: hostId, name: hostName,
  showKebab,
}) => {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const toggleBulkAction = () => setIsDropdownOpen(prev => !prev);

  const expandedHostCollections = useSet([]);
  const hostCollectionIds = hostCollections?.map(({ id }) => id) ?? [];

  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const closeAddModal = () => setIsAddModalOpen(false);
  const [isRemoveModalOpen, setIsRemoveModalOpen] = useState(false);
  const closeRemoveModal = () => setIsRemoveModalOpen(false);

  const openAddHostCollectionsModal = () => {
    setIsDropdownOpen(false);
    setIsAddModalOpen(true);
  };
  const openRemoveHostCollectionsModal = () => {
    setIsDropdownOpen(false);
    setIsRemoveModalOpen(true);
  };

  const dropdownItems = [
    <DropdownItem
      aria-label="add_host_to_collections"
      ouiaId="add_host_to_collections"
      key="add_host_to_collections"
      component="button"
      onClick={openAddHostCollectionsModal}
    >
      {__('Add host to collections')}
    </DropdownItem>,
    <DropdownItem
      aria-label="remove_host_from_collections"
      ouiaId="remove_host_from_collections"
      key="remove_host_from_collections"
      component="button"
      isDisabled={!hostCollections.length}
      onClick={openRemoveHostCollectionsModal}
    >
      {__('Remove host from collections')}
    </DropdownItem>,
  ];

  const primaryActionButton =
    (
      <Button
        ouiaId="add-to-a-host-collection-button"
        onClick={openAddHostCollectionsModal}
        variant="secondary"
        aria-label="add_to_a_host_collection"
      > {__('Add to a host collection')}
      </Button>);

  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3}>
      <Card ouiaId="host-collections-card">
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
            {showKebab && hostCollections?.length > 0 && (
              <FlexItem>
                <Dropdown
                  toggle={<KebabToggle aria-label="host_collections_bulk_actions" onToggle={toggleBulkAction} />}
                  ouiaId="host-collections-bulk-actions-dropdown"
                  isOpen={isDropdownOpen}
                  isPlain
                  position="right"
                  dropdownItems={dropdownItems}
                />
              </FlexItem>)
            }
          </Flex>
        </CardHeader>
        <CardBody className={`host-collection-card-body${hostCollections?.length === 0 ? ' empty' : ''}`}>
          {hostCollections?.length === 0 &&
            <EmptyStateMessage
              title={__('No host collections yet')}
              body={__('To get started, add this host to a host collection.')}
              customIcon={PlusCircleIcon}
              showPrimaryAction
              primaryActionButton={primaryActionButton}
            />
          }
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
                <FlexItem component="span" spacer={{ default: 'spacerXl' }}>
                  {totalHosts}/{unlimitedHosts ? 'unlimited' : maxHosts}
                </FlexItem>
              </Flex>
            );
          })}
        </CardBody>
      </Card>
      {hostId &&
        <>
          <HostCollectionsAddModal
            isOpen={isAddModalOpen}
            closeModal={closeAddModal}
            hostId={hostId}
            key={`hc-add-modal-${hostId}`}
            hostName={hostName}
            existingHostCollectionIds={hostCollectionIds}
          />
          <HostCollectionsRemoveModal
            isOpen={isRemoveModalOpen}
            closeModal={closeRemoveModal}
            hostId={hostId}
            key={`hc-remove-modal-${hostId}`}
            hostName={hostName}
            existingHostCollectionIds={hostCollectionIds}
          />
        </>
      }
    </GridItem>
  );
};

const HostCollectionsCard = ({ hostDetails }) => {
  if (hostIsRegistered({ hostDetails })) {
    const showKebab =
      hasRequiredPermissions(requiredPermissions, userPermissionsFromHostDetails({ hostDetails }));
    return <HostCollectionsDetails showKebab={showKebab} {...propsToCamelCase(hostDetails)} />;
  }
  return null;
};

HostCollectionsDetails.propTypes = {
  hostCollections: PropTypes.arrayOf(PropTypes.shape({})),
  id: PropTypes.number,
  name: PropTypes.string,
  showKebab: PropTypes.bool,
};

HostCollectionsDetails.defaultProps = {
  hostCollections: [],
  id: null,
  name: '',
  showKebab: false,
};

HostCollectionsCard.propTypes = {
  hostDetails: PropTypes.shape({
    permissions: PropTypes.shape({}),
    contentFacetAttributes: PropTypes.shape({
      permissions: PropTypes.shape({}),
    }),
  }),
};

HostCollectionsCard.defaultProps = {
  hostDetails: {
    permissions: {},
    contentFacetAttributes: {
      permissions: {},
    },
  },
};

export default HostCollectionsCard;
