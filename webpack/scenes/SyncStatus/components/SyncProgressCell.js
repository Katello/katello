import React from 'react';
import PropTypes from 'prop-types';
import { Progress, Button, Flex, FlexItem } from '@patternfly/react-core';
import { TimesIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { SYNC_STATE_RUNNING } from '../SyncStatusConstants';

const SyncProgressCell = ({ repo, onCancelSync }) => {
  const { is_running, progress, raw_state, id } = repo;

  if (!is_running || raw_state !== SYNC_STATE_RUNNING) {
    return null;
  }

  const progressValue = progress?.progress || 0;

  return (
    <Flex alignItems={{ default: 'alignItemsCenter' }}>
      <FlexItem grow={{ default: 'grow' }}>
        <Progress
          value={progressValue}
          title={__('Syncing')}
          size="sm"
        />
      </FlexItem>
      <FlexItem>
        <Button
          variant="plain"
          aria-label={__('Cancel sync')}
          onClick={() => onCancelSync(id)}
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
  }).isRequired,
  onCancelSync: PropTypes.func.isRequired,
};

export default SyncProgressCell;
