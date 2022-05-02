import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import {
  EmptyState,
  EmptyStateIcon,
  EmptyStateBody,
  Title,
  EmptyStateVariant,
  Button,
  Flex,
  FlexItem,
  Spinner,
} from '@patternfly/react-core';
import { WrenchIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import EnableTracerModal from './EnableTracerModal';
import { startPollingJob, stopPollingJob } from '../RemoteExecutionActions';
import { refreshHostDetails } from '../../HostDetailsActions';

const EnableTracerButton = ({ setEnableTracerModalOpen, enabling }) => (
  <Button
    onClick={() => setEnableTracerModalOpen(true)}
    isDisabled={enabling}
  >
    {__('Enable Traces')}
  </Button>
);

const ViewTaskButton = ({ jobId }) => (
  <Button
    component="a"
    href={urlBuilder('job_invocations', '', jobId)}
    variant="secondary"
  >
    {__('View the job')}
  </Button>
);

ViewTaskButton.propTypes = {
  jobId: PropTypes.string.isRequired,
};

EnableTracerButton.propTypes = {
  setEnableTracerModalOpen: PropTypes.func.isRequired,
  enabling: PropTypes.bool.isRequired,
};

const TracesEnabler = () => {
  const title = __('Traces are not enabled');
  const enablingTitle = __('Traces are being enabled');
  const body = __('Traces help administrators identify applications that need to be restarted after a system is patched.');
  const [enableTracerModalOpen, setEnableTracerModalOpen] = useState(false);
  const [isPolling, setIsPolling] = useState(null);
  const [pollingComplete, setPollingComplete] = useState(false);
  const [rexJobId, setRexJobId] = useState(null);
  const dispatch = useDispatch();

  const stopRexJobPolling = ({ jobId }) => {
    dispatch(stopPollingJob({ key: `INSTALL_TRACER_${jobId}` }));
  };
  const handleSuccess = (resp) => {
    const { data } = resp;
    const { statusLabel, id } = propsToCamelCase(data);
    const hostName = data.targeting.hosts[0].name;
    setRexJobId(id);
    if (statusLabel !== 'running') {
      setPollingComplete(true);
      setIsPolling(false);
      stopRexJobPolling({ jobId: id });
    }
    if (statusLabel === 'succeeded') {
      dispatch(refreshHostDetails({ hostName }));
    }
  };
  const startRexJobPolling = ({ jobId }) => {
    setIsPolling(true);
    setEnableTracerModalOpen(false);
    dispatch(startPollingJob({ key: `INSTALL_TRACER_${jobId}`, jobId, handleSuccess }));
  };
  const enabling = (isPolling || pollingComplete);

  return (
    <EmptyState variant={EmptyStateVariant.small}>
      {enabling ?
        <Spinner /> :
        <EmptyStateIcon icon={WrenchIcon} />
      }
      <Title headingLevel="h2" size="lg">
        {enabling ? enablingTitle : title}
      </Title>
      <EmptyStateBody>
        <Flex direction={{ default: 'column' }}>
          <FlexItem>{body}</FlexItem>
          <FlexItem>
            {enabling ?
              <ViewTaskButton jobId={rexJobId} /> :
              <EnableTracerButton {...{ setEnableTracerModalOpen, enabling }} />
            }
          </FlexItem>
        </Flex>
      </EmptyStateBody>
      <EnableTracerModal
        isOpen={enableTracerModalOpen}
        setIsOpen={setEnableTracerModalOpen}
        startRexJobPolling={startRexJobPolling}
      />
    </EmptyState>
  );
};

export default TracesEnabler;
