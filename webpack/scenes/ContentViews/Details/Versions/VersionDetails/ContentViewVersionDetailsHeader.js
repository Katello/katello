import React, { useState, useEffect } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import {
  Grid,
  GridItem,
  TextContent,
  Text,
  TextList,
  TextVariants,
  TextListVariants,
  Label,
  Flex,
  FlexItem,
  Dropdown,
  DropdownItem,
  DropdownToggle,
  DropdownPosition,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import EditableTextInput from '../../../../../components/EditableTextInput';
import { hasPermission } from '../../../helpers';
import ContentViewVersionPromote from '../../Promote/ContentViewVersionPromote';
import getEnvironmentPaths from '../../../components/EnvironmentPaths/EnvironmentPathActions';
import RemoveCVVersionWizard from '../Delete/RemoveCVVersionWizard';

const ContentViewVersionDetailsHeader = ({
  versionDetails: {
    version, description, environments, content_view_id: cvId, id,
  },
  onEdit,
  details: { permissions },
}) => {
  const dispatch = useDispatch();
  useEffect(
    () => {
      dispatch(getEnvironmentPaths());
    },
    [dispatch],
  );
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [promoting, setPromoting] = useState(false);
  const [removingFromEnv, setRemovingFromEnv] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const [deleteVersion, setDeleteVersion] = useState(false);
  const dropDownItems = [
    <DropdownItem
      key="promote"
      onClick={() => {
        setPromoting(true);
      }}
    >
      {__('Promote')}
    </DropdownItem>,
    <DropdownItem
      key="remove"
      onClick={() => {
        setRemovingFromEnv(true);
      }}
    >
      {__('Remove from environment')}
    </DropdownItem>,
    <DropdownItem
      key="delete"
      onClick={() => {
        setCurrentStep(1);
        setDeleteVersion(true);
        setRemovingFromEnv(true);
      }}
    >
      {__('Delete')}
    </DropdownItem>,
  ];

  return (
    <Grid className="margin-0-24">
      <GridItem span={10}>
        <TextContent>
          <Text component={TextVariants.h2}>{__('Version ')}{version}</Text>
        </TextContent>
      </GridItem>
      <GridItem span={2} style={{ display: 'flex' }}>
        <Dropdown
          aria-label="version-action-dropdown"
          position={DropdownPosition.right}
          style={{ marginLeft: 'auto' }}
          toggle={
            <DropdownToggle
              onToggle={setDropdownOpen}
              id="toggle-id"
            >
              {__('Actions')}
            </DropdownToggle>
          }
          isOpen={dropdownOpen}
          dropdownItems={dropDownItems}
        />
      </GridItem>
      <GridItem className="content-view-header-content" span={12}>
        <TextContent>
          <TextList component={TextListVariants.dl}>
            <EditableTextInput
              key={description} // This fixes a render issue with the initial value
              textArea
              label={__('Description')}
              attribute="description"
              placeholder={__('No description')}
              onEdit={onEdit}
              disabled={!hasPermission(permissions, 'edit_content_views')}
              value={description}
            />
          </TextList>
        </TextContent>
        <Flex>
          {environments?.map(({ name, id: envId }) =>
            <FlexItem key={name}><Label isTruncated color="purple" href={`/lifecycle_environments/${envId}`}>{name}</Label></FlexItem>)}
        </Flex>
      </GridItem>
      {promoting &&
        <ContentViewVersionPromote
          cvId={cvId}
          versionIdToPromote={id}
          versionNameToPromote={version}
          versionEnvironments={environments}
          setIsOpen={setPromoting}
          detailsPage
          aria-label="promote_content_view_modal"
        />
      }
      {removingFromEnv &&
        <RemoveCVVersionWizard
          cvId={cvId}
          versionIdToRemove={id}
          versionNameToRemove={version}
          versionEnvironments={environments}
          show={removingFromEnv}
          setIsOpen={setRemovingFromEnv}
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          deleteWizard={deleteVersion}
          detailsPage
          aria-label="remove_content_view_version_modal"
        />
      }
    </Grid>
  );
};

ContentViewVersionDetailsHeader.propTypes = {
  versionDetails: PropTypes.shape({
    version: PropTypes.string,
    environments: PropTypes.arrayOf(PropTypes.shape({})),
    description: PropTypes.string,
    content_view_id: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
    ]),
    id: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
    ]),
  }).isRequired,
  onEdit: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default ContentViewVersionDetailsHeader;
