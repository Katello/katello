import React from 'react';
import { TableComposable, Thead, Th, Tbody, Tr, Td, ExpandableRowContent } from '@patternfly/react-table';
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
import BOOTED_CONTAINER_IMAGES_KEY, { BOOTED_CONTAINER_IMAGES_API_PATH } from './BootedContainerImagesConstants';

const BootedContainerImagesPage = () => {
  const columns = {
    bootc_booted_image: {
      title: __('Image name'),
      isSorted: true,
    },
    digest: {
      title: __('Image digests'),
      wrapper: ({digests}) => digests.length,
    },
    hosts: {
      title: __('Hosts'),
      wrapper: ({bootc_booted_image, digests}) => (
        <a href={`/hosts?search=bootc_booted_image%20=%20${bootc_booted_image}`}>{digests.reduce((total, digest) => total + digest.host_count, 0)}</a>
      ),
    },
  };

  const {
    searchParam: urlSearchQuery = '',
    page: urlPage,
    per_page: urlPerPage,
  } = useUrlParams();
  const defaultParams = { search: urlSearchQuery };
  if (urlPage) defaultParams.page = Number(urlPage);
  if (urlPerPage) defaultParams.per_page = Number(urlPerPage);
  const apiOptions = { key: BOOTED_CONTAINER_IMAGES_KEY };

  const response = useTableIndexAPIResponse({
    apiUrl: BOOTED_CONTAINER_IMAGES_API_PATH,
    apiOptions,
    defaultParams,
  });
  const columnsToSortParams = {};
  Object.keys(columns).forEach(key => {
    if (columns[key].isSorted) {
      columnsToSortParams[columns[key].title] = key;
    }
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
  const expandedImages = useSet([]);
  const imageIsExpanded = bootc_booted_image => expandedImages.has(bootc_booted_image);
  const STATUS = {
    PENDING: 'PENDING',
    RESOLVED: 'RESOLVED',
    ERROR: 'ERROR',
  };

  const {
    response: {
      results = [],
      per_page: perPage,
      page,
      subtotal,
      message: errorMessage,
    },
    status = STATUS.PENDING,
    setAPIOptions,
  } = response;

  const { setParamsAndAPI, params } = useSetParamsAndApiAndSearch({
    defaultParams,
    apiOptions,
    setAPIOptions: response.setAPIOptions,
  });

  const [columnNamesKeys, keysToColumnNames] = getColumnHelpers(columns);
  const onPagination = newPagination => {
    setParamsAndAPI({ ...params, ...newPagination });
  };
  const bottomPagination = (
    <Pagination
      key="table-bottom-pagination"
      page={params.page}
      perPage={params.perPage}
      itemCount={subtotal}
      onChange={onPagination}
      updateParamsByUrl={true}
    />
  );

  return (
    <TableIndexPage
      apiUrl={BOOTED_CONTAINER_IMAGES_API_PATH}
      apiOptions={apiOptions}
      header={__('Booted container images')}
      createable={false}
      isDeleteable={false}
      controller="/katello/api/v2/host_bootc_images"
    >
      <>
        <TableComposable variant="compact" ouiaId="booted-containers-table" isStriped>
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
            {!status === STATUS.PENDING &&
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
          {results?.map((result, rowIndex) => {
            const { bootc_booted_image, digests } = result;
            const isExpanded = imageIsExpanded(bootc_booted_image);
            return (
              <Tbody key={`bootable-container-images-body-${rowIndex}`} isExpanded={isExpanded}>
                <Tr key={bootc_booted_image} ouiaId={`table-row-${rowIndex}`}>
                  <>
                    <Td
                      expand={digests.length > 0 && {
                        rowIndex,
                        isExpanded,
                        onToggle: (_event, _rInx, isOpen,) => expandedImages.onToggle(isOpen, bootc_booted_image),
                        expandId: 'booted-containers-expander'
                      }}
                    />
                    {columnNamesKeys.map(k => (
                      <Td
                        key={k}
                        dataLabel={keysToColumnNames[k]}
                      >
                        {columns[k].wrapper ? columns[k].wrapper(result) : result[k]}
                      </Td>
                    ))}
                  </>
                </Tr>
                {digests ? <Tr isExpanded={isExpanded}>
                  <Td colSpan={3}>
                    <ExpandableRowContent>
                      <TableComposable variant="compact" isStriped>
                        <Thead>
                          <Tr>
                            <Th>{__('Image digest')}</Th>
                            <Th>{__('Hosts')}</Th>
                          </Tr>
                        </Thead>
                        <Tbody>
                          {digests.map((digest, index) => (
                            <Tr key={index}>
                              <Td>{digest.bootc_booted_digest}</Td>
                              <Td>
                                <a href={`/hosts?search=bootc_booted_digest%20=%20${digest.bootc_booted_digest}`}>{digest.host_count}</a>
                              </Td>
                            </Tr>
                          ))}
                        </Tbody>
                      </TableComposable>
                    </ExpandableRowContent>
                  </Td>
                </Tr> : null}
              </Tbody>
            );
          })}
        </TableComposable>
        {results.length > 0 && !errorMessage && bottomPagination}
      </>
    </TableIndexPage>
  );
};

export default BootedContainerImagesPage;
