import React, { useState } from 'react';
import { Modal, Button } from '@patternfly/react-core';
import { useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import { Thead, Th, Tbody, Tr, Td, TableVariant } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import PropTypes from 'prop-types';
import TableWrapper from '../../../Table/TableWrapper';
import { useBulkSelect } from '../../../Table/TableHooks';
import { HOST_APPLICABLE_PACKAGES_KEY } from '../ApplicablePackages/ApplicablePackagesConstants';
import { selectHostApplicablePackagesStatus } from '../ApplicablePackages/ApplicablePackagesSelectors';
import { getHostApplicablePackages } from '../ApplicablePackages/ApplicablePackagesActions';
import './PackageInstallModal.scss';

const PackageInstallModal = ({
  isOpen, closeModal, hostId, hostName,
}) => {
  const emptyContentTitle = __('No packages available to install');
  const emptyContentBody = __('No packages applicable to this host. Please check the host\'s content view and environment.');
  const emptySearchTitle = __('No matching packages found');
  const emptySearchBody = __('Try changing your search settings.');
  const columnHeaders = ['', __('Package'), __('Version')];
  const response = useSelector(state => selectAPIResponse(state, HOST_APPLICABLE_PACKAGES_KEY));
  const status = useSelector(state => selectHostApplicablePackagesStatus(state));
  const { results, ...metadata } = response;
  const [suppressFirstFetch, setSuppressFirstFetch] = useState(false);

  const {
    searchQuery,
    updateSearchQuery,
    isSelected,
    selectOne,
    selectNone,
    fetchBulkParams,
    isSelectable,
    selectedCount,
    ...selectAll
  } = useBulkSelect({ results, metadata });
  const fetchItems = (params) => {
    if (!hostId) return { type: 'HOST_ID_NOT_AVAILABLE_NOOP' };

    if (results?.length > 0 && suppressFirstFetch) {
      // If the modal has already been opened, no need to re-fetch the data that's already present
      setSuppressFirstFetch(false);
      return { type: 'HOST_APPLICABLE_PACKAGES_NOOP' };
    }
    return getHostApplicablePackages(hostId, params);
  };

  const handleModalClose = () => {
    setSuppressFirstFetch(true);
    closeModal();
  };

  const modalActions = ([
    <Button key="confirm" variant="primary" onClick={() => console.log('install')}>
      Install
    </Button>,
    <Button key="cancel" variant="link" onClick={handleModalClose}>
      Cancel
    </Button>,
  ]);

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleModalClose}
      title={__('Install packages')}
      width="50%"
      actions={modalActions}
      id="package-install-modal"
    >
      <FormattedMessage
        className="pkg-install-modal-blurb"
        id="pkg-install-modal-blurb"
        defaultMessage={__('Select packages to install to the host {hostName}.')}
        values={{
          hostName: <strong>{hostName}</strong>,
        }}
      />
      <TableWrapper
        {...{
          metadata,
          emptyContentTitle,
          emptyContentBody,
          emptySearchTitle,
          emptySearchBody,
          status,
          searchQuery,
          updateSearchQuery,
          selectedCount,
          selectNone,
        }
        }
        additionalListeners={[hostId]}
        fetchItems={fetchItems}
        searchPlaceholderText={__('Search available packages')}
        autocompleteEndpoint={`/hosts/${hostId}/packages/auto_complete_search`}
        foremanApiAutoComplete
        variant={TableVariant.compact}
        {...selectAll}
        displaySelectAllCheckbox
      >
        <Thead>
          <Tr>
            {columnHeaders.map(col =>
              <Th key={col}>{col}</Th>)}
            <Th />
          </Tr>
        </Thead>
        <Tbody>
          {results?.map((pkg, rowIndex) => {
            const {
              id,
              name: packageName,
              rpm_id: rpmId,
              version,
            } = pkg;
            return (
              <Tr key={id}>
                <Td
                  select={{
                      disable: false,
                      isSelected: isSelected(id),
                      onSelect: (_event, selected) => selectOne(selected, id),
                      rowIndex,
                      variant: 'checkbox',
                  }}
                />
                <Td>
                  {rpmId
                    ? <a href={urlBuilder(`packages/${rpmId}`, '')}>{packageName}</a>
                    : packageName
                  }
                </Td>
                <Td>
                  {version}
                </Td>
              </Tr>
            );
          })
          }
        </Tbody>
      </TableWrapper>
    </Modal>
  );
};

PackageInstallModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  closeModal: PropTypes.func.isRequired,
  hostId: PropTypes.number.isRequired,
  hostName: PropTypes.string.isRequired,
};

export default PackageInstallModal;
