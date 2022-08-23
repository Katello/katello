import React, { useState, useCallback } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal, ModalVariant,
} from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import TableWrapper from '../../../../../components/Table/TableWrapper';
import { getRPMPackages } from '../../ContentViewDetailActions';
import { selectRPMPackages, selectRPMPackagesStatus } from '../../ContentViewDetailSelectors';


const columnHeaders = [
  __('RPM name'),
  __('Summary'),
];

const emptyContentTitle = __('No matching RPM found.');
const emptyContentBody = __("Given criteria doesn't match any RPMs. Try changing your rule.");
const emptySearchTitle = __('Your search returned no matching RPMs.');
const emptySearchBody = __('Try changing your search criteria.');

const CVRpmMatchContentModal = ({ filterId, onClose, filterRuleId }) => {
  const [searchQuery, updateSearchQuery] = useState('');
  const response = useSelector(state => selectRPMPackages(state), shallowEqual);
  const status = useSelector(state => selectRPMPackagesStatus(state), shallowEqual);

  const fetchItems = useCallback(params => getRPMPackages({
    content_view_filter_rule_id: filterRuleId, filterId, ...params,
  }), [filterRuleId, filterId]);

  const { results, ...metadata } = response;

  return (
    <Modal
      title={__('Matching content')}
      ouiaId="rpm-matching-content"
      variant={ModalVariant.medium}
      isOpen
      onClose={onClose}
      appendTo={document.body}
    >
      <TableWrapper
        {...{
          metadata,
          emptyContentTitle,
          emptyContentBody,
          emptySearchTitle,
          emptySearchBody,
          searchQuery,
          updateSearchQuery,
          fetchItems,
          status,
        }}
        ouiaId="content-view-rpm-match-content-table"
        autocompleteEndpoint="/packages/auto_complete_search"
        variant={TableVariant.compact}
      >
        <Thead>
          <Tr ouiaId="column-headers">
            {columnHeaders.map(col =>
              <Th key={col}>{col}</Th>)}
          </Tr>
        </Thead>
        <Tbody>
          {results?.map((result) => {
            const {
              nvra, summary = '-', id,
            } = result;
            return (
              <Tr key={`${nvra}_${summary}_${id}`} ouiaId={`${nvra}_${summary}_${id}`}>
                <Td>
                  <a rel="noreferrer" target="_blank" href={urlBuilder(`packages/${id}`, '')}>{nvra}</a>
                </Td>
                <Td>{summary}</Td>
              </Tr>
            );
          })
          }
        </Tbody>
      </TableWrapper>
    </Modal>
  );
};

CVRpmMatchContentModal.propTypes = {
  filterRuleId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func,
};

CVRpmMatchContentModal.defaultProps = {
  onClose: undefined,
};

export default CVRpmMatchContentModal;
