import React, { useState, useCallback } from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { useDispatch, useSelector } from 'react-redux';
import { Modal, Button, Select, SelectOption, Alert, Flex } from '@patternfly/react-core';
import {
  global_palette_black_600 as pfDescriptionColor,
} from '@patternfly/react-tokens';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import EnvironmentPaths from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import api from '../../../../../services/api';
import getContentViews from '../../../../../scenes/ContentViews/ContentViewsActions';
import { selectContentViews, selectContentViewStatus } from '../../../../../scenes/ContentViews/ContentViewSelectors';
import { uniq } from '../../../../../utils/helpers';
import ContentViewIcon from '../../../../../scenes/ContentViews/components/ContentViewIcon';
import updateHostContentViewAndEnvironment from './HostContentViewActions';
import HOST_CV_AND_ENV_KEY from './HostContentViewConstants';
import { getHostDetails } from '../../HostDetailsActions';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const ContentViewDescription = ({ cv, versionNumber }) => {
  const descriptionStyle = {
    fontSize: '12px',
    fontWeight: 400,
    color: pfDescriptionColor.value,
  };
  if (cv.default) return <span style={descriptionStyle}>{__('Library')}</span>;
  return (
    <span style={descriptionStyle}>
      <FormattedMessage
        id={`content-view-${cv.id}-version-${cv.latest_version}`}
        defaultMessage="Version {versionNumber}"
        values={{ versionNumber }}
      />
    </span>
  );
};

ContentViewDescription.propTypes = {
  cv: PropTypes.shape({
    default: PropTypes.bool.isRequired,
    id: PropTypes.number.isRequired,
    latest_version: PropTypes.string.isRequired,
  }).isRequired,
  versionNumber: PropTypes.string.isRequired,
};

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
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, `FOR_ENV_${hostEnvId}`));
  const hostUpdateStatus = useSelector(state => selectAPIStatus(state, HOST_CV_AND_ENV_KEY));
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

  const relevantVersionObjFromCv = (cv, env) => { // returns the entire version object
    const versions = cv.versions.filter(version => new Set(version.environment_ids).has(env.id));
    return uniq(versions)?.[0];
  };
  const relevantVersionFromCv = (cv, env) =>
    relevantVersionObjFromCv(cv, env)?.version; // returns the version text e.g. "1.0"

  const refreshHostDetails = () => {
    handleModalClose();
    return dispatch(getHostDetails({ hostname: hostName }));
  };

  const handleSave = () => {
    const requestBody = {
      id: hostId,
      host: {
        content_facet_attributes: {
          content_view_id: selectedCVForHost,
          lifecycle_environment_id: selectedEnvId,
        },
      },
    };
    dispatch(updateHostContentViewAndEnvironment(
      requestBody, hostId,
      refreshHostDetails, handleModalClose,
    ));
  };

  const cvPlaceholderText = useCallback(() => {
    if (contentViewsInEnvStatus === STATUS.PENDING) return __('Loading...');
    if (contentViewsInEnvStatus === STATUS.ERROR) return __('Error loading content views');
    return (contentViewsInEnv.length === 0) ? __('No content views available') : __('Select a content view');
  }, [contentViewsInEnv.length, contentViewsInEnvStatus]);

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
      {selectedEnvForHost.length > 0 &&
      <div style={{ marginTop: '1em' }}>
        <h3>{__('Select content view')}</h3>
        <Select
          selections={selectedCVForHost}
          onSelect={handleCVSelect}
          isOpen={cvSelectOpen}
          menuAppendTo="parent"
          isDisabled={contentViewsInEnv.length === 0 || hostUpdateStatus === STATUS.PENDING}
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
            >
              <Flex
                direction={{ default: 'row', sm: 'row' }}
                flexWrap={{ default: 'nowrap' }}
                alignItems={{ default: 'alignItemsCenter', sm: 'alignItemsCenter' }}
              >
                <ContentViewIcon
                  composite={cv.composite}
                  size="sm"
                />
                <Flex
                  direction={{ default: 'column', sm: 'column' }}
                  flexWrap={{ default: 'nowrap' }}
                  alignItems={{ default: 'alignItemsFlexStart', sm: 'alignItemsFlexStart' }}
                >
                  {cv.name}
                  <ContentViewDescription
                    cv={cv}
                    versionNumber={relevantVersionFromCv(cv, selectedEnv)}
                  />
                </Flex>
              </Flex>
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
  hostId: PropTypes.number.isRequired,
  hostName: PropTypes.string.isRequired,
};

ChangeHostCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  hostEnvId: null,
};


export default ChangeHostCVModal;
