import React, { useState, useEffect, useRef } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import { useParams } from 'react-router-dom';
import { DEFAULT_INTERVAL } from 'foremanReact/redux/middlewares/IntervalMiddleware/IntervalConstants';
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
import LastScan from '../Details/LastScan';
import EditFlatpakRemotesModal from '../CreateEdit/EditFlatpakRemotesModal';
import DeleteFlatpakModal from '../Delete/DeleteFlatpakModal';

export default function FlatpakRemoteDetails() {
  const { id } = useParams();
  const frId = Number(id);
  const [dropDownOpen, setDropdownOpen] = useState(false);
  const [isScanning, setIsScanning] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [scanTaskId, setScanTaskId] = useState(null);
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
  const lastScan = frDetails.last_scan;
  const lastScanWords = frDetails.last_scan_words || '';
  const isLoaded = Boolean(frDetails.id);

  const lastScanIdRef = useRef(lastScan?.id);
  useEffect(() => {
    let intervalId;
    if (isScanning) {
      intervalId = setInterval(() => {
        dispatch(getFlatpakRemoteDetails(frId));
      }, DEFAULT_INTERVAL);
    }

    return () => {
      if (intervalId) clearInterval(intervalId);
    };
  }, [isScanning, dispatch, frId]);

  useEffect(() => {
    if (!lastScan) return;

    const isNewScan = lastScan.id !== lastScanIdRef.current;

    if (lastScan.progress < 1) {
      setIsScanning(true);
    } else if (isNewScan && lastScan.progress >= 1) {
      lastScanIdRef.current = lastScan.id;
      setIsScanning(false);
    }
  }, [lastScan]);

  const {
    can_edit: canEdit = false,
    can_delete: canDelete = false,
    can_mirror: canMirror = false,
  } = frDetails || {};

  const onEdit = (val, attribute) => {
    if (val === frDetails[attribute]) return;
    dispatch(updateFlatpakRemote(frId, { [attribute]: val }));
  };

  const handleScan = () => {
    lastScanIdRef.current = lastScan?.id;
    setIsScanning(true);
    dispatch(scanFlatpakRemote(frId, (response) => {
      const taskId = response?.data?.id;
      if (taskId) setScanTaskId(taskId);
    }));
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
            <Flex alignItems={{ default: 'alignItemsCenter' }}>
              {canEdit && (
                <>
                  {
                    isLoaded && <LastScan
                      lastScan={lastScan}
                      lastScanWords={lastScanWords}
                      isScanning={isScanning}
                      scanTaskId={scanTaskId}
                    />
                  }
                  <FlexItem>
                    <Button
                      ouiaId="fr-details-scan-button"
                      onClick={handleScan}
                      variant="primary"
                      aria-label="scan_flatpak_remote"
                      isLoading={isScanning}
                      isDisabled={isScanning}
                    >
                      {__('Scan')}
                    </Button>
                  </FlexItem>
                </>
              )}
              {dropDownItems.length > 0 && (
                <FlexItem>
                  <Dropdown
                    position={DropdownPosition.right}
                    ouiaId="fr-details-actions"
                    toggle={
                      <KebabToggle
                        onToggle={(_event, val) => setDropdownOpen(val)}
                        id="toggle-dropdown"
                      />
                    }
                    isOpen={dropDownOpen}
                    isPlain
                    dropdownItems={dropDownItems}
                  />
                </FlexItem>
              )}
            </Flex>
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

      <GridItem span={12} id="remote-repositories-table">
        <RemoteRepositoriesTable key={lastScan?.id} frId={frId} canMirror={canMirror} />
      </GridItem>
      {
        isEditing &&
        <EditFlatpakRemotesModal show={isEditing} remoteData={frDetails} setIsOpen={setIsEditing} />
      }
      {
        isDeleteModalOpen &&
        <DeleteFlatpakModal
          isModalOpen={isDeleteModalOpen}
          handleModalToggle={() => setDeleteModalOpen(!isDeleteModalOpen)}
          remoteId={frId}
        />
      }
    </Grid >
  );
}
