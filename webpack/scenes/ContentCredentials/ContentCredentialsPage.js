import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import {
  useSetParamsAndApiAndSearch,
  useTableIndexAPIResponse,
} from 'foremanReact/components/PF4/TableIndexPage/Table/TableIndexHooks';
import { useUrlParams } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { CONTENT_CREDENTIAL_GPG_TYPE } from './ContentCredentialConstants';
import { orgId } from '../../services/api';
import CreateContentCredentialModal from './Create';
import DeleteContentCredentialModal from './Delete/DeleteContentCredentialModal';

const formatContentType = (contentType) => {
  if (contentType === CONTENT_CREDENTIAL_GPG_TYPE) return __('GPG Key');
  return __('Certificate');
};

const getProductsCount = credential =>
  (credential.gpg_key_products?.length || 0) +
  (credential.ssl_ca_products?.length || 0) +
  (credential.ssl_client_products?.length || 0) +
  (credential.ssl_key_products?.length || 0);

const getRepositoriesCount = credential =>
  (credential.gpg_key_repos?.length || 0) +
  (credential.ssl_ca_root_repos?.length || 0) +
  (credential.ssl_client_root_repos?.length || 0) +
  (credential.ssl_key_root_repos?.length || 0);

const getACSCount = credential =>
  (credential.ssl_ca_alternate_content_sources?.length || 0) +
  (credential.ssl_client_alternate_content_sources?.length || 0) +
  (credential.ssl_key_alternate_content_sources?.length || 0);

const ContentCredentialsPage = () => {
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [credentialToDelete, setCredentialToDelete] = useState(null);

  const apiOptions = {
    key: 'CONTENT_CREDENTIALS',
  };

  const apiUrl = '/katello/api/v2/content_credentials';

  const {
    searchParam: urlSearchQuery = '',
    page: urlPage,
    per_page: urlPerPage,
  } = useUrlParams();

  const defaultParams = {
    search: urlSearchQuery,
    include_permissions: true,
  };
  if (urlPage) defaultParams.page = Number(urlPage);
  if (urlPerPage) defaultParams.per_page = Number(urlPerPage);

  const apiResponse = useTableIndexAPIResponse({
    apiUrl,
    apiOptions,
    defaultParams,
  });

  useSetParamsAndApiAndSearch({
    apiOptions,
    setAPIOptions: apiResponse.setAPIOptions,
  });

  const { can_create: canCreate = false, can_delete: canDelete = false } =
    apiResponse.response || {};

  const rowKebabItems = credential => [
    {
      title: __('Delete'),
      isDisabled:
        !canDelete || !credential.permissions?.destroy_content_credentials,
      onClick: () => {
        setCredentialToDelete({
          id: credential.id,
          name: credential.name,
        });
        setIsDeleteModalOpen(true);
      },
    },
  ];

  const columns = {
    name: {
      title: __('Name'),
      isSorted: true,
      wrapper: rowData => (
        <Link to={`/content_credentials/${rowData.id}`}>
          {rowData.name}
        </Link>
      ),
    },
    organization: {
      title: __('Organization'),
      wrapper: rowData => rowData.organization?.name,
    },
    content_type: {
      title: __('Type'),
      wrapper: rowData => formatContentType(rowData.content_type),
    },
    products: {
      title: __('Products'),
      wrapper: rowData => getProductsCount(rowData),
    },
    repositories: {
      title: __('Repositories'),
      wrapper: rowData => getRepositoriesCount(rowData),
    },
    alternate_content_sources: {
      title: __('Alternate content sources'),
      wrapper: rowData => getACSCount(rowData),
    },
  };

  const refreshTable = () => {
    apiResponse.setAPIOptions({ ...apiOptions, params: defaultParams });
  };

  return (
    <>
      <TableIndexPage
        apiUrl={apiUrl}
        apiOptions={apiOptions}
        header={__('Content Credentials')}
        columns={columns}
        creatable={canCreate}
        customCreateAction={() => () => setIsCreateModalOpen(true)}
        rowKebabItems={rowKebabItems}
        customSearchProps={{
          autocomplete: {
            url: `${apiUrl}/auto_complete_search`,
            apiParams: { organization_id: orgId() },
          },
          controller: 'katello_content_credentials',
          bookmarks: {
            url: '/api/bookmarks',
            canCreate: true,
          },
        }}
        ouiaId="content-credentials-table"
      />
      <CreateContentCredentialModal
        show={isCreateModalOpen}
        setIsOpen={setIsCreateModalOpen}
        refreshTable={refreshTable}
      />
      <DeleteContentCredentialModal
        isModalOpen={isDeleteModalOpen}
        handleModalToggle={() => setIsDeleteModalOpen(!isDeleteModalOpen)}
        credentialId={credentialToDelete?.id}
        credentialName={credentialToDelete?.name}
        refreshTable={refreshTable}
      />
    </>
  );
};

export default ContentCredentialsPage;
