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
import { useUrlParams } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import PropTypes from 'prop-types';
import ContentViewIcon from '../../../../../scenes/ContentViews/components/ContentViewIcon';
import { hasRequiredPermissions, hostIsRegistered } from '../../hostDetailsHelpers';
import ChangeHostCVModal from './ChangeHostCVModal';
import { truncate } from '../../../../../utils/helpers';

const requiredPermissions = [
  'view_lifecycle_environments', 'view_content_views',
  'promote_or_remove_content_views_to_environments',
];

export const ContentViewEnvironmentDisplay = ({
  contentView, lifecycleEnvironment,
}) => {
  const {
    contentViewDefault,
    contentViewVersionId,
    contentViewVersion,
    contentViewVersionLatest,
  } = propsToCamelCase(contentView);
  let versionLabel = 'Version {version}';
  if (contentViewVersionLatest) {
    versionLabel += ' (latest)';
  }
  return (
    <FlexItem>
      <Flex direction={{ default: 'row', sm: 'row' }} flexWrap={{ default: 'wrap' }}>
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
          <Label isTruncated color="purple" href={`/lifecycle_environments/${lifecycleEnvironment.id}`}>{lifecycleEnvironment.name}</Label>
        </Tooltip>
        <ContentViewIcon composite={contentView.composite} style={{ marginRight: '2px' }} position="left" />
        {contentViewDefault ? <span>{contentView.name}</span> :
        <a style={{ fontSize: '14px' }} href={`/content_views/${contentView.id}`}>
          {truncate(contentView.name)}
        </a>
        }
        {!contentViewDefault &&
          <FlexItem>
            <a style={{ fontSize: '14px' }} href={urlBuilder(`content_views/${contentView.id}/versions/${contentViewVersionId}`, '')}>
              <FormattedMessage
                id={`lce-${lifecycleEnvironment.name}-cv-version-${contentViewVersion}`}
                defaultMessage={versionLabel}
                values={{
                  version: contentViewVersion,
                }}
              />
            </a>
          </FlexItem>}
      </Flex>
    </FlexItem>
  );
};

ContentViewEnvironmentDisplay.propTypes = {
  contentView: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
    composite: PropTypes.bool,
  }).isRequired,
  lifecycleEnvironment: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
  }).isRequired,
};

export const CVEDetailsBareCard = ({
  contentViewEnvironments, hostPermissions, permissions, dropdownItems,
  isDropdownOpen, toggleHamburger,
}) => {
  const userPermissions = { ...hostPermissions, ...permissions };
  const showKebab = hasRequiredPermissions(requiredPermissions, userPermissions);

  return (
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
                <CardTitle>
                  <FormattedMessage
                    id="cv-card-title"
                    defaultMessage="{count, plural, =0 {Content view environments} one {Content view environment} other {Content view environments}}"
                    values={{
                      count: contentViewEnvironments.length,
                    }}
                  />
                </CardTitle>
              </FlexItem>
            </Flex>
          </FlexItem>
          {showKebab && dropdownItems && (
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
          {contentViewEnvironments.map(env => (
            <ContentViewEnvironmentDisplay
              key={`${env.lifecycle_environment.name}-${env.content_view.name}`}
              contentView={env.content_view}
              lifecycleEnvironment={env.lifecycle_environment}
            />
          ))}
        </Flex>
      </CardBody>
    </Card>
  );
};

CVEDetailsBareCard.propTypes = {
  contentViewEnvironments: PropTypes.arrayOf(PropTypes.shape({
    content_view: PropTypes.shape({
      name: PropTypes.string,
      id: PropTypes.number,
      composite: PropTypes.bool,
    }),
    lifecycle_environment: PropTypes.shape({
      name: PropTypes.string,
      id: PropTypes.number,
    }),
  })),
  hostPermissions: PropTypes.shape({
    edit_hosts: PropTypes.bool,
  }),
  permissions: PropTypes.shape({
    view_content_views: PropTypes.bool,
    view_lifecycle_environments: PropTypes.bool,
    promote_or_remove_content_views_to_environments: PropTypes.bool,
  }),
  dropdownItems: PropTypes.arrayOf(PropTypes.node),
  isDropdownOpen: PropTypes.bool,
  toggleHamburger: PropTypes.func,
};

CVEDetailsBareCard.defaultProps = {
  contentViewEnvironments: [],
  hostPermissions: {},
  permissions: {},
  dropdownItems: [],
  isDropdownOpen: false,
  toggleHamburger: () => {},
};

export const ContentViewEnvironmentDetails = ({
  contentViewEnvironments, hostId, hostName, orgId, hostEnvId,
  hostPermissions, permissions, contentSourceId,
}) => {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const toggleHamburger = () => setIsDropdownOpen(prev => !prev);
  const { content_view_assignment: initialCVModalOpen } = useUrlParams();
  const [isModalOpen, setIsModalOpen] = useState(!!initialCVModalOpen);
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
      {__('Edit content view environments')}
    </DropdownItem>,
  ];

  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3} >
      <CVEDetailsBareCard
        isDropdownOpen={isDropdownOpen}
        toggleHamburger={toggleHamburger}
        contentViewEnvironments={contentViewEnvironments}
        hostPermissions={hostPermissions}
        permissions={permissions}
        dropdownItems={showKebab ? dropdownItems : []}
      />
      {hostId &&
        <ChangeHostCVModal
          isOpen={isModalOpen}
          closeModal={closeModal}
          hostId={hostId}
          hostName={hostName}
          hostEnvId={hostEnvId}
          contentSourceId={contentSourceId}
          orgId={orgId}
          multiEnv={contentViewEnvironments.length > 1}
          key={`cv-change-modal-${hostId}`}
        />
      }
    </GridItem>
  );
};

ContentViewEnvironmentDetails.propTypes = {
  contentViewEnvironments: PropTypes.arrayOf(PropTypes.shape({
    content_view: PropTypes.shape({
      name: PropTypes.string,
      id: PropTypes.number,
      composite: PropTypes.bool,
    }),
    lifecycle_environment: PropTypes.shape({
      name: PropTypes.string,
      id: PropTypes.number,
    }),
  })),
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
  contentSourceId: PropTypes.number,
};

ContentViewEnvironmentDetails.defaultProps = {
  contentViewEnvironments: [],
  hostId: null,
  hostName: '',
  orgId: null,
  hostEnvId: null,
  hostPermissions: {},
  permissions: {},
  contentSourceId: null,
};


const ContentViewDetailsCard = ({ hostDetails }) => {
  if (hostIsRegistered({ hostDetails })
    && hostDetails.content_facet_attributes && hostDetails.organization_id) {
    return (<ContentViewEnvironmentDetails
      hostId={hostDetails.id}
      hostName={hostDetails.name}
      contentSourceId={hostDetails.content_facet_attributes.content_source?.id}
      orgId={hostDetails.organization_id}
      hostEnvId={hostDetails.content_facet_attributes.lifecycle_environment_id}
      hostPermissions={hostDetails.permissions}
      {...propsToCamelCase(hostDetails.content_facet_attributes)}
    />);
  }
  return null;
};

ContentViewDetailsCard.propTypes = {
  hostDetails: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    organization_id: PropTypes.number,
    content_facet_attributes: PropTypes.shape({
      lifecycle_environment_id: PropTypes.number,
      content_source: PropTypes.shape({
        id: PropTypes.number,
      }),
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
