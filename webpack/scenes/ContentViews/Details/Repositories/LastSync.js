import React, { Fragment } from 'react';
import { CheckCircleIcon, ExclamationTriangleIcon, ExclamationCircleIcon, InProgressIcon } from '@patternfly/react-icons';
import { foremanUrl } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import InactiveText from '../../components/InactiveText';

const LastSync = ({ lastSyncWords, lastSync, emptyMessage }) => {
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

    return (
      <a href={foremanUrl(`/foreman_tasks/tasks/${id}/`)}>
        <Icon style={{ color }} />&nbsp;{`${lastSyncWords} ago`}
      </a>
    );
  }
  return <InactiveText text={emptyMessage} />;
};

LastSync.propTypes = {
  lastSyncWords: PropTypes.string,
  lastSync: PropTypes.shape({
    id: PropTypes.string, // API returns string
    result: PropTypes.string,
  }),
  emptyMessage: PropTypes.string,
};

LastSync.defaultProps = {
  lastSyncWords: null,
  lastSync: null,
  emptyMessage: 'Not Synced',
};

export default LastSync;
