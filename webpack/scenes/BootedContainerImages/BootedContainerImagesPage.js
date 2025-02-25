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
import { useForemanHostsPageUrl } from 'foremanReact/Root/Context/ForemanContext';
import BOOTED_CONTAINER_IMAGES_KEY, { BOOTED_CONTAINER_IMAGES_API_PATH } from './BootedContainerImagesConstants';

const BootedContainerImagesPage = () => {
  const foremanHostsPageUrl = useForemanHostsPageUrl();
  const columns = {
    bootc_booted_image: {
      title: __('Image name'),
      isSorted: true,
    },
    digest: {
      title: __('Image digests'),
      wrapper: ({ digests }) => digests.length,
    },
    hosts: {
      title: __('Hosts'),
      wrapper: ({ bootc_booted_image: bootcBootedImage, digests }) => (
        <a href={`${foremanHostsPageUrl}?search=bootc_booted_image%20=%20${bootcBootedImage}`}>{digests.reduce((total, digest) => total + digest.host_count, 0)}</a>
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
  const expandedImages = useSet([]);
  const imageIsExpanded = bootcBootedImage => expandedImages.has(bootcBootedImage);
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
  const getColumnWidth = (key) => {
    if (key === 'bootc_booted_image') return 40;
    if (key === 'digest') return 15;
    return 45;
  };

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
                    width={getColumnWidth(k)}
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
          {results?.map((result, rowIndex) => {
            const { bootc_booted_image: bootcBootedImage, digests } = result;
            const isExpanded = imageIsExpanded(bootcBootedImage);
            return (
              <Tbody key={`bootable-container-images-body-${bootcBootedImage}`} isExpanded={isExpanded}>
                <Tr key={bootcBootedImage} ouiaId={`table-row-${rowIndex}`}>
                  <>
                    <Td
                      expand={digests.length > 0 && {
                        rowIndex,
                        isExpanded,
                        onToggle: (_event, _rInx, isOpen) =>
                          expandedImages.onToggle(isOpen, bootcBootedImage),
                        expandId: `booted-containers-expander-${bootcBootedImage}`,
                      }}
                    />
                    {columnNamesKeys.map(k => (
                      <Td
                        key={`${bootcBootedImage}-${keysToColumnNames[k]}`}
                        dataLabel={keysToColumnNames[k]}
                      >
                        {columns[k].wrapper ? columns[k].wrapper(result) : result[k]}
                      </Td>
                    ))}
                  </>
                </Tr>
                {digests ?
                  <Tr isExpanded={isExpanded} ouiaId={`table-row-outer-expandable-${rowIndex}`}>
                    <Td />
                    <Td colSpan={3}>
                      <ExpandableRowContent>
                        <TableComposable variant="compact" isStriped ouiaId={`table-composable-expanded-${rowIndex}`}>
                          <Thead>
                            <Tr ouiaId={`table-row-inner-expandable-${rowIndex}`}>
                              <Th width={55}>{__('Image digest')}</Th>
                              <Th width={45}>{__('Hosts')}</Th>
                            </Tr>
                          </Thead>
                          <Tbody>
                            {digests.map((digest, index) => (
                              <Tr key={digest.bootc_booted_digest} ouiaId={`table-row-expandable-content-${index}`}>
                                <Td>{digest.bootc_booted_digest}</Td>
                                <Td>
                                  <a href={`${foremanHostsPageUrl}?search=bootc_booted_digest%20=%20${digest.bootc_booted_digest}`}>{digest.host_count}</a>
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

export default BootedContainerImagesPage;
