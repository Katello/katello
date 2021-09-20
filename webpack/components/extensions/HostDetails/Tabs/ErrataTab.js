import React, { useCallback, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { Button, Hint, HintBody, Split, SplitItem, ActionList, ActionListItem, Dropdown,
  DropdownItem, KebabToggle } from '@patternfly/react-core';
import {
  TableVariant,
  TableText,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
  ExpandableRowContent,
} from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectAPIResponse } from 'foremanReact/redux/API/APISelectors';

import IsoDate from 'foremanReact/components/common/dates/IsoDate';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import TableWrapper from '../../../../components/Table/TableWrapper';
import useSet from '../../../../components/Table/TableHooks';
import { ErrataType, ErrataSeverity } from '../../../../components/Errata';
import { getInstallableErrata, regenerateApplicability } from '../HostErrata/HostErrataActions';
import ErratumExpansionDetail from './ErratumExpansionDetail';
import ErratumExpansionContents from './ErratumExpansionContents';
import { selectHostErrataStatus } from '../HostErrata/HostErrataSelectors';
import { HOST_ERRATA_KEY } from '../HostErrata/HostErrataConstants';
import './ErrataTab.scss';

export const ErrataTab = () => {
  const hostDetails = useSelector(state => selectAPIResponse(state, 'HOST_DETAILS'));
  const { id: hostId } = hostDetails;
  const dispatch = useDispatch();

  const [searchQuery, updateSearchQuery] = useState('');
  const [isBulkActionOpen, setIsBulkActionOpen] = useState(false);
  const toggleBulkAction = () => setIsBulkActionOpen(prev => !prev);
  const expandedErrata = useSet([]);
  const erratumIsExpanded = id => expandedErrata.has(id);

  const emptyContentTitle = __('This host does not have any installable errata.');
  const emptyContentBody = __('Installable errata will appear here when available.');
  const emptySearchTitle = __('No matching installable errata found');
  const emptySearchBody = __('Try changing your search settings.');
  const columnHeaders = [
    __('Errata'),
    __('Type'),
    __('Severity'),
    __('Synopsis'),
    __('Published Date'),
  ];

  const fetchItems = useCallback(
    params => getInstallableErrata(hostId, params),
    [hostId],
  );

  const response = useSelector(state => selectAPIResponse(state, HOST_ERRATA_KEY));
  const { results, ...metadata } = response;
  const status = useSelector(state => selectHostErrataStatus(state));
  const rowActions = [
    {
      title: __('Apply via Katello agent'), disabled: true,
    },
    {
      title: __('Apply via remote execution'), disabled: true,
    },
    {
      title: __('Apply via customized remote execution'), disabled: true,
    },
  ];

  const recalculateErrata = () => {
    setIsBulkActionOpen(false);
    dispatch(regenerateApplicability(hostId));
  };

  const dropdownItems = [
    <DropdownItem aria-label="bulk_add" key="bulk_add" component="button" onClick={recalculateErrata}>
      {__('Recalculate')}
    </DropdownItem>,
  ];

  const actionButtons = (
    <Split hasGutter>
      <SplitItem>
        <ActionList isIconList>
          <ActionListItem>
            <Button isDisabled> {__('Apply')} </Button>
          </ActionListItem>
          <ActionListItem>
            <Dropdown
              toggle={<KebabToggle aria-label="bulk_actions" onToggle={toggleBulkAction} />}
              isOpen={isBulkActionOpen}
              isPlain
              dropdownItems={dropdownItems}
            />
          </ActionListItem>
        </ActionList>
      </SplitItem>
    </Split>
  );

  return (
    <div>
      <div id="errata-hint">
        <Hint>
          <HintBody>
            {__('Errata management functionality on this page is incomplete')}.
            <br />
            <Button component="a" variant="link" isInline href={urlBuilder(`content_hosts/${hostId}/errata`, '')}>
              {__('Visit the previous Errata page')}.
            </Button>
          </HintBody>
        </Hint>
      </div>
      <div id="errata-tab">
        <TableWrapper
          {...{
                metadata,
                emptyContentTitle,
                emptyContentBody,
                emptySearchTitle,
                emptySearchBody,
                status,
                actionButtons,
                searchQuery,
                updateSearchQuery,
                }}
          additionalListeners={[hostId]}
          fetchItems={fetchItems}
          autocompleteEndpoint={`/hosts/${hostId}/errata/auto_complete_search`}
          foremanApiAutoComplete
          variant={TableVariant.compact}
        >
          <Thead>
            <Tr>
              <Th key="expand-carat" />
              {columnHeaders.map(col =>
                <Th key={col}>{col}</Th>)}
              <Th />
            </Tr>
          </Thead>
          <>
            {results?.map((erratum, rowIndex) => {
                const {
                  id,
                  errata_id: errataId,
                  created_at: createdAt,
                  updated: publishedAt,
                  title,
                } = erratum;
                const isExpanded = erratumIsExpanded(id);
                return (
                  <Tbody isExpanded={isExpanded} key={`${id}_${createdAt}`}>
                    <Tr>
                      <Td
                        expand={{
                          rowIndex,
                          isExpanded,
                          onToggle: (_event, rInx, isOpen) => {
                            if (isOpen) {
                              expandedErrata.add(id);
                            } else {
                              expandedErrata.delete(id);
                            }
                          },
                      }}
                      />
                      <Td>
                        <a href={urlBuilder(`errata/${id}`, '')}>{errataId}</a>
                      </Td>
                      <Td><ErrataType {...erratum} /></Td>
                      <Td><ErrataSeverity {...erratum} /></Td>
                      <Td><TableText wrapModifier="truncate">{title}</TableText></Td>
                      <Td key={publishedAt}><IsoDate date={publishedAt} /></Td>
                      <Td
                        key={`rowActions-${id}`}
                        actions={{
                            items: rowActions,
                          }}
                      />
                    </Tr>
                    <Tr key="child_row" isExpanded={isExpanded}>
                      <Td colSpan={3}>
                        <ExpandableRowContent>
                          <ErratumExpansionContents erratum={erratum} />
                        </ExpandableRowContent>
                      </Td>
                      <Td colSpan={4}>
                        <ExpandableRowContent>
                          <ErratumExpansionDetail erratum={erratum} />
                        </ExpandableRowContent>
                      </Td>
                    </Tr>
                  </Tbody>
                );
              })
              }
          </>
        </TableWrapper>
      </div>
    </div>
  );
};

export default ErrataTab;
