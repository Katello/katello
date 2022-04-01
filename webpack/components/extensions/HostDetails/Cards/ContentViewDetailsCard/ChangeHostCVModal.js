import React, { useState, useCallback, useEffect } from 'react';
import PropTypes from 'prop-types';
import { Modal, Button } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import EnvironmentPaths from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../../services/api';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const ChangeHostCVModal = ({
  isOpen,
  closeModal,
  hostEnvId,
  orgId,
}) => {
  const { response } = useAPI(
    'get',
    api.getApiUrl(`/organizations/${orgId}/environments/paths?permission_type=promotable`),
    ENV_PATH_OPTIONS,
  );
  const { results: envPaths } = response ?? [];
  const initialEnvFromId = useCallback((paths, envId) => {
    const envFlatPaths = paths?.map(p => p.environments ?? []).flat();
    return envFlatPaths?.filter(e => e.id === envId) ?? [];
  }, []);
  const [selectedEnvForHost, setSelectedEnvForHost]
    = useState([]);

  useEffect(() => {
    // set selectedEnvForHost when hostCurrentEnv is populated
    setSelectedEnvForHost(initialEnvFromId(envPaths, hostEnvId));
  }, [envPaths, hostEnvId, initialEnvFromId]);

  const modalActions = ([
    <Button key="add" variant="primary" onClick={closeModal} isDisabled={false}>
      {__('Save')}
    </Button>,
    <Button key="cancel" variant="link" onClick={closeModal}>
      Cancel
    </Button>,
  ]);

  return (
    <Modal
      isOpen={isOpen}
      onClose={closeModal}
      title={__('Edit content view assignment')}
      width="50%"
      position="top"
      actions={modalActions}
      id="change-host-cv-modal"
    >
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHost}
        setUserCheckedItems={setSelectedEnvForHost}
        publishing={false}
        multiSelect={false}
        headerText={__('Select environment')}
      />
    </Modal>
  );
};

ChangeHostCVModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  hostEnvId: PropTypes.number,
  orgId: PropTypes.number.isRequired,
};

ChangeHostCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  hostEnvId: null,
};


export default ChangeHostCVModal;
