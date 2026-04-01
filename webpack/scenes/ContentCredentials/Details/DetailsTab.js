import React, { useState, useEffect, useRef } from 'react';
import { useDispatch } from 'react-redux';
import { addToast } from 'foremanReact/components/ToastsList';
import {
  TextContent,
  TextList,
  TextListVariants,
  TextListItem,
  TextListItemVariants,
  Button,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { FileUploadIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import ActionableDetail from '../../../components/ActionableDetail';
import { updateContentCredential, uploadContentCredentialContent } from './ContentCredentialsDetailsActions';
import { CONTENT_CREDENTIAL_GPG_TYPE } from '../ContentCredentialConstants';

const DetailsTab = ({ credentialId, details }) => {
  const dispatch = useDispatch();
  const [currentAttribute, setCurrentAttribute] = useState();
  const [uploading, setUploading] = useState(false);
  const [updating, setUpdating] = useState(false);
  const isMountedRef = useRef(true);

  // Cleanup effect to prevent state updates after unmount
  useEffect(() => () => {
    isMountedRef.current = false;
  }, []);

  const {
    name,
    content_type: contentType,
    content,
    gpg_key_products: gpgKeyProducts = [],
    ssl_ca_products: sslCaProducts = [],
    ssl_client_products: sslClientProducts = [],
    ssl_key_products: sslKeyProducts = [],
    gpg_key_repos: gpgKeyRepos = [],
    ssl_ca_root_repos: sslCaRootRepos = [],
    ssl_client_root_repos: sslClientRootRepos = [],
    ssl_key_root_repos: sslKeyRootRepos = [],
    ssl_ca_alternate_content_sources: sslCaACS = [],
    ssl_client_alternate_content_sources: sslClientACS = [],
    ssl_key_alternate_content_sources: sslKeyACS = [],
    permissions = {},
  } = details;

  const onEdit = async (val, attribute) => {
    if (val === details[attribute]) return;

    if (!isMountedRef.current) return;
    setCurrentAttribute(attribute);
    setUpdating(true);

    try {
      await dispatch(updateContentCredential(credentialId, { [attribute]: val }));
    } finally {
      if (isMountedRef.current) {
        setUpdating(false);
        setCurrentAttribute(null);
      }
    }
  };

  const handleFileUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    // Store the input element reference before async operations
    const inputElement = event.target;

    if (!isMountedRef.current) return;
    setUploading(true);
    try {
      await dispatch(uploadContentCredentialContent(credentialId, file));
      // Clear the file input to allow re-uploading the same file
      if (inputElement) inputElement.value = '';
    } catch (error) {
      // Clear the file input even on failure
      if (inputElement) inputElement.value = '';

      // Fallback error toast in case the action doesn't handle it
      dispatch(addToast({
        type: 'danger',
        message: __('Failed to upload file.'),
        key: `credential-upload-fallback-error-${credentialId}`,
      }));
    } finally {
      // Always reset uploading state if component is still mounted
      if (isMountedRef.current) {
        setUploading(false);
      }
    }
  };

  const formatContentType = (type) => {
    if (type === CONTENT_CREDENTIAL_GPG_TYPE) return __('GPG Key');
    return __('Certificate');
  };

  const getProductsCount = () =>
    gpgKeyProducts.length + sslCaProducts.length + sslClientProducts.length + sslKeyProducts.length;

  const getRepositoriesCount = () =>
    gpgKeyRepos.length + sslCaRootRepos.length + sslClientRootRepos.length + sslKeyRootRepos.length;

  const getACSCount = () =>
    sslCaACS.length + sslClientACS.length + sslKeyACS.length;

  const canEdit = permissions?.edit_content_credentials || false;

  return (
    <TextContent className="margin-0-24">
      <TextList component={TextListVariants.dl}>
        <ActionableDetail
          key="name-field"
          label={__('Name')}
          attribute="name"
          loading={updating && currentAttribute === 'name'}
          onEdit={onEdit}
          disabled={!canEdit}
          value={name}
          {...{ currentAttribute, setCurrentAttribute }}
        />

        <TextListItem component={TextListItemVariants.dt}>
          {__('Type')}
        </TextListItem>
        <TextListItem
          aria-label="content type value"
          component={TextListItemVariants.dd}
          className="foreman-spaced-list"
        >
          {formatContentType(contentType)}
        </TextListItem>

        <ActionableDetail
          key="content-field"
          textArea
          label={__('Content')}
          attribute="content"
          loading={updating && currentAttribute === 'content'}
          onEdit={onEdit}
          disabled={!canEdit}
          value={content || ''}
          textAreaProps={{
            rows: 12,
            style: { fontFamily: 'monospace', fontSize: '12px' },
          }}
          component="pre"
          style={{ fontFamily: 'monospace', fontSize: '12px', whiteSpace: 'pre-wrap' }}
          {...{ currentAttribute, setCurrentAttribute }}
        />

        <TextListItem component={TextListItemVariants.dt}>
          {__('Upload new file')}
        </TextListItem>
        <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
          <Flex>
            <FlexItem>
              <input
                type="file"
                id="credential-file-upload"
                style={{ display: 'none' }}
                onChange={handleFileUpload}
                disabled={!canEdit || uploading}
                accept={contentType === CONTENT_CREDENTIAL_GPG_TYPE ? '.asc,.gpg,.key' : '.crt,.pem,.cer,.cert'}
              />
              <Button
                variant="secondary"
                icon={<FileUploadIcon />}
                isLoading={uploading}
                isDisabled={!canEdit || uploading}
                onClick={() => document.getElementById('credential-file-upload').click()}
                ouiaId="upload-file-button"
              >
                {__('Choose file')}
              </Button>
            </FlexItem>
          </Flex>
        </TextListItem>

        <TextListItem component={TextListItemVariants.dt}>
          {__('Products')}
        </TextListItem>
        <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
          <a href="#/products">{getProductsCount()}</a>
        </TextListItem>

        <TextListItem component={TextListItemVariants.dt}>
          {__('Repositories')}
        </TextListItem>
        <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
          <a href="#/repositories">{getRepositoriesCount()}</a>
        </TextListItem>

        <TextListItem component={TextListItemVariants.dt}>
          {__('Alternate content sources')}
        </TextListItem>
        <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
          <a href="#/alternate_content_sources">{getACSCount()}</a>
        </TextListItem>
      </TextList>
    </TextContent>
  );
};

DetailsTab.propTypes = {
  credentialId: PropTypes.number.isRequired,
  details: PropTypes.shape({
    name: PropTypes.string,
    content_type: PropTypes.string,
    content: PropTypes.string,
    gpg_key_products: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_ca_products: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_client_products: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_key_products: PropTypes.arrayOf(PropTypes.shape({})),
    gpg_key_repos: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_ca_root_repos: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_client_root_repos: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_key_root_repos: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_ca_alternate_content_sources: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_client_alternate_content_sources: PropTypes.arrayOf(PropTypes.shape({})),
    ssl_key_alternate_content_sources: PropTypes.arrayOf(PropTypes.shape({})),
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default DetailsTab;
