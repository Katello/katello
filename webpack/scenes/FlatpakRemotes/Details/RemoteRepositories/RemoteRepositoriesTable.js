import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  useTableIndexAPIResponse,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import LastSync from '../../../ContentViews/Details/Repositories/LastSync';
import { flatpakRemoteRepositoriesKey } from '../../FlatpakRemotesConstants';
import MirrorRepositoryModal from '../Mirror/MirrorRepositoryModal';
import './RemoteRepositoriesTable.css';

const RemoteRepositoriesTable = ({ frId, canMirror, lastScanId }) => {
  const [selectedRepo, setSelectedRepo] = useState(null);

  const apiUrl = `/katello/api/v2/flatpak_remotes/${frId}/flatpak_remote_repositories`;
  const apiOptions = { key: `${flatpakRemoteRepositoriesKey(frId)}_${lastScanId || ''}` };

  useTableIndexAPIResponse({
    apiUrl,
    apiOptions,
  });

  const openMirrorModal = (repo) => {
    setSelectedRepo(repo);
  };

  const closeMirrorModal = () => {
    setSelectedRepo(null);
  };

  const columns = {
    name: {
      title: __('Name'),
      isSorted: true,
    },
    id: {
      title: __('ID'),
      isSorted: true,
    },
    application_name: {
      title: __('Application name'),
    },
    last_mirrored: {
      title: __('Last mirrored'),
      wrapper: rowData => (
        <LastSync
          lastSyncWords={rowData.last_mirrored?.last_mirror_words}
          lastSync={{
            id: rowData.last_mirrored?.mirror_id,
            result: rowData.last_mirrored?.result,
          }}
          startedAt={rowData.last_mirrored?.started_at}
          emptyMessage={__('Never')}
        />
      ),
    },
    ...(canMirror && {
      mirror: {
        title: __('Mirror'),
        wrapper: rowData => (
          <Button
            variant="link"
            isInline
            ouiaId={`mirror-button-${rowData.id}`}
            onClick={() => openMirrorModal(rowData)}
          >
            {__('Mirror')}
          </Button>
        ),
      },
    }),
  };

  return (
    <>
      <TableIndexPage
        apiUrl={apiUrl}
        apiOptions={apiOptions}
        columns={columns}
        creatable={false}
        controller="/katello/api/v2/flatpak_remote_repositories"
        ouiaId="remote-repos-table"
      />
      {selectedRepo && (
        <MirrorRepositoryModal
          frId={frId}
          repo={selectedRepo}
          closeModal={closeMirrorModal}
        />
      )}
    </>
  );
};

RemoteRepositoriesTable.propTypes = {
  frId: PropTypes.number.isRequired,
  canMirror: PropTypes.bool.isRequired,
  lastScanId: PropTypes.string,
};

RemoteRepositoriesTable.defaultProps = {
  lastScanId: null,
};

export default RemoteRepositoriesTable;
