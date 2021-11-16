import React, { Fragment } from 'react';
import {
  CheckCircleIcon,
  ExclamationTriangleIcon,
  ExclamationCircleIcon,
  InProgressIcon,
} from '@patternfly/react-icons';
import { Tooltip, TooltipPosition } from '@patternfly/react-core';

import { foremanUrl } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import InactiveText from '../../components/InactiveText';
import { makeReadableDate } from '../../../../utils/dateTimeHelpers';

const LastSync = ({
  lastSyncWords, lastSync, emptyMessage, startedAt,
}) => {
  if (lastSync && lastSyncWords) {
    let Icon;
    let color = 'black';
    const { result, id } = lastSync;

    if (result === 'success' || result === 'successful') {
      Icon = CheckCircleIcon;
      color = 'green';
    } else if (result === 'warning') {
      Icon = ExclamationTriangleIcon;
      color = 'orange';
    } else if (result === 'error' || result === 'failed') {
      Icon = ExclamationCircleIcon;
      color = 'red';
    } else if (result === 'in progress' || result === 'pending') {
      Icon = InProgressIcon;
      color = 'blue';
    } else {
      Icon = Fragment;
    }

    if (startedAt) {
      return (
        <Tooltip
          position={TooltipPosition.top}
          content={makeReadableDate(startedAt)}
        >
          <a
            href={foremanUrl(`/foreman_tasks/tasks/${id}/`)}
            style={{
              display: 'inline-flex', alignItems: 'center', margin: 0,
            }}
          >
            <Icon style={{ color, marginRight: '5px' }} />
            <span>{lastSyncWords}{__(' ago')}</span>
          </a >
        </Tooltip >
      );
    }

    return (
      <a
        href={foremanUrl(`/foreman_tasks/tasks/${id}/`)}
        style={{
          display: 'flex', alignItems: 'center',
        }}
      >
        <Icon style={{ color, marginRight: '5px' }} />
        <span>{lastSyncWords}{__(' ago')}</span>
      </a >);
  }

  return <InactiveText text={emptyMessage} />;
};

LastSync.propTypes = {
  startedAt: PropTypes.string,
  lastSyncWords: PropTypes.string,
  lastSync: PropTypes.shape({
    id: PropTypes.string, // API returns string
    result: PropTypes.string,
  }),
  emptyMessage: PropTypes.string,
};

LastSync.defaultProps = {
  startedAt: undefined,
  lastSyncWords: undefined,
  lastSync: undefined,
  emptyMessage: 'Not Synced',
};

export default LastSync;
