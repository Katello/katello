import React, { useState, useEffect, useRef } from 'react';
import { useSelector, shallowEqual, useDispatch } from 'react-redux';
import { useParams, useHistory } from 'react-router-dom';
import {
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
  Button,
  Flex,
  FlexItem,
  Modal,
  ModalVariant,
  Breadcrumb,
  BreadcrumbItem,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
  DropdownPosition,
} from '@patternfly/react-core/deprecated';
import { STATUS } from 'foremanReact/constants';
import { ExternalLinkAltIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { addToast } from 'foremanReact/components/ToastsList';
import { getResponseErrorMsgs } from '../../../utils/helpers';

import { getContentCredentialDetails } from './ContentCredentialsDetailsActions';
import Loading from '../../../components/Loading';
import DetailsTab from './DetailsTab';
import ProductsTab from './ProductsTab';
import RepositoriesTab from './RepositoriesTab';
import AlternateContentSourcesTab from './AlternateContentSourcesTab';
import {
  selectContentCredentialDetails,
  selectContentCredentialDetailsStatus,
  selectContentCredentialDetailsError,
} from './ContentCredentialsDetailsSelectors';
import RoutedTabs from '../../../components/RoutedTabs';
import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';
import { CONTENT_CREDENTIAL_GPG_TYPE } from '../ContentCredentialConstants';
import api, { orgId } from '../../../services/api';

const ContentCredentialsDetails = () => {
  const { id } = useParams();
  const history = useHistory();
  const credentialId = Number(id);
  const details = useSelector(state =>
    selectContentCredentialDetails(state, credentialId), shallowEqual);
  const [dropDownOpen, setDropdownOpen] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const isMountedRef = useRef(true);
  const dispatch = useDispatch();
  const status = useSelector(state =>
    selectContentCredentialDetailsStatus(state, credentialId), shallowEqual);
  const error = useSelector(state =>
    selectContentCredentialDetailsError(state, credentialId), shallowEqual);

  useEffect(() => {
    dispatch(getContentCredentialDetails(credentialId));
  }, [credentialId, dispatch]);

  useEffect(() => () => {
    isMountedRef.current = false;
  }, []);

  const handleDelete = async () => {
    try {
      await api.delete(`/content_credentials/${credentialId}`, {}, {
        organization_id: orgId(),
      });
      history.push('/labs/content_credentials');
    } catch (deleteError) {
      const [errorMessage] = getResponseErrorMsgs(deleteError.response)
        .filter(Boolean);
      dispatch(addToast({
        type: 'error',
        message: errorMessage || __('Failed to delete content credential. Please try again.'),
      }));
    }
    if (isMountedRef.current) {
      setDeleting(false);
    }
  };

  if (status === STATUS.PENDING) return (<Loading />);
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);

  const {
    name,
    content_type: contentType,
  } = details;

  const formatContentType = (type) => {
    if (type === CONTENT_CREDENTIAL_GPG_TYPE) return __('GPG Key');
    return __('Certificate');
  };

  const dropDownItems = [
    <DropdownItem key="delete" ouiaId="credential-delete" onClick={() => { setDeleting(true); }}>
      {__('Delete')}
    </DropdownItem>,
  ];

  const detailsTab = {
    key: 'details',
    title: __('Details'),
    content: <DetailsTab {...{ credentialId, details }} />,
  };

  const productsTab = {
    key: 'products',
    title: __('Products'),
    content: <ProductsTab {...{ details }} />,
  };

  const repositoriesTab = {
    key: 'repositories',
    title: __('Repositories'),
    content: <RepositoriesTab {...{ details }} />,
  };

  const alternateContentSourcesTab = {
    key: 'alternate_content_sources',
    title: __('Alternate content sources'),
    content: <AlternateContentSourcesTab {...{ details }} />,
  };

  const tabs = [
    detailsTab,
    productsTab,
    repositoriesTab,
    alternateContentSourcesTab,
  ];

  return (
    <>
      <Grid>
        <Grid className="margin-16-24">
          <Breadcrumb ouiaId="content-credential-breadcrumb" className="margin-bottom-24">
            <BreadcrumbItem to="/labs/content_credentials">
              {__('Content Credentials')}
            </BreadcrumbItem>
            <BreadcrumbItem isActive>{name}</BreadcrumbItem>
          </Breadcrumb>
          <GridItem md={8} sm={12}>
            <Flex alignItems={{
              default: 'alignItemsCenter',
            }}
            >
              <FlexItem>
                <TextContent>
                  <Text ouiaId="credential-details-header-name" component={TextVariants.h1}>
                    {name} ({formatContentType(contentType)})
                  </Text>
                </TextContent>
              </FlexItem>
            </Flex>
          </GridItem>
          <GridItem md={4} sm={12}>
            <Flex justifyContent={{ lg: 'justifyContentFlexEnd', sm: 'justifyContentFlexStart' }}>
              <FlexItem>
                <Button
                  ouiaId="credential-details-view-tasks-button"
                  component="a"
                  aria-label="view tasks button"
                  href={'/foreman_tasks/tasks?search=resource_type%3D+Katello%3A%3A' +
                        `ContentCredential+resource_id%3D${credentialId}`}
                  target="_blank"
                  variant="secondary"
                >
                  {__('View tasks ')}
                  <ExternalLinkAltIcon />
                </Button>
              </FlexItem>
              <FlexItem>
                <Dropdown
                  position={DropdownPosition.right}
                  ouiaId="credential-details-actions"
                  toggle={<KebabToggle
                    onToggle={(_event, val) => setDropdownOpen(val)}
                    id="toggle-dropdown"
                  />}
                  isOpen={dropDownOpen}
                  isPlain
                  dropdownItems={dropDownItems}
                />
              </FlexItem>
            </Flex>
          </GridItem>
        </Grid>
        <GridItem span={12}>
          <RoutedTabs tabs={tabs} defaultTabIndex={0} />
        </GridItem>
      </Grid>
      {deleting && (
        <Modal
          variant={ModalVariant.small}
          title={__('Delete Content Credential')}
          isOpen={deleting}
          onClose={() => setDeleting(false)}
          ouiaId="delete-content-credential-modal"
          actions={[
            <Button
              key="confirm"
              variant="danger"
              onClick={handleDelete}
              ouiaId="delete-confirm-button"
            >
              {__('Delete')}
            </Button>,
            <Button
              key="cancel"
              variant="link"
              onClick={() => setDeleting(false)}
              ouiaId="delete-cancel-button"
            >
              {__('Cancel')}
            </Button>,
          ]}
        >
          {__(`Are you sure you want to delete content credential "${name}"?` +
             ' This action cannot be undone.')}
        </Modal>
      )}
    </>
  );
};

export default ContentCredentialsDetails;
