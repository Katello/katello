import React, { useState } from 'react';
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
} from '@patternfly/react-core';
import { WrenchIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import EnableTracerModal from './EnableTracerModal';
import { startPollingJob, stopPollingJob } from '../RemoteExecutionActions';
import { refreshHostDetails } from '../../HostDetailsActions';

const EnableTracerEmptyState = () => {
  const title = __('Traces are not enabled');
  const body = __('Traces help administrators identify applications that need to be restarted after a system is patched.');
  const [enableTracerModalOpen, setEnableTracerModalOpen] = useState(false);
  const [isPolling, setIsPolling] = useState(null);
  const [pollingComplete, setPollingComplete] = useState(false);
  const dispatch = useDispatch();

  const stopRexJobPolling = ({ jobId }) => {
    dispatch(stopPollingJob({ key: `INSTALL_TRACER_${jobId}` }));
  };
  const handleSuccess = (resp) => {
    const { data } = resp;
    const { statusLabel, id } = propsToCamelCase(data);
    const hostName = data.targeting.hosts[0].name;
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

  return (
    <EmptyState variant={EmptyStateVariant.small}>
      <EmptyStateIcon icon={WrenchIcon} />
      <Title headingLevel="h2" size="lg">
        {title}
      </Title>
      <EmptyStateBody>
        <Flex direction={{ default: 'column' }}>
          <FlexItem>{body}</FlexItem>
          <FlexItem>
            <Button
              onClick={() => setEnableTracerModalOpen(true)}
              isDisabled={isPolling || pollingComplete}
            >
              {__('Enable Traces')}
            </Button>
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

export default EnableTracerEmptyState;
