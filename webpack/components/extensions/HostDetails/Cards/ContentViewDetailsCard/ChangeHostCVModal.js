import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { Modal, Button, Alert, Checkbox, TextContent, Text, TextVariants } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { useUrlParams } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import EnvironmentPaths from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../../services/api';
import getContentViews from '../../../../../scenes/ContentViews/ContentViewsActions';
import { selectContentViews, selectContentViewStatus } from '../../../../../scenes/ContentViews/ContentViewSelectors';
import updateHostContentViewAndEnvironment, { runSubmanRepos } from './HostContentViewActions';
import HOST_CV_AND_ENV_KEY from './HostContentViewConstants';
import { getHostDetails } from '../../HostDetailsActions';
import ContentViewSelect from '../../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelect';
import ContentViewSelectOption
  from '../../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelectOption';
import { getCVPlaceholderText } from '../../../../../scenes/ContentViews/components/ContentViewSelect/helpers';
import { useRexJobPolling } from '../../Tabs/RemoteExecutionHooks';
import './ChangeHostCVModal.scss';
import { selectEnvironmentPaths } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathSelectors';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const ChangeHostCVModal = ({
  isOpen,
  closeModal,
  hostEnvId,
  orgId,
  hostId,
  contentSourceId,
  hostName,
  multiEnv,
}) => {
  const { content_view_assignment: initialCVModalOpen } = useUrlParams();
  const [selectedEnvForHost, setSelectedEnvForHost]
    = useState([]);

  const [selectedCVForHost, setSelectedCVForHost] = useState(null);
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const [forceProfileUpload, setForceProfileUpload] = useState(false);
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(state => selectContentViews(state, `FOR_ENV_${hostEnvId}`));
  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const environments = environmentPathResponse?.results?.map(path => path.environments).flat();
  const { results } = contentViewsInEnvResponse;
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, `FOR_ENV_${hostEnvId}`));
  const hostUpdateStatus = useSelector(state => selectAPIStatus(state, HOST_CV_AND_ENV_KEY));
  const pathsUrl = `/organizations/${orgId}/environments/paths?permission_type=promotable${contentSourceId ? `&content_source_id=${contentSourceId}` : ''}`;
  useAPI( // No TableWrapper here, so we can useAPI from Foreman
    'get',
    api.getApiUrl(pathsUrl),
    ENV_PATH_OPTIONS,
  );
  const selectedCVForHostId = results?.find(cv => cv.name === selectedCVForHost)?.id;

  const handleModalClose = () => {
    setCVSelectOpen(false);
    setForceProfileUpload(false);
    setSelectedCVForHost(null);
    setSelectedEnvForHost([]);
    closeModal();
  };

  const handleCancel = () => {
    handleModalClose();
    if (initialCVModalOpen) {
      window.history.back();
    }
  };

  const selectedEnv = selectedEnvForHost?.[0];
  const selectedEnvId = selectedEnv?.id;

  const handleCVSelect = (event, selection) => {
    setSelectedCVForHost(selection);
    setCVSelectOpen(false);
  };

  const handleEnvSelect = (selection) => {
    dispatch(getContentViews({
      environment_id: selection[0].id,
      include_default: true,
      full_result: true,
      order: 'default DESC', // show Default Organization View first
    }, `FOR_ENV_${hostEnvId}`));
    setSelectedCVForHost(null);
    setSelectedEnvForHost(selection);
  };
  const { results: contentViewsInEnv = [] } = contentViewsInEnvResponse;
  const canSave = !!(selectedCVForHost && selectedEnvForHost.length);

  const { triggerJobStart } =
    useRexJobPolling(runSubmanRepos, () => getHostDetails({ hostname: hostName }));

  const refreshHostDetails = () => {
    if (forceProfileUpload) {
      triggerJobStart(hostName);
    }
    handleModalClose();
    return dispatch(getHostDetails({ hostname: hostName }));
  };

  const handleSave = () => {
    const requestBody = {
      id: hostId,
      host: {
        content_facet_attributes: {
          content_view_id: selectedCVForHostId,
          lifecycle_environment_id: selectedEnvId,
        },
      },
    };
    dispatch(updateHostContentViewAndEnvironment(
      requestBody, hostId,
      refreshHostDetails, handleModalClose,
    ));
  };

  const cvPlaceholderText = getCVPlaceholderText({
    environments: selectedEnvForHost,
    cvSelectOptions: contentViewsInEnv,
    contentViewsStatus: contentViewsInEnvStatus,
  });

  const stillLoading =
    (contentViewsInEnvStatus === STATUS.PENDING || hostUpdateStatus === STATUS.PENDING);
  const noContentViewsAvailable =
    (contentViewsInEnv.length === 0 || selectedEnvForHost.length === 0);

  const modalActions = ([
    <Button
      key="add"
      ouiaId="change-host-cv-modal-add-button"
      variant="primary"
      onClick={handleSave}
      isDisabled={!canSave}
      isLoading={hostUpdateStatus === STATUS.PENDING}
    >
      {__('Save')}
    </Button>,
    <Button key="cancel" ouiaId="change-host-cv-modal-cancel-button" variant="link" onClick={handleCancel}>
      {__('Cancel')}
    </Button>,
  ]);
  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      onEscapePress={handleModalClose}
      title={__('Edit content view assignment')}
      width="50%"
      position="top"
      actions={modalActions}
      id="change-host-cv-modal"
      key={`change-host-cv-modal-${hostId}`}
      ouiaId="change-host-cv-modal"
    >
      {contentViewsInEnvStatus === STATUS.RESOLVED &&
        !!selectedEnvForHost.length && contentViewsInEnv.length === 0 &&
        <Alert
          ouiaId="no-cv-alert"
          variant="warning"
          isInline
          title={__('No content views available for the selected environment')}
          style={{ marginBottom: '1rem' }}
        >
          <a href="/content_views">{__('View the Content Views page')}</a>
          {__(' to manage and promote content views, or select a different environment.')}
        </Alert>
      }
      {environments?.some(env => env?.content_source?.environment_is_associated === false) &&
        <Alert
          variant="info"
          ouiaId="disabled-environments-alert"
          isInline
          title={__('Some environments are disabled because they are not associated with the host\'s content source.')}
          style={{ marginBottom: '1rem' }}
        >
          {__('To enable them, add the environment to the host\'s content source, or ')}
          <a href={`/change_host_content_source?host_id=${hostId}`}>{__('change the host\'s content source.')}</a>
        </Alert>
      }
      {multiEnv &&
        <Alert
          variant="warning"
          ouiaId="multi-env-alert"
          isInline
          title={__('This host is associated with multiple content view environments. If you assign a lifecycle environment and content view here, the host will be removed from the other environments.')}
          style={{ marginBottom: '1rem' }}
        />
      }
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHost}
        setUserCheckedItems={handleEnvSelect}
        publishing={false}
        multiSelect={false}
        hostId={hostId}
        headerText={__('Select lifecycle environment')}
        isDisabled={hostUpdateStatus === STATUS.PENDING}
      />
      <ContentViewSelect
        selections={selectedCVForHost}
        onClear={() => setSelectedCVForHost(null)}
        onSelect={handleCVSelect}
        isOpen={cvSelectOpen}
        isDisabled={stillLoading || noContentViewsAvailable}
        onToggle={isExpanded => setCVSelectOpen(isExpanded)}
        placeholderText={cvPlaceholderText}
      >
        {(contentViewsInEnv.length !== 0 && selectedEnvForHost.length !== 0) &&
            contentViewsInEnv?.map(cv => (
              <ContentViewSelectOption
                key={cv.id}
                value={cv.name}
                cv={cv}
                env={selectedEnvForHost[0]}
              />
            ))}
      </ContentViewSelect>
      <hr />
      <TextContent>
        <Text component={TextVariants.small} ouiaId="force-profile-upload-text">
          {forceProfileUpload ? __('Errata and package information will be updated immediately.') : __('Errata and package information will be updated at the next host check-in or package action.')}
        </Text>
      </TextContent>
      <Checkbox
        isChecked={forceProfileUpload}
        onChange={(_event, val) => setForceProfileUpload(val)}
        label={__('Update the host immediately via remote execution')}
        id="force-profile-upload-checkbox"
        ouiaId="force-profile-upload-checkbox"
        isDisabled={!selectedCVForHost}
      />
      <hr />
    </Modal>
  );
};

ChangeHostCVModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  hostEnvId: PropTypes.number,
  orgId: PropTypes.number.isRequired,
  hostId: PropTypes.number.isRequired,
  contentSourceId: PropTypes.number,
  hostName: PropTypes.string.isRequired,
  multiEnv: PropTypes.bool,
};

ChangeHostCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  hostEnvId: null,
  contentSourceId: null,
  multiEnv: false,
};


export default ChangeHostCVModal;
