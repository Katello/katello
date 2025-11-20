import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Table, Thead, Th, Tbody, Tr, Td, ActionsColumn } from '@patternfly/react-table';
import { Button } from '@patternfly/react-core';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import {
  useSetParamsAndApiAndSearch,
  useTableIndexAPIResponse,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import {
  useUrlParams,
  useSet,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import {
  getColumnHelpers,
} from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import {
  useTableSort,
} from 'foremanReact/components/PF4/Helpers/useTableSort';
import Pagination from 'foremanReact/components/Pagination';
import { translate as __ } from 'foremanReact/common/I18n';
import { orgId } from '../../../services/api';
import {
  formatManifestType,
  getManifest,
  hasLabelsOrAnnotations,
  anyChildHasLabelsOrAnnotations,
  STATUS,
} from '../containerImagesHelpers';
import LabelsAnnotationsModal from '../LabelsAnnotationsModal';
import PullablePathsModal from './PullablePathsModal';
import TableEmptyState from '../TableEmptyState';
import './SyncedContainerImagesPage.scss';

const SYNCED_CONTAINER_IMAGES_KEY = 'SYNCED_CONTAINER_IMAGES';
const SYNCED_CONTAINER_IMAGES_API_PATH = '/katello/api/v2/docker_tags';

const SyncedContainerImagesPage = () => {
  const [showLabelsModal, setShowLabelsModal] = useState(false);
  const [selectedManifest, setSelectedManifest] = useState(null);
  const [showPullablePathsModal, setShowPullablePathsModal] = useState(false);
  const [selectedTag, setSelectedTag] = useState(null);

  const getManifestType = (tag) => {
    const manifest = getManifest(tag);
    return formatManifestType(manifest);
  };

  const getDigest = (tag) => {
    const manifest = getManifest(tag);
    if (!manifest || !manifest.digest) return 'N/A';
    return (
      <Link to={`/labs/container_images/${tag.id}`}>
        {manifest.digest}
      </Link>
    );
  };

  const getProductLink = (tag) => {
    if (!tag.product) return 'N/A';

    const productId = tag.product.id;
    const productName = tag.product.name;

    return (
      <a href={`/products/${productId}`} target="_blank" rel="noopener noreferrer">
        {productName}
      </a>
    );
  };

  const openLabelsModal = (manifest) => {
    setSelectedManifest(manifest);
    setShowLabelsModal(true);
  };

  const openPullablePathsModal = (tag) => {
    setSelectedTag(tag);
    setShowPullablePathsModal(true);
  };

  const expandedTags = useSet([]);
  const tagIsExpanded = tagId => expandedTags.has(tagId);

  const columns = {
    name: {
      title: __('Tag'),
      isSorted: true,
    },
    digest: {
      title: __('Manifest digest'),
      wrapper: tag => getDigest(tag),
    },
    type: {
      title: __('Type'),
      wrapper: tag => getManifestType(tag),
    },
    product: {
      title: __('Product'),
      wrapper: tag => getProductLink(tag),
    },
    labels: {
      title: __('Labels | Annotations'),
      wrapper: (tag) => {
        const manifest = getManifest(tag);
        if (hasLabelsOrAnnotations(manifest)) {
          return (
            <Button
              variant="link"
              isInline
              onClick={() => openLabelsModal(manifest)}
              ouiaId="view-labels-annotations-button"
              aria-label={__('View labels and annotations')}
            >
              {__('View here')}
            </Button>
          );
        }
        if (anyChildHasLabelsOrAnnotations(manifest)) {
          const isExpanded = tagIsExpanded(tag.id);
          return (
            <Button
              variant="link"
              isInline
              onClick={() => expandedTags.onToggle(!isExpanded, tag.id)}
              ouiaId="see-child-manifests-button"
            >
              {__('See child manifests')}
            </Button>
          );
        }
        return <span>{__('N/A')}</span>;
      },
      width: 15,
    },
  };

  const {
    searchParam: currentSearchQuery = '',
    page: urlPage,
    per_page: urlPerPage,
  } = useUrlParams();

  // Persistent params that must always be included
  const persistentParams = {
    grouped: true,
    organization_id: orgId(),
  };

  const defaultParams = {
    search: currentSearchQuery,
    page: urlPage ? Number(urlPage) : 1,
    per_page: urlPerPage ? Number(urlPerPage) : 20,
    ...persistentParams,
  };
  const apiOptions = {
    key: SYNCED_CONTAINER_IMAGES_KEY,
  };

  const originalResponse = useTableIndexAPIResponse({
    apiUrl: SYNCED_CONTAINER_IMAGES_API_PATH,
    apiOptions,
    defaultParams,
  });

  // Wrap setAPIOptions to ensure persistent params are always included
  // This is necessary because TableIndexPage may call setAPIOptions directly
  // for operations like search, and those calls need to preserve persistent params
  const wrappedSetAPIOptions = (options) => {
    const mergedOptions = {
      ...options,
      params: {
        ...persistentParams,
        ...options.params,
      },
    };
    originalResponse.setAPIOptions(mergedOptions);
  };

  const response = {
    ...originalResponse,
    setAPIOptions: wrappedSetAPIOptions,
  };

  const columnsToSortParams = {};
  Object.keys(columns).forEach((key) => {
    if (columns[key].isSorted) {
      columnsToSortParams[columns[key].title] = key;
    }
  });

  const { setParamsAndAPI, params } = useSetParamsAndApiAndSearch({
    defaultParams,
    apiOptions,
    setAPIOptions: wrappedSetAPIOptions,
  });

  const onSort = (_event, index, direction) => {
    setParamsAndAPI({
      ...params,
      page: urlPage ? Number(urlPage) : params.page,
      per_page: urlPerPage ? Number(urlPerPage) : params.per_page,
      search: currentSearchQuery,
      order: `${Object.keys(columns)[index]} ${direction}`,
    });
  };

  const { pfSortParams } = useTableSort({
    allColumns: Object.keys(columns).map(k => columns[k].title),
    columnsToSortParams,
    onSort,
  });

  const {
    response: {
      results = [],
      subtotal,
      message: errorMessage,
    },
    status = STATUS.PENDING,
  } = response;

  const [columnNamesKeys, keysToColumnNames] = getColumnHelpers(columns);
  const onPagination = (newPagination) => {
    setParamsAndAPI({
      ...params,
      search: currentSearchQuery,
      ...newPagination,
    });
  };

  return (
    <TableIndexPage
      apiUrl={SYNCED_CONTAINER_IMAGES_API_PATH}
      apiOptions={apiOptions}
      replacementResponse={response}
      creatable={false}
      isDeleteable={false}
      customSearchProps={{
        autocomplete: {
          url: `${SYNCED_CONTAINER_IMAGES_API_PATH}/auto_complete_search`,
          apiParams: { organization_id: orgId() },
        },
        controller: 'katello_docker_tags',
        bookmarks: {
          url: '/api/bookmarks',
          canCreate: true,
        },
      }}
      ouiaId="synced-container-images-table-index"
    >
      <>
        <Table variant="compact" ouiaId="synced-container-images-table">
          <Thead>
            <Tr ouiaId="table-header">
              <Th />
              {columnNamesKeys.map(k => (
                <Th
                  key={k}
                  width={columns[k].width}
                  sort={
                    Object.values(columnsToSortParams).includes(k) &&
                    pfSortParams(keysToColumnNames[k])
                  }
                >
                  {keysToColumnNames[k]}
                </Th>
              ))}
            </Tr>
          </Thead>
          <TableEmptyState
            status={status}
            results={results}
            errorMessage={errorMessage}
          />
          {results?.map((tag, rowIndex) => {
            const { id, manifest } = tag;
            const isExpanded = tagIsExpanded(id);
            const hasChildManifests = manifest?.manifest_type === 'list' && manifest?.manifests?.length > 0;
            return (
              <Tbody key={`synced-container-images-body-${id}`} isExpanded={isExpanded}>
                <Tr key={id} ouiaId={`table-row-${rowIndex}`}>
                  <Td
                    expand={hasChildManifests && {
                      rowIndex,
                      isExpanded,
                      onToggle: (_event, _rInx, isOpen) =>
                        expandedTags.onToggle(isOpen, id),
                      expandId: `synced-containers-expander-${id}`,
                    }}
                  />
                  {columnNamesKeys.map(k => (
                    <Td
                      key={`${id}-${keysToColumnNames[k]}`}
                      dataLabel={keysToColumnNames[k]}
                    >
                      {columns[k].wrapper ? columns[k].wrapper(tag) : tag[k]}
                    </Td>
                  ))}
                  <Td isActionCell>
                    <ActionsColumn
                      items={[
                        {
                          title: __('View pullable paths'),
                          onClick: () => openPullablePathsModal(tag),
                        },
                      ]}
                    />
                  </Td>
                </Tr>
                {hasChildManifests && manifest.manifests.map((childManifest, childIndex) => {
                  const isLastChild = childIndex === manifest.manifests.length - 1;
                  return (
                    <Tr
                      key={childManifest.id || childIndex}
                      isExpanded={isExpanded}
                      ouiaId={`table-row-expandable-${rowIndex}-${childIndex}`}
                      className={`child-manifest-row ${isLastChild ? 'last-child' : ''}`}
                    >
                      <Td className="empty-cell" />
                      <Td className="empty-cell" />
                      <Td dataLabel={__('Manifest digest')}>
                        {childManifest.digest ? (
                          <Link to={`/labs/container_images/${tag.id}?manifest=${childManifest.id}`}>
                            {childManifest.digest}
                          </Link>
                        ) : 'N/A'}
                      </Td>
                      <Td dataLabel={__('Type')}>
                        {formatManifestType(childManifest)}
                      </Td>
                      <Td dataLabel={__('Product')} className="empty-cell" />
                      <Td dataLabel={__('Labels | Annotations')}>
                        {hasLabelsOrAnnotations(childManifest) ? (
                          <Button
                            variant="link"
                            isInline
                            onClick={() => openLabelsModal(childManifest)}
                            ouiaId="view-child-labels-annotations-button"
                            aria-label={__('View labels and annotations')}
                          >
                            {__('View here')}
                          </Button>
                        ) : (
                          <span>N/A</span>
                        )}
                      </Td>
                      <Td className="empty-cell" />
                    </Tr>
                  );
                })}
              </Tbody>
            );
          })}
        </Table>
        {results.length > 0 && !errorMessage &&
          <Pagination
            key="table-bottom-pagination"
            page={params.page}
            perPage={params.per_page}
            itemCount={subtotal}
            onChange={onPagination}
            updateParamsByUrl
          />
        }
        <LabelsAnnotationsModal
          show={showLabelsModal}
          setIsOpen={setShowLabelsModal}
          digest={selectedManifest?.digest || ''}
          labels={selectedManifest?.labels || {}}
          annotations={selectedManifest?.annotations || {}}
        />
        <PullablePathsModal
          show={showPullablePathsModal}
          setIsOpen={setShowPullablePathsModal}
          repositories={selectedTag?.repositories || []}
          tagName={selectedTag?.name || ''}
        />
      </>
    </TableIndexPage>
  );
};

export default SyncedContainerImagesPage;
