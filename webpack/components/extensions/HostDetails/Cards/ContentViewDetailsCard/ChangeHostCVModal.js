import React, { useState, useCallback } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { useDispatch, useSelector } from 'react-redux';
import { Modal, Button, Select, SelectOption, Alert } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import EnvironmentPaths from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../../services/api';
import getContentViews from '../../../../../scenes/ContentViews/ContentViewsActions';
import { selectContentViewError, selectContentViews, selectContentViewStatus } from '../../../../../scenes/ContentViews/ContentViewSelectors';
import { uniq } from '../../../../../utils/helpers';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const ChangeHostCVModal = ({
  isOpen,
  closeModal,
  hostEnvId,
  orgId,
}) => {
  const [selectedEnvForHost, setSelectedEnvForHost]
    = useState([]);

  const [selectedCVForHost, setSelectedCVForHost] = useState(null);
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(state => selectContentViews(state, `FOR_ENV_${hostEnvId}`));
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, `FOR_ENV_${hostEnvId}`));
  const contentViewsInEnvError = useSelector(state => selectContentViewError(state, `FOR_ENV_${hostEnvId}`));

  useAPI( // No TableWrapper here, so we can useAPI from Foreman
    'get',
    api.getApiUrl(`/organizations/${orgId}/environments/paths?permission_type=promotable`),
    ENV_PATH_OPTIONS,
  );

  const handleModalClose = () => {
    setCVSelectOpen(false);
    setSelectedCVForHost(null);
    setSelectedEnvForHost([]);
    closeModal();
  };

  const selectedEnv = selectedEnvForHost?.[0];

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

  const relevantVersionObjFromCv = (cv, env) => { // returns the entire version object
    const versions = cv.versions.filter(version => new Set(version.environment_ids).has(env.id));
    return uniq(versions)?.[0];
  };
  const relevantVersionFromCv = (cv, env) =>
    relevantVersionObjFromCv(cv, env)?.version; // returns the version text e.g. "1.0"
  const relevantVersionIdFromCv = (cv, env) =>
    relevantVersionObjFromCv(cv, env)?.id; // returns the version's database id

  const cvPlaceholderText = useCallback(() => {
    if (contentViewsInEnvStatus === STATUS.PENDING) return __('Loading...');
    return (contentViewsInEnv.length === 0) ? __('No content views available') : __('Select a content view');
  }, [contentViewsInEnv.length, contentViewsInEnvStatus]);

  const modalActions = ([
    <Button key="add" variant="primary" onClick={handleModalClose} isDisabled={!canSave}>
      {__('Save')}
    </Button>,
    <Button key="cancel" variant="link" onClick={handleModalClose}>
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
    >
      {contentViewsInEnvStatus === STATUS.RESOLVED &&
        !!selectedEnvForHost.length && contentViewsInEnv.length === 0 &&
        <Alert
          variant="warning"
          isInline
          title={__('No content views available for the selected environment')}
          style={{ marginBottom: '1rem' }}
        >
          {__('View the Content Views page to manage and promote content views, or select a different environment.')}
        </Alert>
      }
      <EnvironmentPaths
        userCheckedItems={selectedEnvForHost}
        setUserCheckedItems={handleEnvSelect}
        publishing={false}
        multiSelect={false}
        headerText={__('Select environment')}
      />
      {selectedEnvForHost.length > 0 &&
      <div style={{ marginTop: '1em' }}>
        <h3>{__('Select content view')}</h3>
        <Select
          selections={selectedCVForHost}
          onSelect={handleCVSelect}
          isOpen={cvSelectOpen}
          menuAppendTo="parent"
          isDisabled={contentViewsInEnv.length === 0}
          onToggle={isExpanded => setCVSelectOpen(isExpanded)}
          ouiaId="select-content-view"
          id="selectCV"
          name="selectCV"
          aria-label="selectCV"
          placeholderText={cvPlaceholderText()}
        >
          {contentViewsInEnv?.map(cv => (
            <SelectOption
              key={cv.id}
              value={cv.id}
              description={cv.default ? __('Library') :
              <FormattedMessage
                id={`content-view-${cv.id}-version-${cv.latest_version}`}
                defaultMessage="Version {versionNumber}"
                values={{ versionNumber: relevantVersionFromCv(cv, selectedEnv) }}
              />}
            >
              {cv.name}
            </SelectOption>
          ))
          }
        </Select>
      </div>
      }
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
