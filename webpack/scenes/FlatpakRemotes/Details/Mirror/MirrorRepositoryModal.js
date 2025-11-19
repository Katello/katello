import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
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
  Alert,
  AlertVariant,
  AlertActionCloseButton,
  Checkbox,
  Spinner,
} from '@patternfly/react-core';
import SearchText from '../../../../components/Search/SearchText';
import { getRemoteRepositories, getRemoteRepository, mirrorFlatpakRepository } from '../FlatpakRemoteDetailActions';
import { selectRemoteRepository, selectRemoteRepositoryStatus } from '../FlatpakRemoteDetailSelectors';
import { orgId } from '../../../../services/api';

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
  const [selectedDependencies, setSelectedDependencies] = useState([]);
  const [alertDismissed, setAlertDismissed] = useState(false);

  const repoDetails = useSelector(state => selectRemoteRepository(state, repo.id));
  const repoStatus = useSelector(state => selectRemoteRepositoryStatus(state, repo.id));

  const fetchingDependencies = repoStatus === STATUS.PENDING;
  const dependencies = repoDetails?.repository_dependencies || [];
  const unmirroredDependencies = dependencies.filter(dep => !dep.exists_in_org);

  useEffect(() => {
    dispatch(getRemoteRepository(repo.id));
  }, [dispatch, repo.id]);

  const handleSearchChange = (rawValue) => {
    setProductName(rawValue.trim());
  };

  const handleDependencyToggle = (depId) => {
    setSelectedDependencies((prev) => {
      if (prev.includes(depId)) {
        return prev.filter(id => id !== depId);
      }
      return [...prev, depId];
    });
  };

  const handleMirror = (e) => {
    e.preventDefault();
    if (!productName || loading) return;
    setLoading(true);
    dispatch(mirrorFlatpakRepository(
      repo.id,
      productName,
      selectedDependencies,
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
        {fetchingDependencies && (
          <Spinner size="md" />
        )}

        {!fetchingDependencies && unmirroredDependencies.length > 0 && !alertDismissed && (
          <Alert
            variant={AlertVariant.info}
            isInline
            title={__('Dependency found')}
            ouiaId="dependency-alert"
            actionClose={<AlertActionCloseButton onClose={() => setAlertDismissed(true)} />}
          >
            <TextContent>
              <Text component={TextVariants.p} ouiaId="dependency-info-text">
                {__('Ensure the runtime dependency for this Flatpak app is also mirrored in this organization to avoid installation errors on host(s).')}
              </Text>
            </TextContent>
            {unmirroredDependencies.map(dep => (
              <Checkbox
                key={dep.id}
                id={`dep-checkbox-${dep.id}`}
                label={
                  <>
                    {__('Mirror runtime repository ')}<strong>{dep.name}</strong>{__(' to same product')}
                  </>
                }
                isChecked={selectedDependencies.includes(dep.id)}
                onChange={() => handleDependencyToggle(dep.id)}
                ouiaId={`mirror-dep-checkbox-${dep.id}`}
              />
            ))}
          </Alert>
        )}

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
