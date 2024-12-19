import React from 'react';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { Table } from 'foremanReact/components/PF4/TableIndexPage/Table/Table';
import {
  useSetParamsAndApiAndSearch,
  useTableIndexAPIResponse,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import {
  useUrlParams,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { translate as __ } from 'foremanReact/common/I18n';
import BOOTED_CONTAINER_IMAGES_KEY, { BOOTED_CONTAINER_IMAGES_API_PATH } from './BootedContainerImagesConstants';

const BootedContainerImagesPage = () => {
  const columns = {
    image_name: {
      title: __('Image name'),
      isSorted: true,
    },
    digest: {
      title: __('Image digests'),
      wrapper: ({digests}) => digests.length,
    },
    hosts: {
      title: __('Hosts'),
      wrapper: ({image_name, digests}) => (
        <a href={`/hosts?search=bootc_booted_image%20=%20${image_name}`}>{digests.reduce((total, digest) => total + digest.host_count, 0)}</a>
      ),
    },
  };

  const STATUS = {
    PENDING: 'PENDING',
    RESOLVED: 'RESOLVED',
    ERROR: 'ERROR',
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

  const {
    response: {
      results,
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

  return (
    <TableIndexPage
      apiUrl={BOOTED_CONTAINER_IMAGES_API_PATH}
      apiOptions={{ key: BOOTED_CONTAINER_IMAGES_KEY }}
      header={__('Booted container images')}
      createable={false}
      isDeleteable={false}
      controller="/katello/api/v2/host_bootc_images"
    >
      <Table
        ouiaId="booted-container-images-table"
        isEmbedded={false}
        params={{
          ...params,
          page,
          perPage,
        }}
        setParams={setParamsAndAPI}
        itemCount={subtotal}
        results={results}
        url={BOOTED_CONTAINER_IMAGES_API_PATH}
        isDeleteable={false}
        refreshData={() =>
          setAPIOptions({
            ...apiOptions,
            params: { urlSearchQuery },
          })
        }
        columns={columns}
        errorMessage={
          status === STATUS.ERROR && errorMessage ? errorMessage : null
        }
        isPending={status === STATUS.PENDING}
      />
    </TableIndexPage>
  );
};

export default BootedContainerImagesPage;
