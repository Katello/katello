import React from 'react';
import PropTypes from 'prop-types';
import { Progress, Button, Flex, FlexItem } from '@patternfly/react-core';
import { TimesIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl, propsToCamelCase } from 'foremanReact/common/helpers';
import { SYNC_STATE_RUNNING } from '../SyncStatusConstants';

const SyncProgressCell = ({ repo, onCancelSync }) => {
  const {
    isRunning, progress, rawState, id, syncId,
  } = propsToCamelCase(repo);

  if (!isRunning || rawState !== SYNC_STATE_RUNNING) {
    return null;
  }

  const progressValue = Math.max(0, Math.min(100, progress?.progress || 0));
  const taskUrl = syncId ? foremanUrl(`/foreman_tasks/tasks/${syncId}`) : null;

  return (
    <Flex alignItems={{ default: 'alignItemsCenter' }}>
      <FlexItem grow={{ default: 'grow' }}>
        {taskUrl ? (
          <a href={taskUrl} target="_blank" rel="noopener noreferrer">
            <Progress
              value={progressValue}
              title={__('Syncing')}
              size="sm"
            />
          </a>
        ) : (
          <Progress
            value={progressValue}
            title={__('Syncing')}
            size="sm"
          />
        )}
      </FlexItem>
      <FlexItem>
        <Button
          variant="plain"
          aria-label={__('Cancel sync')}
          onClick={() => onCancelSync(id)}
          ouiaId={`cancel-sync-${id}`}
        >
          <TimesIcon />
        </Button>
      </FlexItem>
    </Flex>
  );
};

SyncProgressCell.propTypes = {
  repo: PropTypes.shape({
    id: PropTypes.number,
    is_running: PropTypes.bool,
    progress: PropTypes.shape({
      progress: PropTypes.number,
    }),
    raw_state: PropTypes.string,
    sync_id: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  }).isRequired,
  onCancelSync: PropTypes.func.isRequired,
};

export default SyncProgressCell;
