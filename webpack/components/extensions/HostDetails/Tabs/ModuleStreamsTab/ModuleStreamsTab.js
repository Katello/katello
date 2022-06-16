import React, { useCallback, useState } from 'react';
import { useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { translate as __ } from 'foremanReact/common/I18n';
import { Skeleton,
  Label,
  Button,
  Split,
  SplitItem,
  Checkbox,
  Dropdown,
  Text,
  TextVariants,
  DropdownItem,
  KebabToggle,
  DropdownPosition,
  DropdownSeparator,
  Modal,
  ModalVariant } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { upperFirst, lowerCase } from 'lodash';
import { TableText, TableVariant, Thead, Tbody, Tr, Td } from '@patternfly/react-table';
import {
  LongArrowAltUpIcon,
  CheckIcon,
} from '@patternfly/react-icons';
import { selectModuleStreamStatus, selectModuleStream } from './ModuleStreamsSelectors';
import { useBulkSelect, useTableSort, useUrlParams } from '../../../../Table/TableHooks';
import { getHostModuleStreams } from './ModuleStreamsActions';
import InactiveText from '../../../../../scenes/ContentViews/components/InactiveText';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import hostIdNotReady from '../../HostDetailsActions';
import { selectHostDetails } from '../../HostDetailsSelectors';
import SortableColumnHeaders from '../../../../Table/components/SortableColumnHeaders';
import SelectableDropdown from '../../../../SelectableDropdown/SelectableDropdown';
import {
  HOST_MODULE_STREAM_STATUSES, INSTALL_STATUS_PARAM_TO_FRIENDLY_NAME, INSTALLED_STATE,
  STATUS_PARAM_TO_FRIENDLY_NAME, MODULE_STREAMS_KEY,
} from './ModuleStreamsConstants';
import { moduleStreamAction } from '../RemoteExecutionActions';
import { katelloModuleStreamActionUrl } from '../customizedRexUrlHelpers';
import { useRexJobPolling } from '../RemoteExecutionHooks';
import {
  hasRequiredPermissions as can,
  missingRequiredPermissions as cannot,
  userPermissionsFromHostDetails,
} from '../../hostDetailsHelpers';


const EnabledIcon = ({ streamText, streamInstallStatus, upgradable }) => {
  switch (true) {
  case (streamInstallStatus?.length > 0 && streamText === 'disabled'):
    return <TableText wrapModifier="nowrap">{INSTALLED_STATE.INSTALLED}</TableText>;
  case (streamInstallStatus?.length > 0 && streamText === 'enabled' && upgradable !== true):
    return <><CheckIcon color="green" /> {INSTALLED_STATE.UPTODATE}</>;
  case (streamInstallStatus?.length > 0 && streamText === 'enabled' && upgradable):
    return <><LongArrowAltUpIcon color="blue" /> {INSTALLED_STATE.UPGRADEABLE}</>;
  default:
    return <InactiveText text={INSTALLED_STATE.NOTINSTALLED} />;
  }
};

EnabledIcon.propTypes = {
  streamText: PropTypes.string.isRequired,
  streamInstallStatus: PropTypes.arrayOf(PropTypes.string).isRequired,
  upgradable: PropTypes.bool.isRequired,
};

const stateText = (moduleStreamStatus) => {
  let streamText = moduleStreamStatus?.charAt(0)?.toUpperCase() + moduleStreamStatus?.slice(1);
  streamText = streamText?.replace('Unknown', 'Default');
  return streamText;
};

const StreamState = ({ moduleStreamStatus }) => {
  const streamText = stateText(moduleStreamStatus);
  switch (true) {
  case (streamText === 'Default'):
    return <Label color="gray" variant="outline">{streamText}</Label>;
  case (streamText === 'Disabled'):
    return <Label color="gray" variant="filled">{streamText}</Label>;
  case (streamText === 'Enabled'):
    return <Label color="green" variant="filled">{streamText}</Label>;
  default:
    return null;
  }
};

StreamState.propTypes = {
  moduleStreamStatus: PropTypes.string.isRequired,
};

const HostInstalledProfiles = ({ moduleStreamStatus, installedProfiles }) => {
  let installedProfile;
  if (installedProfiles?.length > 0) {
    installedProfile = installedProfiles?.map(profile => upperFirst(profile)).join(', ');
  } else {
    installedProfile = 'No profile installed';
  }
  const disabledText = moduleStreamStatus === 'disabled' || moduleStreamStatus === 'unknown';
  return disabledText ? <InactiveText text={installedProfile} /> : installedProfile;
};

HostInstalledProfiles.propTypes = {
  moduleStreamStatus: PropTypes.string.isRequired,
  installedProfiles: PropTypes.arrayOf(PropTypes.string).isRequired,
};

const ModuleActionConfirmationModal = ({
  hostname, action, moduleSpec, actionModalOpen, setActionModalOpen, triggerModuleStreamAction,
}) => {
  let title;
  let body;
  let confirmText;
  switch (action) {
  case 'disable':
    confirmText = __('Disable');
    title = __('Disable module stream');
    body = (
      <FormattedMessage
        id="warning-message-disable"
        defaultMessage={__('Selected module {moduleSpec} will become unavailable. \n' +
          '      The module RPMs will become unavailable in the package set.')}
        values={{
          moduleSpec,
        }}
      />
    );
    break;
  case 'reset':
    confirmText = __('Reset');
    title = __('Reset module stream');
    body = (
      <FormattedMessage
        id="warning-message-reset"
        defaultMessage={__('Selected module {moduleSpec} will be no longer enabled or disabled. \n' +
          'Consequently, all installed profiles will be removed and only RPMs from the default stream will be available in the package set.')}
        values={{
          moduleSpec,
        }}
      />
    );
    break;
  case 'remove':
    confirmText = __('Remove');
    title = __('Remove module stream');
    body = __(`Installed module profiles will be removed. Additionally, all packages whose names are provided by specific modules will be removed.
      Packages required by other installed modules profiles and packages whose names are also provided by other modules are not removed.`);
    break;
  default:
    // No action selected. Should not be here!
    setActionModalOpen(false);
  }
  return (
    <Modal
      variant={ModalVariant.small}
      isOpen={actionModalOpen}
      aria-label="Module action confirmation modal"
      title={title}
      titleIconVariant="warning"
      showClose
      onClose={() => setActionModalOpen(false)}
      actions={[
        <Button
          aria-label="confirm-module-action"
          key="confirm-module-action"
          onClick={() => {
            triggerModuleStreamAction({ hostname, action, moduleSpec });
            setActionModalOpen(false);
          }}
        >
          {confirmText}
        </Button>,
        <Button
          aria-label="cancel-module-action"
          key="cancel-module-action"
          variant="link"
          onClick={() => setActionModalOpen(false)}
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      <Text component={TextVariants.p}>
        {body}
      </Text>

    </Modal>
  );
};

ModuleActionConfirmationModal.propTypes = {
  hostname: PropTypes.string.isRequired,
  action: PropTypes.string.isRequired,
  moduleSpec: PropTypes.string.isRequired,
  actionModalOpen: PropTypes.bool.isRequired,
  setActionModalOpen: PropTypes.func.isRequired,
  triggerModuleStreamAction: PropTypes.func.isRequired,
};

const invokeRexJobs = ['create_job_invocations'];
const createBookmarks = ['create_bookmarks'];

export const ModuleStreamsTab = () => {
  const hostDetails = useSelector(selectHostDetails);
  const { id: hostId, name: hostname } = hostDetails;
  const showActions = can(invokeRexJobs, userPermissionsFromHostDetails({ hostDetails }));
  const [useCustomizedRex, setUseCustomizedRex] = useState('');
  const [dropdownOpen, setDropdownOpen] = useState('');
  const [actionModalOpen, setActionModalOpen] = useState(false);
  const [actionableModuleSpec, setActionableModuleSpec] = useState(null);
  const [hostModuleStreamAction, setHostModuleStreamAction] = useState(null);

  const emptyContentTitle = __('This host does not have any Module streams.');
  const emptyContentBody = __('Module streams will appear here after enabling Red Hat repositories or creating custom products.');
  const emptySearchTitle = __('Your search returned no matching Module streams.');
  const emptySearchBody = __('Try changing your search criteria.');
  const showPrimaryAction = true;
  const showSecondaryAction = true;
  const primaryActionTitle = __('Enable Red Hat repositories');
  const secondaryActionTitle = __('Create a custom product');
  const primaryActionLink = '/redhat_repositories';
  const secondaryActionLink = '/products/new';
  const errorSearchTitle = __('Problem searching module streams');
  const {
    status: initialStatus,
    installStatus: initialInstallStatusSelected,
    searchParam,
  } = useUrlParams();
  const MODULE_STREAM_STATUS = __('Status');
  const MODULE_STREAM_INSTALLATION_STATUS = __('Installation status');
  const [statusSelected, setStatusSelected] =
    useState(STATUS_PARAM_TO_FRIENDLY_NAME[initialStatus] ??
    MODULE_STREAM_STATUS);
  const [installStatusSelected, setInstallStatusSelected] =
    useState(INSTALL_STATUS_PARAM_TO_FRIENDLY_NAME[initialInstallStatusSelected] ??
    MODULE_STREAM_INSTALLATION_STATUS);
  const columnHeaders = [
    __('Name'),
    __('State'),
    __('Stream'),
    __('Installation status'),
    __('Installed profile'),
  ];
  const COLUMNS_TO_SORT_PARAMS = {
    [columnHeaders[0]]: 'name',
    [columnHeaders[1]]: 'status',
    [columnHeaders[3]]: 'installed_profiles',
  };

  const {
    pfSortParams, apiSortParams,
    activeSortColumn, activeSortDirection,
  } = useTableSort({
    allColumns: columnHeaders,
    columnsToSortParams: COLUMNS_TO_SORT_PARAMS,
    initialSortColumnName: 'Name',
  });

  const {
    triggerJobStart: triggerModuleStreamAction, lastCompletedJob: tableJobCompleted,
    isPolling: isModuleStreamActionInProgress,
  } = useRexJobPolling(moduleStreamAction);

  const {
    triggerJobStart: triggerConfirmModalAction, lastCompletedJob: confirmModalJobCompleted,
    isPolling: isConfirmModalActionInProgress,
  } = useRexJobPolling(moduleStreamAction);

  const actionInProgress = (isModuleStreamActionInProgress || isConfirmModalActionInProgress);

  const fetchItems = useCallback(
    (params) => {
      let extraParams = params;
      if (!hostId) return hostIdNotReady;
      if (statusSelected !== MODULE_STREAM_STATUS) {
        extraParams = { ...extraParams, status: lowerCase(statusSelected) };
      }
      if (installStatusSelected !== MODULE_STREAM_INSTALLATION_STATUS) {
        extraParams = { ...extraParams, install_status: lowerCase(installStatusSelected) };
      }
      return getHostModuleStreams(
        hostId,
        { ...apiSortParams, ...extraParams },
      );
    },
    [hostId, statusSelected, installStatusSelected,
      MODULE_STREAM_STATUS, MODULE_STREAM_INSTALLATION_STATUS, apiSortParams],
  );

  const handleModuleStreamStatusSelected = newStatus => setStatusSelected((prevStatus) => {
    if (prevStatus === newStatus) {
      return MODULE_STREAM_STATUS;
    }
    return newStatus;
  });

  const handleModuleStreamInstallationStatusSelected =
      newInstallationStatus => setInstallStatusSelected((prevInstallationStatus) => {
        if (prevInstallationStatus === newInstallationStatus) {
          return MODULE_STREAM_INSTALLATION_STATUS;
        }
        return newInstallationStatus;
      });

  const customizedActionURL = (action, moduleSpec) =>
    katelloModuleStreamActionUrl({ hostname, action, moduleSpec });

  const response = useSelector(selectModuleStream);
  const { results, ...metadata } = response;
  const { error: errorSearchBody } = metadata;
  const status = useSelector(state => selectModuleStreamStatus(state));
  /* eslint-disable no-unused-vars */
  const {
    selectOne, isSelected, searchQuery, selectedCount, isSelectable,
    updateSearchQuery, selectNone, fetchBulkParams, ...selectAll
  } = useBulkSelect({
    results,
    metadata,
    isSelectable: _result => false,
    initialSearchQuery: searchParam || '',
  });
  /* eslint-enable no-unused-vars */

  const hideBookmarkActions =
    cannot(createBookmarks, userPermissionsFromHostDetails({ hostDetails }));

  if (!hostId) return <Skeleton />;

  const activeFilters = [statusSelected, installStatusSelected];
  const defaultFilters = [MODULE_STREAM_STATUS, MODULE_STREAM_INSTALLATION_STATUS];

  const resetFilters = () => {
    setStatusSelected(MODULE_STREAM_STATUS);
    setInstallStatusSelected(MODULE_STREAM_INSTALLATION_STATUS);
  };

  return (
    <div>
      <div id="modulestreams-tab">
        <TableWrapper
          {...{
            metadata,
            emptyContentTitle,
            emptyContentBody,
            emptySearchTitle,
            emptySearchBody,
            errorSearchTitle,
            errorSearchBody,
            searchQuery,
            updateSearchQuery,
            fetchItems,
            activeFilters,
            defaultFilters,
            status,
            showPrimaryAction,
            showSecondaryAction,
            primaryActionTitle,
            secondaryActionTitle,
            primaryActionLink,
            secondaryActionLink,
            resetFilters,
          }}
          ouiaId="host-module-stream-table"
          additionalListeners={[hostId, activeSortColumn, activeSortDirection,
            statusSelected, installStatusSelected, confirmModalJobCompleted,
            tableJobCompleted]}
          fetchItems={fetchItems}
          bookmarkController="katello_host_available_module_streams"
          readOnlyBookmarks={hideBookmarkActions}
          autocompleteEndpoint={`/hosts/${hostId}/module_streams/auto_complete_search`}
          foremanApiAutoComplete
          rowsCount={results?.length}
          variant={TableVariant.compact}
          requestKey={MODULE_STREAMS_KEY}
          alwaysShowActionButtons={false}
          actionButtons={
            <Split hasGutter>
              <SplitItem>
                <SelectableDropdown
                  id="status-dropdown"
                  title={MODULE_STREAM_STATUS}
                  showTitle={false}
                  items={Object.values(HOST_MODULE_STREAM_STATUSES)}
                  selected={statusSelected}
                  setSelected={handleModuleStreamStatusSelected}
                />
              </SplitItem>
              <SplitItem>
                <SelectableDropdown
                  id="install-status-dropdown"
                  title={MODULE_STREAM_INSTALLATION_STATUS}
                  showTitle={false}
                  items={Object.values(INSTALLED_STATE)}
                  selected={installStatusSelected}
                  setSelected={handleModuleStreamInstallationStatusSelected}
                />
              </SplitItem>
            </Split>
          }
        >
          <Thead>
            <Tr>
              <SortableColumnHeaders
                columnHeaders={columnHeaders}
                pfSortParams={pfSortParams}
                columnsToSortParams={COLUMNS_TO_SORT_PARAMS}
              />
            </Tr>
          </Thead>
          <Tbody>
            {results?.map(({
              id,
              status: moduleStreamStatus,
              name,
              stream,
              installed_profiles: installedProfiles,
              upgradable,
              install_status: installedStatus,
              module_spec: moduleSpec,
            }, index) => {
              /* eslint-disable react/no-array-index-key */
              const dropdownItems = [
                <DropdownItem key={`dropdownItem-checkbox-${id}`}>
                  <Checkbox
                    aria-label={`customize-checkbox-${id}`}
                    id={`Checkbox${id}`}
                    label={__('Customize with Rex')}
                    isChecked={id === useCustomizedRex}
                    onChange={checked => (checked ? setUseCustomizedRex(id) : setUseCustomizedRex(''))}
                  />
                </DropdownItem>,
                <DropdownSeparator key={`separator-${id}`} />,

              ];
              if (id === useCustomizedRex) {
                dropdownItems.push(
                  <DropdownItem
                    aria-label={`enable-${id}-href`}
                    key={`dropdownItem-enable-url-${id}`}
                    component="a"
                    href={customizedActionURL('enable', moduleSpec)}
                    isDisabled={stateText(moduleStreamStatus) ===
                    HOST_MODULE_STREAM_STATUSES.ENABLED}
                  >
                    {__('Enable')}
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`disable-${id}-href`}
                    key={`dropdownItem-disable-url-${id}`}
                    component="a"
                    href={customizedActionURL('disable', moduleSpec)}
                    isDisabled={stateText(moduleStreamStatus) !==
                    HOST_MODULE_STREAM_STATUSES.ENABLED}
                  >
                    {__('Disable')}
                    <InactiveText style={{ marginBottom: '1px' }} text={__('Prevent from further updates')} />
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`install-${id}-href`}
                    key={`dropdownItem-install-url-${id}`}
                    component="a"
                    href={customizedActionURL('install', moduleSpec)}
                    isDisabled={(upgradable ||
                      (installedStatus !== INSTALLED_STATE.NOTINSTALLED) ||
                      !(stateText(moduleStreamStatus) === HOST_MODULE_STREAM_STATUSES.ENABLED ||
                        stateText(moduleStreamStatus) === HOST_MODULE_STREAM_STATUSES.DISABLED)
                    )}
                  >
                    {__('Install')}
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`update-${id}-href`}
                    key={`dropdownItem-update-${id}`}
                    component="a"
                    href={customizedActionURL('update', moduleSpec)}
                    isDisabled={!upgradable}
                  >
                    {__('Update')}
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`reset-${id}-href`}
                    key={`dropdownItem-reset-${id}`}
                    component="a"
                    href={customizedActionURL('reset', moduleSpec)}
                  >
                    {__('Reset')}
                    <InactiveText style={{ marginBottom: '1px' }} text={__('Reset to the default state')} />
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`remove-${id}-href`}
                    key={`dropdownItem-remove-${id}`}
                    component="a"
                    href={customizedActionURL('remove', moduleSpec)}
                  >
                    {__('Remove')}
                    <InactiveText style={{ marginBottom: '1px' }} text={__('Uninstall and reset')} />
                  </DropdownItem>,
                );
              } else {
                dropdownItems.push(
                  <DropdownItem
                    aria-label={`enable-${id}-button`}
                    key={`dropdownItem-enable-${id}`}
                    component="button"
                    onClick={() => {
                      triggerModuleStreamAction({ hostname, action: 'enable', moduleSpec });
                      setUseCustomizedRex('');
                      setDropdownOpen('');
                    }}
                    isDisabled={actionInProgress || stateText(moduleStreamStatus) ===
                    HOST_MODULE_STREAM_STATUSES.ENABLED}
                  >
                    {__('Enable')}
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`disable-${id}-button`}
                    key={`dropdownItem-disable-${id}`}
                    component="button"
                    onClick={() => {
                      setActionableModuleSpec(moduleSpec);
                      setHostModuleStreamAction('disable');
                      setActionModalOpen(true);
                      setUseCustomizedRex('');
                      setDropdownOpen('');
                    }}
                    isDisabled={actionInProgress || stateText(moduleStreamStatus) !==
                    HOST_MODULE_STREAM_STATUSES.ENABLED}
                  >
                    {__('Disable')}
                    <InactiveText style={{ marginBottom: '1px' }} text={__('Prevent from further updates')} />
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`install-${id}-button`}
                    key={`dropdownItem-install-${id}`}
                    component="button"
                    onClick={() => {
                      triggerModuleStreamAction({ hostname, action: 'install', moduleSpec });
                      setUseCustomizedRex('');
                      setDropdownOpen('');
                    }}
                    isDisabled={(actionInProgress || upgradable ||
                      (installedStatus !== INSTALLED_STATE.NOTINSTALLED) ||
                      !(stateText(moduleStreamStatus) === HOST_MODULE_STREAM_STATUSES.ENABLED ||
                        stateText(moduleStreamStatus) === HOST_MODULE_STREAM_STATUSES.DISABLED)
                    )}
                  >
                    {__('Install')}
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`update-${id}-button`}
                    key={`dropdownItem-update-${id}`}
                    component="button"
                    onClick={() => {
                      triggerModuleStreamAction({ hostname, action: 'update', moduleSpec });
                      setUseCustomizedRex('');
                      setDropdownOpen('');
                    }}
                    isDisabled={actionInProgress || !upgradable}
                  >
                    {__('Update')}
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`reset-${id}-button`}
                    key={`dropdownItem-reset-${id}`}
                    component="button"
                    onClick={() => {
                      setActionableModuleSpec(moduleSpec);
                      setHostModuleStreamAction('reset');
                      setActionModalOpen(true);
                      setUseCustomizedRex('');
                      setDropdownOpen('');
                    }}
                    isDisabled={actionInProgress}
                  >
                    {__('Reset')}
                    <InactiveText style={{ marginBottom: '1px' }} text={__('Reset to the default state')} />
                  </DropdownItem>,
                  <DropdownItem
                    aria-label={`remove-${id}-button`}
                    key={`dropdownItem-remove-${id}`}
                    component="button"
                    onClick={() => {
                      setActionableModuleSpec(moduleSpec);
                      setHostModuleStreamAction('remove');
                      setActionModalOpen(true);
                      setUseCustomizedRex('');
                      setDropdownOpen('');
                    }}
                    isDisabled={actionInProgress}
                  >
                    {__('Remove')}
                    <InactiveText style={{ marginBottom: '1px' }} text={__('Uninstall and reset')} />
                  </DropdownItem>,
                );
              }
              return (
                <Tr key={`${id} ${index}`}>
                  <Td>
                    <a
                      href={`/module_streams?search=module_spec%3D${moduleSpec}+and+host%3D${hostname}`}
                    >
                      {name}
                    </a>
                  </Td>
                  <Td>
                    <StreamState moduleStreamStatus={moduleStreamStatus} />
                  </Td>
                  <Td>{stream}</Td>
                  <Td>
                    <EnabledIcon
                      streamText={moduleStreamStatus}
                      streamInstallStatus={installedProfiles}
                      upgradable={upgradable}
                    />
                  </Td>
                  <Td>
                    <HostInstalledProfiles
                      moduleStreamStatus={moduleStreamStatus}
                      installedProfiles={installedProfiles}
                    />
                  </Td>
                  {showActions && (
                    <Td key={`actions-td-${id}-${dropdownOpen}`}>
                      <Dropdown
                        aria-label={`actions-dropdown-${id}`}
                        key={`actions-dropdown-${id}-${dropdownOpen}`}
                        isPlain
                        style={{ width: 'inherit' }}
                        position={DropdownPosition.right}
                        toggle={
                          <KebabToggle aria-label={`kebab-dropdown-${id}`} onToggle={() => ((dropdownOpen === id) ? setDropdownOpen('') : setDropdownOpen(id))} id={`toggle-dropdown-${id}`} />
                      }
                        isOpen={id === dropdownOpen}
                        dropdownItems={dropdownItems}
                      />
                    </Td>
                  )}
                </Tr>
              );
            })
            }
          </Tbody>
        </TableWrapper>
        {actionModalOpen &&
          <ModuleActionConfirmationModal
            hostname={hostname}
            action={hostModuleStreamAction}
            moduleSpec={actionableModuleSpec}
            actionModalOpen={actionModalOpen}
            setActionModalOpen={setActionModalOpen}
            triggerModuleStreamAction={triggerConfirmModalAction}
          />
        }
      </div>
    </div>
  );
};

export default ModuleStreamsTab;
