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

const RepositoriesTab = ({ details }) => {
  const [filterText, setFilterText] = useState('');

  const {
    gpg_key_repos: gpgKeyRepos = [],
    ssl_ca_root_repos: sslCaRootRepos = [],
    ssl_client_root_repos: sslClientRootRepos = [],
    ssl_key_root_repos: sslKeyRootRepos = [],
  } = details;

  // Combine all repositories with their usage type
  const allRepositories = useMemo(() => [
    ...gpgKeyRepos.map(repo => ({ ...repo, used_as: __('GPG Key') })),
    ...sslCaRootRepos.map(repo => ({ ...repo, used_as: __('SSL CA Certificate') })),
    ...sslClientRootRepos.map(repo => ({ ...repo, used_as: __('SSL Client Certificate') })),
    ...sslKeyRootRepos.map(repo => ({ ...repo, used_as: __('SSL Client Key') })),
  ], [gpgKeyRepos, sslCaRootRepos, sslClientRootRepos, sslKeyRootRepos]);

  // Filter repositories based on search text
  const filteredRepositories = useMemo(() => {
    if (!filterText.trim()) {
      return allRepositories;
    }

    const searchTerm = filterText.toLowerCase();
    return allRepositories.filter(repo =>
      repo.name?.toLowerCase().includes(searchTerm) ||
      repo.product?.name?.toLowerCase().includes(searchTerm) ||
      repo.content_type?.toLowerCase().includes(searchTerm) ||
      repo.used_as?.toLowerCase().includes(searchTerm));
  }, [allRepositories, filterText]);

  if (allRepositories.length === 0) {
    return (
      <Card ouiaId="repositories-empty-state-card">
        <CardBody>
          <EmptyStateMessage
            title={__('No repositories using this credential')}
            body={__('This content credential is not currently being used by any repositories.')}
          />
        </CardBody>
      </Card>
    );
  }

  return (
    <>
      <Toolbar ouiaId="repositories-filter-toolbar">
        <ToolbarContent>
          <ToolbarItem>
            <TextInput
              type="text"
              placeholder={__('Filter...')}
              value={filterText}
              onChange={(_event, value) => setFilterText(value)}
              ouiaId="repositories-filter-input"
              aria-label={__('Filter repositories')}
            />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      {filteredRepositories.length === 0 && filterText.trim() ? (
        <Card ouiaId="repositories-no-results-card">
          <CardBody>
            <EmptyStateMessage
              title={__('No matching repositories')}
              body={__('No repositories match your filter criteria.')}
            />
          </CardBody>
        </Card>
      ) : (
        <Table aria-label={__('Repositories table')} variant="compact" ouiaId="content-credential-repositories-table">
          <Thead>
            <Tr>
              <Th>{__('Name')}</Th>
              <Th>{__('Product')}</Th>
              <Th>{__('Type')}</Th>
              <Th>{__('Used as')}</Th>
            </Tr>
          </Thead>
          <Tbody>
            {filteredRepositories.map(repo => (
              <Tr key={`${repo.id}-${repo.used_as}`}>
                <Td>
                  {repo.product?.id ? (
                    <a href={`/products/${repo.product.id}/repositories/${repo.library_instance_id}`}>
                      {repo.name}
                    </a>
                  ) : (
                    repo.name
                  )}
                </Td>
                <Td>
                  {repo.product?.id ? (
                    <a href={`/products/${repo.product.id}`}>
                      {repo.product.name}
                    </a>
                  ) : (repo.product?.name || '-')}
                </Td>
                <Td>{repo.content_type || '-'}</Td>
                <Td>{repo.used_as}</Td>
              </Tr>
            ))}
          </Tbody>
        </Table>
      )}
    </>
  );
};

RepositoriesTab.propTypes = {
  details: PropTypes.shape({
    gpg_key_repos: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      content_type: PropTypes.string,
      library_instance_id: PropTypes.number,
      product: PropTypes.shape({
        id: PropTypes.number,
        name: PropTypes.string,
      }),
    })),
    ssl_ca_root_repos: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      content_type: PropTypes.string,
      library_instance_id: PropTypes.number,
      product: PropTypes.shape({
        id: PropTypes.number,
        name: PropTypes.string,
      }),
    })),
    ssl_client_root_repos: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      content_type: PropTypes.string,
      library_instance_id: PropTypes.number,
      product: PropTypes.shape({
        id: PropTypes.number,
        name: PropTypes.string,
      }),
    })),
    ssl_key_root_repos: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      content_type: PropTypes.string,
      library_instance_id: PropTypes.number,
      product: PropTypes.shape({
        id: PropTypes.number,
        name: PropTypes.string,
      }),
    })),
  }).isRequired,
};

export default RepositoriesTab;
