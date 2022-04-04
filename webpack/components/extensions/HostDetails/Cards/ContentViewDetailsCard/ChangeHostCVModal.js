import React, { useState, useCallback, useEffect } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { Modal, Button, Select, SelectOption } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import EnvironmentPaths from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../../services/api';
import CONTENT_VIEWS_KEY from '../../../../../scenes/ContentViews/ContentViewsConstants';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };
const CV_OPTIONS = { key: CONTENT_VIEWS_KEY };

const ChangeHostCVModal = ({
  isOpen,
  closeModal,
  hostEnvId,
  orgId,
}) => {
  const { response: envResponse } = useAPI( // No TableWrapper here, so we can useAPI from Foreman
    'get',
    api.getApiUrl(`/organizations/${orgId}/environments/paths?permission_type=promotable`),
    ENV_PATH_OPTIONS,
  );
  const { response: cvResponse } = useAPI(
    'get',
    api.getApiUrl(`/organizations/${orgId}/content_views`),
    CV_OPTIONS,
  );
  const { results: allContentViews } = cvResponse;
  const { results: envPaths } = envResponse ?? [];

  const initialEnvFromId = useCallback((paths, envId) => {
    const envFlatPaths = paths?.map(p => p.environments ?? []).flat();
    return envFlatPaths?.filter(e => e.id === envId) ?? [];
  }, []);
  const [selectedEnvForHost, setSelectedEnvForHost]
    = useState([]);

  const cvSelectionsFromEnvironment = useCallback((env) => {
    if (!env) return [];
    const defaultOrgView = allContentViews?.find(cv => cv.default);
    const cvIds = new Set(env.content_views.map(cv => cv.id));
    const cvSelections = allContentViews?.filter(cv => cvIds.has(cv.id));
    if (defaultOrgView && cvSelections && env.library) {
      return [defaultOrgView, ...cvSelections];
    }
    return cvSelections ?? [];
  }, [allContentViews]);

  const [selectedCVForHost, setSelectedCVForHost] = useState(null);
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const [cvSelectOptions, setCvSelectOptions] = useState([]);

  useEffect(() => {
    // set selectedEnvForHost when hostCurrentEnv is populated
    setSelectedEnvForHost(initialEnvFromId(envPaths, hostEnvId));
  }, [envPaths, hostEnvId, initialEnvFromId]);

  useEffect(() => {
    // set cvSelectOptions when selectedEnvForHost is populated
    setCvSelectOptions(cvSelectionsFromEnvironment(selectedEnvForHost[0]));
  }, [selectedEnvForHost, cvSelectionsFromEnvironment]);

  const onSelect = (event, selection) => {
    setSelectedCVForHost(selection);
    setCVSelectOpen(false);
  };

  const canSave = selectedCVForHost && selectedEnvForHost.length;

  useEffect(() => {
    const selectedCVIsValid = selectedCVForHost &&
        new Set(cvSelectOptions.map(cv => cv.latest_version_id)).has(selectedCVForHost);
    if (!selectedCVIsValid) {
      setSelectedCVForHost(null);
    }
  }, [cvSelectOptions, selectedCVForHost]);

  const modalActions = ([
    <Button key="add" variant="primary" onClick={closeModal} isDisabled={!canSave}>
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
      {selectedEnvForHost.length > 0 &&
      <div style={{ marginTop: '1em' }}>
        <h3>{__('Select content view')}</h3>
        <Select
          selections={selectedCVForHost}
          onSelect={onSelect}
          isOpen={cvSelectOpen}
          menuAppendTo="parent"
          isDisabled={cvSelectOptions.length === 0}
          onToggle={isExpanded => setCVSelectOpen(isExpanded)}
          ouiaId="select-content-view"
          id="selectCV"
          name="selectCV"
          aria-label="selectCV"
          placeholderText={(cvSelectOptions.length === 0) ? __('No content views available') : __('Select a content view')}
        >
          {cvSelectOptions.map(cv => (
            <SelectOption
              key={cv.id}
              value={cv.latest_version_id}
              description={
                <FormattedMessage
                  id={`content-view-${cv.id}-version-${cv.latest_version}`}
                  defaultMessage="Version {versionNumber}"
                  values={{ versionNumber: cv.latest_version }}
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
