import React, { useState } from 'react';
import {
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  Flex,
  FlexItem,
  GridItem,
  Label,
  Tooltip,
  Button,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
} from '@patternfly/react-core/deprecated';
import { PlusCircleIcon } from '@patternfly/react-icons';
import { FormattedMessage } from 'react-intl';

import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { useUrlParams } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import PropTypes from 'prop-types';
import ContentViewIcon from '../../../../../scenes/ContentViews/components/ContentViewIcon';
import { hasRequiredPermissions, hostIsRegistered } from '../../hostDetailsHelpers';
import AssignHostCVModal from './AssignHostCVModal';
import { truncate } from '../../../../../utils/helpers';
import EmptyStateMessage from '../../../../../components/Table/EmptyStateMessage';
import './ContentViewDetailsCard.scss';

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
          <Label color="purple" href={`/lifecycle_environments/${lifecycleEnvironment.id}`} style={{ marginRight: '2px' }}>{lifecycleEnvironment.name}</Label>
        </Tooltip>
        <ContentViewIcon composite={contentView.composite} rolling={contentViewDefault || contentView.rolling} style={{ marginLeft: '6px', marginRight: '1px' }} position="left" />
        {contentViewDefault ? <span>{contentView.name}</span> :
        <a style={{ fontSize: '14px' }} href={`/content_views/${contentView.id}`}>
          {truncate(contentView.name)}
        </a>
        }
        {!(contentViewDefault || contentView.rolling) &&
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
    rolling: PropTypes.bool,
  }).isRequired,
  lifecycleEnvironment: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
  }).isRequired,
};

export const CVEDetailsBareCard = ({
  contentViewEnvironments, hostPermissions, permissions, dropdownItems,
  isDropdownOpen, toggleKebab, allowMultipleContentViews, openModal,
}) => {
  const userPermissions = { ...hostPermissions, ...permissions };
  const showKebab = hasRequiredPermissions(requiredPermissions, userPermissions);

  const primaryActionButton = openModal ? (
    <Button
      ouiaId="assign-content-view-environments-button"
      onClick={openModal}
      variant="secondary"
      aria-label="assign_content_view_environments"
    >
      {__('Assign content view environments')}
    </Button>
  ) : null;

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
                  {contentViewEnvironments.length > 1
                    ? __('Content view environments')
                    : __('Content view environment')}
                </CardTitle>
              </FlexItem>
            </Flex>
          </FlexItem>
          {showKebab && dropdownItems && (
            <FlexItem>
              <Dropdown
                toggle={<KebabToggle aria-label="change_content_view_kebab" onToggle={toggleKebab} />}
                isOpen={isDropdownOpen}
                isPlain
                ouiaId="change-content-view-environments-card-kebab"
                position="right"
                dropdownItems={dropdownItems}
              />
            </FlexItem>
          )}
        </Flex>
      </CardHeader>
      <CardBody className={contentViewEnvironments.length === 0 ? 'empty' : ''}>
        {contentViewEnvironments.length === 0 ? (
          <EmptyStateMessage
            title={__('No content view environments yet')}
            body={__('To get started, assign content view environments.')}
            customIcon={PlusCircleIcon}
            headingLevel="h4"
            showPrimaryAction={!!primaryActionButton}
            primaryActionButton={primaryActionButton}
          />
        ) : (
          <Flex direction={{ default: 'column' }}>
            {contentViewEnvironments.map(env => (
              <ContentViewEnvironmentDisplay
                key={`${env.lifecycle_environment.name}-${env.content_view.name}`}
                contentView={env.content_view}
                lifecycleEnvironment={env.lifecycle_environment}
              />
            ))}
          </Flex>
        )}
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
  toggleKebab: PropTypes.func,
  allowMultipleContentViews: PropTypes.bool,
  openModal: PropTypes.func,
};

CVEDetailsBareCard.defaultProps = {
  contentViewEnvironments: [],
  hostPermissions: {},
  permissions: {},
  dropdownItems: [],
  isDropdownOpen: false,
  toggleKebab: () => {},
  allowMultipleContentViews: true,
  openModal: null,
};

export const ContentViewEnvironmentDetails = ({
  contentViewEnvironments, hostId, hostName, orgId,
  hostPermissions, permissions, contentSourceId, allowMultipleContentViews,
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
      aria-label="assign-content-view-environments"
      ouiaId="assign-content-view-environments"
      key="assign-content-view-environments"
      component="button"
      onClick={openModal}
    >
      {allowMultipleContentViews
        ? __('Assign content view environments')
        : __('Edit content view environment')}
    </DropdownItem>,
  ];

  // Convert contentViewEnvironments to the format expected by AssignHostCVModal
  const existingAssignments = contentViewEnvironments.map(env => ({
    contentView: env.content_view,
    environment: env.lifecycle_environment,
    cveLabel: env.label, // Use the CVE label from the API
  }));

  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3} >
      <CVEDetailsBareCard
        isDropdownOpen={isDropdownOpen}
        toggleHamburger={toggleHamburger}
        contentViewEnvironments={contentViewEnvironments}
        hostPermissions={hostPermissions}
        permissions={permissions}
        dropdownItems={showKebab ? dropdownItems : []}
        allowMultipleContentViews={allowMultipleContentViews}
        openModal={showKebab ? openModal : null}
      />
      {hostId &&
        <AssignHostCVModal
          isOpen={isModalOpen}
          closeModal={closeModal}
          hostId={hostId}
          hostName={hostName}
          contentSourceId={contentSourceId}
          orgId={orgId}
          existingAssignments={existingAssignments}
          allowMultipleContentViews={allowMultipleContentViews}
          key={`cv-assign-modal-${hostId}`}
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
  hostPermissions: PropTypes.shape({
    edit_hosts: PropTypes.bool,
  }),
  permissions: PropTypes.shape({
    view_content_views: PropTypes.bool,
    view_lifecycle_environments: PropTypes.bool,
    promote_or_remove_content_views_to_environments: PropTypes.bool,
  }),
  contentSourceId: PropTypes.number,
  allowMultipleContentViews: PropTypes.bool.isRequired,
};

ContentViewEnvironmentDetails.defaultProps = {
  contentViewEnvironments: [],
  hostId: null,
  hostName: '',
  orgId: null,
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
