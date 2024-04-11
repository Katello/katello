import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { Modal, Button, Alert, TextContent, Text, TextVariants } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import { ENVIRONMENT_PATHS_KEY } from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import EnvironmentPaths from '../../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import ContentViewSelect from '../../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelect';
import ContentViewSelectOption from '../../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelectOption';
import api from '../../../../../services/api';
import getContentViews from '../../../../../scenes/ContentViews/ContentViewsActions';
import { selectContentViews, selectContentViewStatus } from '../../../../../scenes/ContentViews/ContentViewSelectors';
import { bulkUpdateHostContentViewAndEnvironment } from './actions';
import { getCVPlaceholderText } from '../../../../../scenes/ContentViews/components/ContentViewSelect/helpers';
import HOST_CV_AND_ENV_KEY from '../../../HostDetails/Cards/ContentViewDetailsCard/HostContentViewConstants';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const BulkChangeHostCVModal = ({
  isOpen,
  closeModal,
  selectedCount,
  orgId,
  fetchBulkParams,
}) => {
  const [selectedLifecycleEnv, setSelectedLifecycleEnv]
    = useState([]);

  const [selectedContentView, setSelectedContentView] = useState(null);
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const dispatch = useDispatch();
  const contentViewsInEnvResponse = useSelector(state => selectContentViews(state, '_FOR_DEFAULT_ENV'));
  const { results } = contentViewsInEnvResponse;
  const contentViewsInEnvStatus = useSelector(state => selectContentViewStatus(state, '_FOR_DEFAULT_ENV'));
  const hostUpdateStatus = useSelector(state => selectAPIStatus(state, HOST_CV_AND_ENV_KEY));
  const pathsUrl = `/organizations/${orgId}/environments/paths?permission_type=promotable`;
  useAPI( // No TableWrapper here, so we can useAPI from Foreman
    'get',
    api.getApiUrl(pathsUrl),
    ENV_PATH_OPTIONS,
  );
  const selectedContentViewId = results?.find(cv => cv.name === selectedContentView)?.id;

  const handleModalClose = () => {
    setCVSelectOpen(false);
    setSelectedContentView(null);
    setSelectedLifecycleEnv([]);
    closeModal();
  };

  const selectedEnv = selectedLifecycleEnv?.[0];
  const selectedEnvId = selectedEnv?.id;

  const handleCVSelect = (event, selection) => {
    setSelectedContentView(selection);
    setCVSelectOpen(false);
  };

  const handleEnvSelect = (selection) => {
    dispatch(getContentViews({
      environment_id: selection[0].id,
      include_default: true,
      full_result: true,
      order: 'default DESC', // show Default Organization View first
    }, '_FOR_DEFAULT_ENV'));
    setSelectedContentView(null);
    setSelectedLifecycleEnv(selection);
  };
  const { results: contentViewsInEnv = [] } = contentViewsInEnvResponse;
  const canSave = !!(selectedContentView && selectedLifecycleEnv.length);

  const handleSave = () => {
    const requestBody = {
      content_view_id: selectedContentViewId,
      environment_id: selectedEnvId,
      organization_id: orgId,
      included: {
        search: fetchBulkParams(),
      },
    };
    dispatch(bulkUpdateHostContentViewAndEnvironment(
      requestBody, fetchBulkParams(),
      handleModalClose, handleModalClose,
    ));
  };

  const cvPlaceholderText = getCVPlaceholderText({
    environments: selectedLifecycleEnv,
    cvSelectOptions: contentViewsInEnv,
    contentViewsStatus: contentViewsInEnvStatus,
  });

  const stillLoading =
    (contentViewsInEnvStatus === STATUS.PENDING || hostUpdateStatus === STATUS.PENDING);
  const noContentViewsAvailable =
    (contentViewsInEnv.length === 0 || selectedLifecycleEnv.length === 0);

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
      title={__('Edit content view environments')}
      width="50%"
      position="top"
      actions={modalActions}
      id="change-host-cv-modal"
      key="bulk-change-host-cv-modal"
      ouiaId="bulk-change-host-cv-modal"
    >
      <TextContent>
        <Text
          ouiaId="bulk-change-cv-options-description"
        >
          <FormattedMessage
            defaultMessage={__('This will update the content view environments for {hosts}.')}
            values={{
              hosts: (
                <strong>
                  <FormattedMessage
                    defaultMessage="{count, plural, one {# {singular}} other {# {plural}}}"
                    values={{
                      count: selectedCount,
                      singular: __('selected host'),
                      plural: __('selected hosts'),
                    }}
                    id="ccs-options-i18n"
                  />
                </strong>
              ),
            }}
            id="bulk-change-cv-options-description-i18n"
          />
        </Text>
      </TextContent>
      {contentViewsInEnvStatus === STATUS.RESOLVED &&
        !!selectedLifecycleEnv.length && contentViewsInEnv.length === 0 &&
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
      <EnvironmentPaths
        userCheckedItems={selectedLifecycleEnv}
        setUserCheckedItems={handleEnvSelect}
        publishing={false}
        multiSelect={false}
        headerText={__('Select environment')}
        isDisabled={hostUpdateStatus === STATUS.PENDING}
      />
      <ContentViewSelect
        selections={selectedContentView}
        onClear={() => setSelectedContentView(null)}
        onSelect={handleCVSelect}
        isOpen={cvSelectOpen}
        isDisabled={stillLoading || noContentViewsAvailable}
        onToggle={isExpanded => setCVSelectOpen(isExpanded)}
        placeholderText={cvPlaceholderText}
      >
        {(contentViewsInEnv.length !== 0 && selectedLifecycleEnv.length !== 0) &&
            contentViewsInEnv?.map(cv => (
              <ContentViewSelectOption
                key={cv.id}
                value={cv.name}
                cv={cv}
                env={selectedLifecycleEnv[0]}
              />
            ))}
      </ContentViewSelect>
      <hr />
      <TextContent>
        <Text component={TextVariants.small} ouiaId="profile-upload-reminder-text">
          {__('Errata and package information will be updated at the next host check-in or package action.')}
        </Text>
      </TextContent>
      <hr />
    </Modal>
  );
};

BulkChangeHostCVModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  selectedCount: PropTypes.number.isRequired,
  orgId: PropTypes.number.isRequired,
  fetchBulkParams: PropTypes.func.isRequired,
};

BulkChangeHostCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
};


export default BulkChangeHostCVModal;
