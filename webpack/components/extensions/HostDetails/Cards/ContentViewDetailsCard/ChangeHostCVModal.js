import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { Modal, Button, Alert } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import EnvironmentPaths from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../../services/api';
import getContentViews from '../../../../../scenes/ContentViews/ContentViewsActions';
import { selectContentViews, selectContentViewStatus } from '../../../../../scenes/ContentViews/ContentViewSelectors';
import updateHostContentViewAndEnvironment from './HostContentViewActions';
import HOST_CV_AND_ENV_KEY from './HostContentViewConstants';
import { getHostDetails } from '../../HostDetailsActions';
import ContentViewSelect from '../../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelect';
import ContentViewSelectOption
  from '../../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelectOption';
import { getCVPlaceholderText } from '../../../../../scenes/ContentViews/components/ContentViewSelect/helpers';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const ChangeHostCVModal = ({
  isOpen,
  closeModal,
  hostEnvId,
  orgId,
  hostId,
  hostName,
}) => {
  const [selectedEnvForHost, setSelectedEnvForHost]
    = useState([]);

  const [selectedCVForHost, setSelectedCVForHost] = useState(null);
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(state => selectContentViews(state, `FOR_ENV_${hostEnvId}`));
  const { results } = contentViewsInEnvResponse;
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, `FOR_ENV_${hostEnvId}`));
  const hostUpdateStatus = useSelector(state => selectAPIStatus(state, HOST_CV_AND_ENV_KEY));
  useAPI( // No TableWrapper here, so we can useAPI from Foreman
    'get',
    api.getApiUrl(`/organizations/${orgId}/environments/paths?permission_type=promotable`),
    ENV_PATH_OPTIONS,
  );
  const selectedCVForHostId = results?.find(cv => cv.name === selectedCVForHost)?.id;

  const handleModalClose = () => {
    setCVSelectOpen(false);
    setSelectedCVForHost(null);
    setSelectedEnvForHost([]);
    closeModal();
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

  const refreshHostDetails = () => {
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
    contentViews: contentViewsInEnv,
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
    <Button key="cancel" ouiaId="change-host-cv-modal-cancel-button" variant="link" onClick={handleModalClose}>
      Cancel
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
      ouiaId="change-host-cv-modal"
    >
      {contentViewsInEnvStatus === STATUS.RESOLVED &&
        !!selectedEnvForHost.length && contentViewsInEnv.length === 0 &&
        <Alert
          variant="warning"
          isInline
          title={__('No content views available for the selected environment')}
          style={{ marginBottom: '1rem' }}
        >
          <a href="/content_views">{__('View the Content Views page')}</a>
          {__(' to manage and promote content views, or select a different environment.')}
        </Alert>
      }
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHost}
        setUserCheckedItems={handleEnvSelect}
        publishing={false}
        multiSelect={false}
        headerText={__('Select environment')}
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
            contentViewsInEnv?.map(cv =>
              <ContentViewSelectOption key={cv.id} cv={cv} env={selectedEnvForHost[0]} />)}
      </ContentViewSelect>
    </Modal>
  );
};

ChangeHostCVModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  hostEnvId: PropTypes.number,
  orgId: PropTypes.number.isRequired,
  hostId: PropTypes.number.isRequired,
  hostName: PropTypes.string.isRequired,
};

ChangeHostCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  hostEnvId: null,
};


export default ChangeHostCVModal;
