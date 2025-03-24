import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import {
  Button,
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
  Label,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
  DropdownPosition,
} from '@patternfly/react-core/deprecated';
import { useHistory } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { hasPermission } from '../../../helpers';
import ContentViewVersionPromote from '../../Promote/ContentViewVersionPromote';
import getEnvironmentPaths from '../../../components/EnvironmentPaths/EnvironmentPathActions';
import RemoveCVVersionWizard from '../Delete/RemoveCVVersionWizard';
import ActionableDetail from '../../../../../components/ActionableDetail';
import BulkDeleteModal from '../BulkDelete/BulkDeleteModal';
import NeedsPublishIcon from '../../../components/NeedsPublishIcon';
import FiltersAppliedIcon from '../../../components/FiltersAppliedIcon';
import { selectCVNeedsPublish } from '../../ContentViewDetailSelectors';
import { republishCVVRepoMetadata } from '../../ContentViewDetailActions';

const ContentViewVersionDetailsHeader = ({
  versionDetails,
  onEdit,
  details: {
    permissions, latest_version_id: latestVersionId, needs_publish: needsPublish, composite,
  },
  loading,
}) => {
  const history = useHistory();
  const {
    version, description, environments, filters_applied: filtersApplied, content_view_id: cvId, id,
    repositories,
  } = versionDetails;
  const needsPublishLocal = useSelector(state => selectCVNeedsPublish(state));
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
  const [bulkDeleteOpen, setBulkDeleteOpen] = useState(false);

  const handleRepublish = () => {
    dispatch(republishCVVRepoMetadata({ cvId, id }));
    setDropdownOpen(false);
  };

  const anyReposUseCompleteMirroring =
    repositories.some(repo => repo.mirroring_policy === 'mirror_complete');

  const dropDownItems = [
    <DropdownItem
      ouiaId="remove"
      key="remove"
      onClick={() => {
        setRemovingFromEnv(true);
      }}
    >
      {__('Remove from environment')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="republish"
      key="republish"
      isDisabled={anyReposUseCompleteMirroring}
      onClick={() => {
        handleRepublish();
      }}
    >
      {__('Republish repository metadata')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="delete"
      key="delete"
      onClick={() =>
        setBulkDeleteOpen(true)
      }
    >
      {__('Delete')}
    </DropdownItem >,
  ];

  return (
    <Grid className="margin-0-24">
      <GridItem sm={6} >
        <TextContent>
          <Text ouiaId="cv-version" component={TextVariants.h2}>
            {__('Version ')}{version}
            {(latestVersionId === id &&
                    (needsPublish === null || needsPublish || needsPublishLocal)) &&
                    <NeedsPublishIcon
                      composite={composite}
                      determinate={needsPublish !== null || needsPublishLocal}
                    />
            }
            {(filtersApplied) &&
            <FiltersAppliedIcon />
            }
          </Text>

        </TextContent>
      </GridItem>
      <GridItem sm={6} style={{ display: 'flex' }}>
        <Button
          ouiaId="cv-details-promote-button"
          style={{ marginLeft: 'auto' }}
          onClick={() => setPromoting(true)}
          variant="primary"
          aria-label="promote_content_view"
        >
          {__('Promote')}
        </Button>
        <Dropdown
          isPlain
          ouiaId="cv-version-header-actions-dropdown"
          style={{ width: 'inherit' }}
          position={DropdownPosition.right}
          toggle={
            <KebabToggle onToggle={(_event, val) => setDropdownOpen(val)} id="toggle-dropdown" />
          }
          isOpen={dropdownOpen}
          dropdownItems={dropDownItems}
        />
      </GridItem>
      <GridItem className="content-view-header-content" span={12}>
        <TextContent>
          <ActionableDetail
            key={description} // This fixes a render issue with the initial value
            textArea
            attribute="description"
            loading={loading}
            placeholder={__('No description')}
            onEdit={onEdit}
            disabled={!hasPermission(permissions, 'edit_content_views')}
            value={description}
          />
        </TextContent>
        <Flex>
          {environments?.map(({ name, id: envId }) => (
            <FlexItem key={name}>
              <Label color="purple" href={`/lifecycle_environments/${envId}`}>{name}</Label>
            </FlexItem>))}
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
      {bulkDeleteOpen &&
        <BulkDeleteModal
          versions={[versionDetails]}
          onClose={(redirect) => {
            setBulkDeleteOpen(false);
            if (redirect) history.push(`/content_views/${cvId}#/versions`);
          }}
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
    repositories: PropTypes.arrayOf(PropTypes.shape({
      mirroring_policy: PropTypes.string,
    })),
    content_view_id: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
    ]),
    id: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
    ]),
    filters_applied: PropTypes.bool,
  }).isRequired,
  onEdit: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
    needs_publish: PropTypes.bool,
    composite: PropTypes.bool,
    latest_version_id: PropTypes.number,
  }).isRequired,
  loading: PropTypes.bool.isRequired,
};

export default ContentViewVersionDetailsHeader;
