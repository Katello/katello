import React from 'react';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { translate as __ } from 'foremanReact/common/I18n';
import BOOTED_CONTAINER_IMAGES_KEY, { BOOTED_CONTAINER_IMAGES_API_PATH } from './BootedContainerImagesConstants';

const BootedContainerImagesPage = () => {
  const columns = {
    image_name: {
      title: __('Image name'),
    },
  };
  return (
    <TableIndexPage
      apiUrl={BOOTED_CONTAINER_IMAGES_API_PATH}
      apiOptions={{ key: BOOTED_CONTAINER_IMAGES_KEY }}
      header={__('Booted container images')}
      createable={false}
      isDeleteable={false}
      controller="/katello/api/v2/host_bootc_images"
      columns={columns}
    />
  );
};

export default BootedContainerImagesPage;
