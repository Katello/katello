import React, { useState } from 'react';
import {
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  Dropdown,
  DropdownItem,
  Flex,
  FlexItem,
  GridItem,
  KebabToggle,
  Label,
  Tooltip,
} from '@patternfly/react-core';
import { FormattedMessage } from 'react-intl';

import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import ContentViewIcon from '../../../../../scenes/ContentViews/components/ContentViewIcon';
import { hasRequiredPermissions, hostIsRegistered } from '../../hostDetailsHelpers';
import ChangeHostCVModal from './ChangeHostCVModal';

const requiredPermissions = [
  'view_lifecycle_environments', 'view_content_views',
  'promote_or_remove_content_views_to_environments',
];

const HostContentViewDetails = ({
  contentView, lifecycleEnvironment, contentViewVersionId, contentViewDefault,
  contentViewVersion, contentViewVersionLatest, hostId, hostName, orgId, hostEnvId,
  hostPermissions, permissions,
}) => {
  let versionLabel = `Version ${contentViewVersion}`;
  if (contentViewVersionLatest) {
    versionLabel += ' (latest)';
  }

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const toggleHamburger = () => setIsDropdownOpen(prev => !prev);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const closeModal = () => setIsModalOpen(false);
  const openModal = () => {
    setIsDropdownOpen(false);
    setIsModalOpen(true);
  };

  const userPermissions = { ...hostPermissions, ...permissions };
  const showKebab = hasRequiredPermissions(requiredPermissions, userPermissions);

  const dropdownItems = [
    <DropdownItem
      aria-label="change-host-content-view"
      ouiaId="change-host-content-view"
      key="change-host-content-view"
      component="button"
      onClick={openModal}
    >
      {__('Edit content view assignment')}
    </DropdownItem>,
  ];

  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3} >
      <Card ouiaId="content-view-details-card">
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
                  <CardTitle>{__('Content view details')}</CardTitle>
                </FlexItem>
              </Flex>
            </FlexItem>
            {showKebab && (
              <FlexItem>
                <Dropdown
                  toggle={<KebabToggle aria-label="change_content_view_hamburger" onToggle={toggleHamburger} />}
                  isOpen={isDropdownOpen}
                  isPlain
                  ouiaId="change-host-content-view-kebab"
                  position="right"
                  dropdownItems={dropdownItems}
                />
              </FlexItem>
            )}
          </Flex>
        </CardHeader>
        <CardBody>
          <Flex direction={{ default: 'column' }}>
            <Flex
              direction={{ default: 'row', sm: 'row' }}
              flexWrap={{ default: 'nowrap' }}
              alignItems={{ default: 'alignItemsCenter', sm: 'alignItemsCenter' }}
            >
              <ContentViewIcon composite={contentView.composite} style={{ marginRight: '2px' }} position="left" />
              <h3>{__('Content view')}</h3>
            </Flex>
            <Flex direction={{ default: 'row', sm: 'row' }} flexWrap={{ default: 'wrap' }}>
              <a style={{ fontSize: '14px' }} href={`/content_views/${contentView.id}`}>{`${contentView.name}`}</a>
              <Tooltip
                position="top"
                enableFlip
                entryDelay={400}
                content={<FormattedMessage
                  id="cv-card-lce-tooltip"
                  defaultMessage={__('Lifecycle environment: {lce}')}
                  values={{
                    lce: lifecycleEnvironment.name,
                  }}
                />}
              >
                <Label isTruncated color="purple" href={`/lifecycle_environments/${lifecycleEnvironment.id}`}>{`${lifecycleEnvironment.name}`}</Label>
              </Tooltip>
            </Flex>
          </Flex>
          {!contentViewDefault &&
          <Flex direction={{ default: 'column' }}>
            <FlexItem>
              <h3>{__('Version in use')}</h3>
              <a style={{ fontSize: '14px' }} href={urlBuilder(`content_views/${contentView.id}/versions/${contentViewVersionId}`, '')}>
                {versionLabel}
              </a>
            </FlexItem>
          </Flex>
      }
        </CardBody>
      </Card>
      {hostId &&
        <ChangeHostCVModal
          isOpen={isModalOpen}
          closeModal={closeModal}
          hostId={hostId}
          hostName={hostName}
          hostEnvId={hostEnvId}
          orgId={orgId}
          key={`cv-change-modal-${hostId}`}
        />
      }
    </GridItem>
  );
};

const ContentViewDetailsCard = ({ hostDetails }) => {
  if (hostIsRegistered({ hostDetails })
    && hostDetails.content_facet_attributes && hostDetails.organization_id) {
    return (<HostContentViewDetails
      hostId={hostDetails.id}
      hostName={hostDetails.name}
      orgId={hostDetails.organization_id}
      hostEnvId={hostDetails.content_facet_attributes.lifecycle_environment_id}
      hostPermissions={hostDetails.permissions}
      {...propsToCamelCase(hostDetails.content_facet_attributes)}
    />);
  }
  return null;
};

HostContentViewDetails.propTypes = {
  contentView: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
    composite: PropTypes.bool,
  }).isRequired,
  contentViewDefault: PropTypes.bool,
  lifecycleEnvironment: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
  }).isRequired,
  contentViewVersionId: PropTypes.number.isRequired,
  contentViewVersion: PropTypes.string.isRequired,
  contentViewVersionLatest: PropTypes.bool.isRequired,
  id: PropTypes.number,
  name: PropTypes.string,
  hostId: PropTypes.number,
  hostName: PropTypes.string,
  orgId: PropTypes.number,
  hostEnvId: PropTypes.number,
  hostPermissions: PropTypes.shape({
    edit_hosts: PropTypes.bool,
  }),
  permissions: PropTypes.shape({
    view_content_views: PropTypes.bool,
    view_lifecycle_environments: PropTypes.bool,
    promote_or_remove_content_views_to_environments: PropTypes.bool,
  }),
};

HostContentViewDetails.defaultProps = {
  id: null,
  name: '',
  hostEnvId: null,
  hostId: null,
  hostName: '',
  orgId: null,
  contentViewDefault: false,
  hostPermissions: {},
  permissions: {},
};

ContentViewDetailsCard.propTypes = {
  hostDetails: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    organization_id: PropTypes.number,
    content_facet_attributes: PropTypes.shape({
      lifecycle_environment_id: PropTypes.number,
      permissions: PropTypes.shape({
        view_content_views: PropTypes.bool,
        view_lifecycle_environments: PropTypes.bool,
        promote_or_remove_content_views_to_environments: PropTypes.bool,
      }),
    }),
    permissions: PropTypes.shape({
      edit_hosts: PropTypes.bool,
    }),
  }),
};

ContentViewDetailsCard.defaultProps = {
  hostDetails: {},
};

export default ContentViewDetailsCard;
