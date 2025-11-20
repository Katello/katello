import React, { useState, useMemo, useCallback } from 'react';
import PropTypes from 'prop-types';
import { ClipboardCopy, Label, Icon, Flex } from '@patternfly/react-core';
import { CubeIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import './ManifestRepositoriesTable.scss';

const ManifestRepositoriesTable = ({ repositories, tagName }) => {
  const [sortOrder, setSortOrder] = useState(null);

  const getLibraryRepositoryId = (repo) => {
    if (repo.library_instance) return repo.id;
    // Find the library instance with the same product
    const libraryRepo = repositories.find(r => (
      r.library_instance && r.product_id === repo.product_id
    ));
    return libraryRepo?.id || null;
  };

  const sortedRepositories = useMemo(() => {
    if (!sortOrder || !repositories) return repositories;

    const sortValueGetters = {
      kt_environment: repo => repo.kt_environment?.name || '',
      content_view_version: repo => repo.content_view_version?.name || '',
      name: repo => repo.name || '',
      full_path: repo => repo.full_path || '',
    };

    const [sortColumn, sortDirection] = sortOrder.split(' ');
    const getSortValue = sortValueGetters[sortColumn];
    if (!getSortValue) return repositories;

    return [...repositories].sort((repoA, repoB) => {
      const valueA = getSortValue(repoA);
      const valueB = getSortValue(repoB);
      const comparisonResult = valueA.localeCompare(valueB, undefined, { numeric: true, sensitivity: 'base' });
      return sortDirection === 'asc' ? comparisonResult : -comparisonResult;
    });
  }, [repositories, sortOrder]);

  const setAPIOptions = useCallback((options) => {
    if (options?.params?.order) {
      setSortOrder(options.params.order);
    }
  }, []);

  const repositoriesResponse = useMemo(() => ({
    response: {
      results: sortedRepositories || [],
      total: 0,
      subtotal: sortedRepositories?.length || 0,
      search: null,
      can_create: false,
    },
    status: STATUS.RESOLVED,
    setAPIOptions,
  }), [sortedRepositories, setAPIOptions]);

  const columns = {
    kt_environment: {
      title: __('Environment'),
      wrapper: ({ kt_environment: env }) => (
        env ? (
          <Label color="purple" href={`/lifecycle_environments/${env.id}`}>
            {env.name}
          </Label>
        ) : 'N/A'
      ),
      isSorted: true,
    },
    content_view_version: {
      title: __('Content view'),
      wrapper: ({ content_view_version: cvv }) => (
        cvv ? (
          <Flex alignItems={{ default: 'alignItemsCenter' }} spaceItems={{ default: 'spaceItemsSm' }} flexWrap={{ default: 'nowrap' }}>
            <Icon size="md">
              <CubeIcon />
            </Icon>
            <span>{cvv.name}</span>
          </Flex>
        ) : 'N/A'
      ),
      isSorted: true,
    },
    name: {
      title: __('Repository'),
      wrapper: (repo) => {
        const { name, product_id: productId } = repo;
        const libraryRepoId = getLibraryRepositoryId(repo);

        return libraryRepoId ? (
          <a href={`/products/${productId}/repositories/${libraryRepoId}`}>
            {name}
          </a>
        ) : (
          <span>{name}</span>
        );
      },
      isSorted: true,
    },
    full_path: {
      title: __('Pullable path'),
      wrapper: ({ full_path: fullPath }) => (
        <ClipboardCopy variant="inline-compact" clickTip="Copied">
          {`${fullPath}:${tagName}`}
        </ClipboardCopy>
      ),
      isSorted: true,
    },
  };

  return (
    <div className="manifest-repositories-table-wrapper">
      <TableIndexPage
        apiUrl="/katello/api/v2/docker_tags"
        apiOptions={{ key: 'MANIFEST_REPOSITORIES' }}
        controller="docker_tags"
        columns={columns}
        replacementResponse={repositoriesResponse}
        creatable={false}
        searchable={false}
        exportable={false}
        hasHelpPage={false}
        updateParamsByUrl={false}
        ouiaId="manifest-repositories-table"
      />
    </div>
  );
};

ManifestRepositoriesTable.propTypes = {
  repositories: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    full_path: PropTypes.string,
    library_instance: PropTypes.bool,
    product_id: PropTypes.number,
    kt_environment: PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    }),
    content_view_version: PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      content_view_id: PropTypes.number,
    }),
  })),
  tagName: PropTypes.string.isRequired,
};

ManifestRepositoriesTable.defaultProps = {
  repositories: [],
};

export default ManifestRepositoriesTable;
