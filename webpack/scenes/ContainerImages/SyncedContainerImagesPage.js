import React from 'react';
import { Table, Thead, Th, Tbody, Tr, Td } from '@patternfly/react-table';
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
import EmptyPage from 'foremanReact/routes/common/EmptyPage';
import { translate as __ } from 'foremanReact/common/I18n';
import { capitalize } from '../../utils/helpers';
import './SyncedContainerImagesPage.scss';

const SYNCED_CONTAINER_IMAGES_KEY = 'SYNCED_CONTAINER_IMAGES';
const SYNCED_CONTAINER_IMAGES_API_PATH = '/katello/api/v2/docker_tags';

const SyncedContainerImagesPage = () => {
  const getManifestType = (tag) => {
    const manifest = tag.manifest || tag.manifest_schema1 || tag.manifest_schema2;
    if (!manifest || !manifest.manifest_type) return 'N/A';

    return capitalize(manifest.manifest_type);
  };

  const getDigest = (tag) => {
    const manifest = tag.manifest || tag.manifest_schema1 || tag.manifest_schema2;
    if (!manifest || !manifest.digest) return 'N/A';
    return manifest.digest.replace('sha256:', '').substring(0, 12);
  };

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
    labels: {
      title: __('Labels | Annotations'),
      wrapper: () => <span>{__('View here')}</span>,
    },
  };

  const {
    searchParam: urlSearchQuery = '',
    page: urlPage,
    per_page: urlPerPage,
  } = useUrlParams();
  const defaultParams = { search: urlSearchQuery, grouped: true };
  if (urlPage) defaultParams.page = Number(urlPage);
  if (urlPerPage) defaultParams.per_page = Number(urlPerPage);
  const apiOptions = { key: SYNCED_CONTAINER_IMAGES_KEY };

  const response = useTableIndexAPIResponse({
    apiUrl: SYNCED_CONTAINER_IMAGES_API_PATH,
    apiOptions,
    defaultParams,
  });

  const columnsToSortParams = {};
  Object.keys(columns).forEach((key) => {
    if (columns[key].isSorted) {
      columnsToSortParams[columns[key].title] = key;
    }
  });

  const { setParamsAndAPI, params } = useSetParamsAndApiAndSearch({
    defaultParams,
    apiOptions,
    setAPIOptions: response.setAPIOptions,
  });

  const onSort = (_event, index, direction) => {
    setParamsAndAPI({
      ...params,
      order: `${Object.keys(columns)[index]} ${direction}`,
    });
  };

  const { pfSortParams } = useTableSort({
    allColumns: Object.keys(columns).map(k => columns[k].title),
    columnsToSortParams,
    onSort,
  });

  const expandedTags = useSet([]);
  const tagIsExpanded = tagId => expandedTags.has(tagId);

  const STATUS = {
    PENDING: 'PENDING',
    RESOLVED: 'RESOLVED',
    ERROR: 'ERROR',
  };

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
    setParamsAndAPI({ ...params, ...newPagination });
  };

  return (
    <TableIndexPage
      apiUrl={SYNCED_CONTAINER_IMAGES_API_PATH}
      apiOptions={apiOptions}
      creatable={false}
      isDeleteable={false}
      controller="docker_tags"
      customSearchProps={{
        autocomplete: {
          url: `${SYNCED_CONTAINER_IMAGES_API_PATH}/auto_complete_search`,
          searchQuery: 'grouped=true',
        },
      }}
    >
      <>
        <Table variant="compact" ouiaId="synced-container-images-table">
          <Thead>
            <Tr ouiaId="table-header">
              <>
                <Th />
                {columnNamesKeys.map(k => (
                  <Th
                    key={k}
                    sort={
                      Object.values(columnsToSortParams).includes(k) &&
                      pfSortParams(keysToColumnNames[k])
                    }
                  >
                    {keysToColumnNames[k]}
                  </Th>
                ))}
              </>
            </Tr>
          </Thead>
          {(results.length === 0 || errorMessage) && (
            <Tbody>
              {status === STATUS.PENDING && results.length === 0 && (
                <Tr ouiaId="table-loading">
                  <Td colSpan={100}>
                    <EmptyPage
                      message={{
                        type: 'loading',
                        text: __('Loading...'),
                      }}
                    />
                  </Td>
                </Tr>
              )}
              {!(status === STATUS.PENDING) &&
                results.length === 0 &&
                !errorMessage && (
                  <Tr ouiaId="table-empty">
                    <Td colSpan={100}>
                      <EmptyPage
                        message={{
                          type: 'empty',
                        }}
                      />
                    </Td>
                  </Tr>
              )}
              {errorMessage && (
                <Tr ouiaId="table-error">
                  <Td colSpan={100}>
                    <EmptyPage message={{ type: 'error', text: errorMessage }} />
                  </Td>
                </Tr>
              )}
            </Tbody>
          )}
          {results?.map((tag, rowIndex) => {
            const { id, manifest } = tag;
            const isExpanded = tagIsExpanded(id);
            const hasChildManifests = manifest?.manifest_type === 'list' && manifest?.manifests?.length > 0;
            return (
              <Tbody key={`synced-container-images-body-${id}`} isExpanded={isExpanded}>
                <Tr key={id} ouiaId={`table-row-${rowIndex}`}>
                  <>
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
                  </>
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
                        {childManifest.digest?.replace('sha256:', '').substring(0, 12) || 'N/A'}
                      </Td>
                      <Td dataLabel={__('Type')}>
                        {capitalize(childManifest.manifest_type) || 'N/A'}
                      </Td>
                      <Td dataLabel={__('Labels | Annotations')}>
                        N/A
                      </Td>
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
            perPage={params.perPage}
            itemCount={subtotal}
            onChange={onPagination}
            updateParamsByUrl
          />
        }
      </>
    </TableIndexPage>
  );
};

export default SyncedContainerImagesPage;
