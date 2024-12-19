import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  EmptyState,
  EmptyStateIcon,
  EmptyStateBody,
  EmptyStateVariant,
  Button,
  Flex,
  FlexItem,
  Spinner, EmptyStateHeader, EmptyStateFooter,
} from '@patternfly/react-core';
import { WrenchIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import EnableTracerModal from './EnableTracerModal';
import { useRexJobPolling } from '../RemoteExecutionHooks';
import { installTracerPackage } from './HostTracesActions';
import { getHostDetails } from '../../HostDetailsActions';

const EnableTracerButton = ({ setEnableTracerModalOpen, pollingStarted }) => (
  <Button
    onClick={() => setEnableTracerModalOpen(true)}
    isDisabled={pollingStarted}
    ouiaId="enable-traces-button"
  >
    {__('Enable Traces')}
  </Button>
);

const ViewTaskButton = ({ jobId }) => (
  <Button
    ouiaId="view-job-button"
    component="a"
    href={urlBuilder('job_invocations', '', jobId)}
    variant="secondary"
    isDisabled={!jobId}
  >
    {__('View the job')}
  </Button>
);

ViewTaskButton.propTypes = {
  jobId: PropTypes.number,
};
ViewTaskButton.defaultProps = {
  jobId: null,
};

EnableTracerButton.propTypes = {
  setEnableTracerModalOpen: PropTypes.func.isRequired,
  pollingStarted: PropTypes.bool.isRequired,
};

const TracesEnabler = ({ hostname, tracerRpmAvailable }) => {
  const title = __('Traces are not enabled');
  const enablingTitle = __('Traces are being enabled');
  const body = __('Traces help administrators identify applications that need to be restarted after a system is patched.');
  const [enableTracerModalOpen, setEnableTracerModalOpen] = useState(false);
  const initialAction = installTracerPackage({ hostname });
  const successAction = getHostDetails({ hostname });
  const {
    pollingStarted,
    rexJobId,
    triggerJobStart,
  } = useRexJobPolling(initialAction, successAction);

  return (
    <EmptyState variant={EmptyStateVariant.sm}>
      {pollingStarted ?
        <Spinner /> :
        <EmptyStateIcon icon={WrenchIcon} />
      }
      <EmptyStateHeader titleText={<>{pollingStarted ? enablingTitle : title}</>} headingLevel="h2" />
      <EmptyStateBody>
        <Flex direction={{ default: 'column' }}>
          <FlexItem>{body}</FlexItem>
          <FlexItem>
            {pollingStarted ?
              <ViewTaskButton jobId={rexJobId} /> :
              <EnableTracerButton {...{
                setEnableTracerModalOpen,
                pollingStarted,
              }}
              />
            }
          </FlexItem>
        </Flex>
      </EmptyStateBody>
      <EmptyStateFooter>
        <EnableTracerModal
          key={hostname}
          isOpen={enableTracerModalOpen}
          setIsOpen={setEnableTracerModalOpen}
          triggerJobStart={triggerJobStart}
          tracerRpmAvailable={tracerRpmAvailable}
        />
      </EmptyStateFooter>
    </EmptyState>
  );
};

TracesEnabler.propTypes = {
  hostname: PropTypes.string.isRequired,
  tracerRpmAvailable: PropTypes.bool.isRequired,
};

export default TracesEnabler;
