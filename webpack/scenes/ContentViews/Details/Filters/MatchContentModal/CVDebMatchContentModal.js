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
import { getDebPackages } from '../../ContentViewDetailActions';
import { selectDebPackages, selectDebPackagesStatus } from '../../ContentViewDetailSelectors';


const columnHeaders = [
  __('DEB name'),
  __('Summary'),
];

const emptyContentTitle = __('No matching DEB found.');
const emptyContentBody = __("Given criteria doesn't match any DEBs. Try changing your rule.");
const emptySearchTitle = __('Your search returned no matching DEBs.');
const emptySearchBody = __('Try changing your search criteria.');

const CVDebMatchContentModal = ({ filterId, onClose, filterRuleId }) => {
  const [searchQuery, updateSearchQuery] = useState('');
  const response = useSelector(state => selectDebPackages(state), shallowEqual);
  const status = useSelector(state => selectDebPackagesStatus(state), shallowEqual);

  const fetchItems = useCallback(params => getDebPackages({
    content_view_filter_rule_id: filterRuleId, filterId, ...params,
  }), [filterRuleId, filterId]);

  const { results, ...metadata } = response;

  return (
    <Modal
      title={__('Matching content')}
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
        ouiaId="content-view-deb-match-content-table"
        autocompleteEndpoint="/debs/auto_complete_search"
        variant={TableVariant.compact}
      >
        <Thead>
          <Tr>
            {columnHeaders.map(col =>
              <Th key={col}>{col}</Th>)}
          </Tr>
        </Thead>
        <Tbody>
          {results?.map((result) => {
            const {
              nva, description = '-', id,
            } = result;
            return (
              <Tr key={`${nva}_${description}_${id}`}>
                <Td>
                  <a rel="noreferrer" target="_blank" href={urlBuilder(`debs/${id}`, '')}>{nva}</a>
                </Td>
                <Td>{description}</Td>
              </Tr>
            );
          })
          }
        </Tbody>
      </TableWrapper>
    </Modal>
  );
};

CVDebMatchContentModal.propTypes = {
  filterRuleId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func,
};

CVDebMatchContentModal.defaultProps = {
  onClose: undefined,
};

export default CVDebMatchContentModal;
