import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal,
  ModalVariant,
  Form,
  FormGroup,
  ActionGroup,
  Button,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import { orgId } from '../../../../services/api';
import SearchText from '../../../../components/Search/SearchText';
import { getRemoteRepositories, mirrorFlatpakRepository } from '../FlatpakRemoteDetailActions';

const MirrorRepositoryModal = ({
  frId,
  closeModal,
  repo,
  onMirrorSuccess,
}) => {
  const dispatch = useDispatch();

  const autoCompleteEndpoint = '/katello/api/v2/products/auto_complete_name';
  const searchParams = term => ({
    organization_id: orgId(),
    enabled: true,
    custom: true,
    page: 1,
    per_page: 5,
    term,
  });

  const [productName, setProductName] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSearchChange = (rawValue) => {
    setProductName(rawValue.trim());
  };

  const handleMirror = (e) => {
    e.preventDefault();
    if (!productName || loading) return;
    setLoading(true);
    dispatch(mirrorFlatpakRepository(
      repo.id,
      productName,
      () => {
        dispatch(getRemoteRepositories(frId)());
        setLoading(false);
        if (onMirrorSuccess) onMirrorSuccess();
        closeModal();
      },
      () => {
        setLoading(false);
        closeModal();
      },
    ));
  };

  return (
    <Modal
      ouiaId="mirror-repo-modal"
      title={__('Mirror Repository')}
      variant={ModalVariant.medium}
      isOpen
      onClose={closeModal}
      appendTo={document.body}
    >
      <TextContent>
        <Text component={TextVariants.p} ouiaId="mirror-text-info">
          {__('Mirroring will import the remote flatpak repository')} <strong>{repo.name}</strong>{' '}
          {__('into a product. Details from the flatpak remote will automatically populate the repository fields. The repository will be available for syncing once it has been mirrored into a product.')}
        </Text>
        <Text component={TextVariants.p} ouiaId="mirror-select-product">
          {__('Select a product to mirror the repository into')}
        </Text>
      </TextContent>
      <Form onSubmit={handleMirror}>
        <FormGroup label={__('Product')} isRequired fieldId="mirror-product">
          <SearchText
            value={productName}
            data={{
              autocomplete: {
                url: autoCompleteEndpoint,
                apiParams: searchParams,
              },
            }}
            onSearchChange={handleSearchChange}
            aria-label="product-search"
          />
        </FormGroup>

        <ActionGroup>
          <Button
            ouiaId="confirm-mirror-btn"
            variant="primary"
            type="submit"
            isLoading={loading}
            isDisabled={!productName || loading}
          >
            {__('Mirror')}
          </Button>
          <Button
            ouiaId="cancel-mirror-btn"
            variant="link"
            onClick={closeModal}
          >
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

MirrorRepositoryModal.propTypes = {
  frId: PropTypes.number.isRequired,
  closeModal: PropTypes.func.isRequired,
  repo: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
  }).isRequired,
  onMirrorSuccess: PropTypes.func,
};

MirrorRepositoryModal.defaultProps = {
  onMirrorSuccess: null,
};

export default MirrorRepositoryModal;
