import React from 'react';
import PropTypes from 'prop-types';
import { Label, Tooltip } from '@patternfly/react-core';
import {
  CheckCircleIcon,
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
  BanIcon,
  PauseCircleIcon,
} from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import {
  SYNC_STATE_STOPPED,
  SYNC_STATE_ERROR,
  SYNC_STATE_NEVER_SYNCED,
  SYNC_STATE_CANCELED,
  SYNC_STATE_PAUSED,
  SYNC_STATE_LABELS,
} from '../SyncStatusConstants';

const SyncResultCell = ({ repo }) => {
  const { raw_state, state, start_time, sync_id, error_details } = repo;

  const getVariantAndIcon = () => {
    switch (raw_state) {
      case SYNC_STATE_STOPPED:
        return { color: 'green', icon: <CheckCircleIcon /> };
      case SYNC_STATE_ERROR:
        return { color: 'red', icon: <ExclamationCircleIcon /> };
      case SYNC_STATE_CANCELED:
        return { color: 'orange', icon: <BanIcon /> };
      case SYNC_STATE_PAUSED:
        return { color: 'blue', icon: <PauseCircleIcon /> };
      case SYNC_STATE_NEVER_SYNCED:
        return { color: 'grey', icon: <ExclamationTriangleIcon /> };
      default:
        return { color: 'grey', icon: null };
    }
  };

  const { color, icon } = getVariantAndIcon();
  const label = SYNC_STATE_LABELS[raw_state] || state;

  const taskUrl = sync_id ? foremanUrl(`/foreman_tasks/tasks/${sync_id}`) : null;

  const labelContent = (
    <Label color={color} icon={icon}>
      {taskUrl ? (
        <a href={taskUrl} target="_blank" rel="noopener noreferrer">
          {label}
        </a>
      ) : (
        label
      )}
      {start_time && ` - ${start_time}`}
    </Label>
  );

  if (error_details) {
    const errorText = Array.isArray(error_details)
      ? error_details.join('\n')
      : error_details;

    if (errorText && errorText.length > 0) {
      return (
        <Tooltip content={errorText}>
          {labelContent}
        </Tooltip>
      );
    }
  }

  return labelContent;
};

SyncResultCell.propTypes = {
  repo: PropTypes.shape({
    raw_state: PropTypes.string,
    state: PropTypes.string,
    start_time: PropTypes.string,
    sync_id: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
    error_details: PropTypes.any,
  }).isRequired,
};

export default SyncResultCell;
