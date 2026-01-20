import PropTypes from 'prop-types';
import { Flex, Text, Spinner } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import React from 'react';
import {
  ExclamationTriangleIcon,
  ExclamationCircleIcon,
} from '@patternfly/react-icons';
import { foremanUrl } from 'foremanReact/common/helpers';

const LastScan = ({
  lastScan, lastScanWords, isScanning, scanTaskId,
}) => {
  const showInProgress = isScanning || (lastScan && lastScan.progress < 1);

  if (showInProgress) {
    const taskId = lastScan?.id || scanTaskId;
    return (
      <Flex
        alignItems={{ default: 'alignItemsCenter' }}
        spaceItems={{ default: 'spaceItemsXs' }}
      >
        <Text ouiaId="fr-last-scan-text" component="span" style={{ fontWeight: 'bold' }}>
          {__('Last scan:')}
        </Text>
        <Spinner size="sm" isInline aria-label="Spinner" />
        <a href={foremanUrl(`/foreman_tasks/tasks/${taskId}`)}>
          {__('In progress')}
        </a>
      </Flex>
    );
  }

  if (lastScan && lastScanWords) {
    let Icon;
    let color = 'black';

    const { result } = lastScan;

    if (result === 'warning') {
      Icon = ExclamationTriangleIcon;
      color = 'orange';
    } else if (result === 'error' || result === 'failed') {
      Icon = ExclamationCircleIcon;
      color = 'red';
    }

    return (
      <Flex
        alignItems={{ default: 'alignItemsCenter' }}
        spaceItems={{ default: 'spaceItemsXs' }}
      >
        <Text ouiaId="fr-last-scan-text" component="span" style={{ fontWeight: 'bold' }}>
          {__('Last scan:')}
        </Text>
        <Text component="span" ouiaId="fr-last-scan-words-text">
          {Icon && <Icon style={{ color, marginRight: '5px' }} />}
          <span>{lastScanWords} {__('ago')}</span>
        </Text>
      </Flex>
    );
  }

  return null;
};

LastScan.propTypes = {
  lastScan: PropTypes.shape({
    id: PropTypes.string,
    progress: PropTypes.number,
    result: PropTypes.string,
  }),
  lastScanWords: PropTypes.string,
  isScanning: PropTypes.bool,
  scanTaskId: PropTypes.string,
};

LastScan.defaultProps = {
  lastScan: null,
  lastScanWords: '',
  isScanning: false,
  scanTaskId: null,
};

export default LastScan;
