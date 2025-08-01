import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import { useParams } from 'react-router-dom';
import {
  Breadcrumb,
  BreadcrumbItem,
  Button,
  Title,
  Grid,
  GridItem,
  Text,
  TextContent,
  TextList,
  TextListVariants,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
  DropdownPosition,
} from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectFlatpakRemoteDetails } from './FlatpakRemoteDetailSelectors';
import getFlatpakRemoteDetails, {
  scanFlatpakRemote,
  updateFlatpakRemote,
} from './FlatpakRemoteDetailActions';
import ActionableDetail from '../../../components/ActionableDetail';
import RemoteRepositoriesTable from './RemoteRepositories/RemoteRepositoriesTable';
import EditFlatpakRemotesModal from '../CreateEdit/EditFlatpakRemotesModal';
import DeleteFlatpakModal from '../Delete/DeleteFlatpakModal';

export default function FlatpakRemoteDetails() {
  const { id } = useParams();
  const frId = Number(id);
  const [dropDownOpen, setDropdownOpen] = useState(false);
  const [isScanning, setIsScanning] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const dispatch = useDispatch();

  const [currentAttribute, setCurrentAttribute] = useState(null);
  const [isDeleteModalOpen, setDeleteModalOpen] = useState(false);

  useEffect(() => {
    dispatch(getFlatpakRemoteDetails(frId));
  }, [dispatch, frId]);

  const frDetails = useSelector(state =>
    selectFlatpakRemoteDetails(state, frId), shallowEqual) || {};
  const name = frDetails.name || '';
  const url = frDetails.url || '';

  const {
    can_edit: canEdit = false,
    can_delete: canDelete = false,
    can_mirror: canMirror = false,
  } = frDetails || {};

  const onEdit = (val, attribute) => {
    if (val === frDetails[attribute]) return;
    dispatch(updateFlatpakRemote(frId, { [attribute]: val }));
  };

  const dropDownItems = [];
  if (canEdit) {
    dropDownItems.push(<DropdownItem key="edit" ouiaId="fr-edit" onClick={() => { setIsEditing(true); }}> {__('Edit')}</DropdownItem>);
  }
  if (canDelete) {
    dropDownItems.push(<DropdownItem key="delete" ouiaId="cv-delete" onClick={() => setDeleteModalOpen(true)}>{__('Delete')}</DropdownItem>);
  }

  return (
    <Grid hasGutter span={12} style={{ padding: '24px' }}>
      <GridItem span={12}>
        <Breadcrumb ouiaId="flatpak-remote-breadcrumb">
          <BreadcrumbItem to="/flatpak_remotes">Flatpak remotes</BreadcrumbItem>
          <BreadcrumbItem isActive>{name}</BreadcrumbItem>
        </Breadcrumb>
      </GridItem>

      <GridItem span={12}>
        <Flex>
          <FlexItem>
            <Title headingLevel="h1" size="2xl" ouiaId="flatpak-remote-title">{name}</Title>
          </FlexItem>
          <FlexItem align={{ default: 'alignRight' }}>
            {canEdit &&
            <Button
              ouiaId="fr-details-scan-button"
              style={{ marginLeft: 'auto' }}
              onClick={() => {
                setIsScanning(true);
                dispatch(scanFlatpakRemote(
                  frId,
                  () => { setIsScanning(false); },
                  () => setIsScanning(false),
                ));
              }
              }
              variant="primary"
              aria-label="scan_flatpak_remote"
              isLoading={isScanning}
              isDisabled={isScanning}
            >
              {__('Scan')}
            </Button>
            }
            {dropDownItems.length > 0 &&
            <Dropdown
              position={DropdownPosition.right}
              ouiaId="fr-details-actions"
              style={{ marginLeft: 'auto' }}
              toggle={<KebabToggle onToggle={(_event, val) => setDropdownOpen(val)} id="toggle-dropdown" />}
              isOpen={dropDownOpen}
              isPlain
              dropdownItems={dropDownItems}
            />
            }
          </FlexItem>
        </Flex>
      </GridItem>

      <GridItem span={12}>
        <TextContent>
          <TextList component={TextListVariants.dl}>
            <ActionableDetail
              key={url}
              label={__('URL:')}
              attribute="url"
              onEdit={onEdit}
              disabled={!canEdit}
              value={url}
              {...{ currentAttribute, setCurrentAttribute }}
            />
          </TextList>
        </TextContent>
      </GridItem>

      <GridItem span={12}>
        <TextContent>
          <Title headingLevel="h2" size="xl" ouiaId="flatpak-remote-subtitle">Remote repositories</Title>
          <Text component="p" ouiaId="flatpak-remote-description" style={{ color: 'gray' }}>
            This is a list of scanned flatpaks.
            Mirroring a scanned flatpak creates a repository in the product of your choice.
            Sync the repository after mirroring it from this remote to distribute its content.
          </Text>
        </TextContent>
      </GridItem>

      <GridItem span={12}>
        <RemoteRepositoriesTable frId={frId} canMirror={canMirror} />
      </GridItem>
      { isEditing &&
        <EditFlatpakRemotesModal show={isEditing} remoteData={frDetails} setIsOpen={setIsEditing} />
      }
      { isDeleteModalOpen &&
        <DeleteFlatpakModal
          isModalOpen={isDeleteModalOpen}
          handleModalToggle={() => setDeleteModalOpen(!isDeleteModalOpen)}
          remoteId={frId}
        />
        }
    </Grid>
  );
}
