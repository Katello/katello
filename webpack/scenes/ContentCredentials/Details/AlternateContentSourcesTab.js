/* eslint-disable @theforeman/rules/require-ouiaid */
import React, { useState, useMemo } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Table, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import {
  Card,
  CardBody,
  TextInput,
  Toolbar,
  ToolbarContent,
  ToolbarItem,
} from '@patternfly/react-core';

import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';

const AlternateContentSourcesTab = ({ details }) => {
  const [filterText, setFilterText] = useState('');

  const {
    ssl_ca_alternate_content_sources: sslCaACS = [],
    ssl_client_alternate_content_sources: sslClientACS = [],
    ssl_key_alternate_content_sources: sslKeyACS = [],
  } = details;

  // Combine all alternate content sources with their usage type
  const allACS = useMemo(() => [
    ...sslCaACS.map(acs => ({ ...acs, used_as: __('SSL CA Certificate') })),
    ...sslClientACS.map(acs => ({ ...acs, used_as: __('SSL Client Certificate') })),
    ...sslKeyACS.map(acs => ({ ...acs, used_as: __('SSL Client Key') })),
  ], [sslCaACS, sslClientACS, sslKeyACS]);

  // Filter alternate content sources based on search text
  const filteredACS = useMemo(() => {
    if (!filterText.trim()) {
      return allACS;
    }

    const searchTerm = filterText.toLowerCase();
    return allACS.filter(acs =>
      acs.name?.toLowerCase().includes(searchTerm) ||
      acs.used_as?.toLowerCase().includes(searchTerm));
  }, [allACS, filterText]);

  if (allACS.length === 0) {
    return (
      <Card ouiaId="acs-empty-state-card">
        <CardBody>
          <EmptyStateMessage
            title={__('No alternate content sources using this credential')}
            body={__('This content credential is not currently being used by any alternate content sources.')}
          />
        </CardBody>
      </Card>
    );
  }

  return (
    <>
      <Toolbar ouiaId="acs-filter-toolbar">
        <ToolbarContent>
          <ToolbarItem>
            <TextInput
              type="text"
              placeholder={__('Filter...')}
              value={filterText}
              onChange={(_event, value) => setFilterText(value)}
              ouiaId="acs-filter-input"
              aria-label={__('Filter alternate content sources')}
            />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      {filteredACS.length === 0 && filterText.trim() ? (
        <Card ouiaId="acs-no-results-card">
          <CardBody>
            <EmptyStateMessage
              title={__('No matching alternate content sources')}
              body={__('No alternate content sources match your filter criteria.')}
            />
          </CardBody>
        </Card>
      ) : (
        <Table aria-label={__('Alternate content sources table')} variant="compact" ouiaId="content-credential-acs-table">
          <Thead>
            <Tr>
              <Th>{__('Name')}</Th>
              <Th>{__('Used as')}</Th>
            </Tr>
          </Thead>
          <Tbody>
            {filteredACS.map(acs => (
              <Tr key={`${acs.id}-${acs.used_as}`}>
                <Td>
                  <a href={`/alternate_content_sources/${acs.id}`}>
                    {acs.name}
                  </a>
                </Td>
                <Td>{acs.used_as}</Td>
              </Tr>
            ))}
          </Tbody>
        </Table>
      )}
    </>
  );
};

AlternateContentSourcesTab.propTypes = {
  details: PropTypes.shape({
    ssl_ca_alternate_content_sources: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    })),
    ssl_client_alternate_content_sources: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    })),
    ssl_key_alternate_content_sources: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    })),
  }).isRequired,
};

export default AlternateContentSourcesTab;
