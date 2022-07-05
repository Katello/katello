import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { useParams } from 'react-router-dom';
import { isEmpty } from 'lodash';
import {
  Button,
  ExpandableSection,
  ExpandableSectionToggle,
  List,
  ListItem,
  Split,
  SplitItem,
  Stack,
  StackItem,
  TextContent,
  TextList,
  TextListItem,
  TextListItemVariants,
  TextListVariants,
} from '@patternfly/react-core';
import { PencilAltIcon } from '@patternfly/react-icons';
import { STATUS } from 'foremanReact/constants';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { getACSDetails } from '../ACSActions';
import { selectACSDetails, selectACSDetailsStatus } from '../ACSSelectors';
import Loading from '../../../components/Loading';
import InactiveText from '../../ContentViews/components/InactiveText';
import ACSEditDetails from './EditModals/ACSEditDetails';
import ACSEditURLPaths from './EditModals/ACSEditURLPaths';
import ACSEditSmartProxies from './EditModals/ACSEditSmartProxies';
import ACSEditCredentials from './EditModals/ACSEditCredentials';
import ACSEditProducts from './EditModals/ACSEditProducts';

const ACSExpandableDetails = () => {
  const { id } = useParams();
  const acsId = Number(id);
  const details = useSelector(state => selectACSDetails(state, acsId));
  const status = useSelector(state => selectACSDetailsStatus(state, acsId));
  const dispatch = useDispatch();
  const [showDetails, setShowDetails] = useState(true);
  const [showSmartProxies, setShowSmartProxies] = useState(false);
  const [showProducts, setShowProducts] = useState(false);
  const [showUrlPaths, setShowUrlPaths] = useState(false);
  const [showCredentials, setShowCredentials] = useState(false);
  const [editDetailsModalOpen, setEditDetailsModalOpen] = useState(false);
  const [editUrlModalOpen, setEditUrlModalOpen] = useState(false);
  const [editSmartProxiesModalOpen, setEditSmartProxiesModalOpen] = useState(false);
  const [editProductsModalOpen, setEditProductsModalOpen] = useState(false);
  const [editCredentialsModalOpen, setEditCredentialsModalOpen] = useState(false);

  useDeepCompareEffect(() => {
    if (isEmpty(details)) {
      dispatch(getACSDetails(acsId));
    }
  }, [acsId, details, dispatch]);

  if (status === STATUS.PENDING) return <Loading />;

  const {
    name,
    alternate_content_source_type: acsType,
    content_type: contentType,
    subpaths,
    description,
    base_url: url,
    smart_proxies: smartProxies,
    verify_ssl: verifySsl,
    ssl_ca_cert: sslCaCert,
    ssl_client_cert: sslClientCert,
    ssl_client_key: sslClientKey,
    upstream_username: username,
    products,
  } = details;
  return (
    <>
      <Stack>
        <StackItem>
          <Split>
            <SplitItem isFilled>
              <ExpandableSectionToggle
                isExpanded={showDetails}
                onToggle={(expanded) => {
                  setShowDetails(expanded);
                  setShowSmartProxies(false);
                  setShowProducts(false);
                  setShowUrlPaths(false);
                  setShowCredentials(false);
                }}
                contentId="showDetails"
              >
                {showDetails ? __('Hide details') : __('Show details')}
              </ExpandableSectionToggle>
            </SplitItem>
            <SplitItem>
              <Button
                ouiaId="edit-details-pencil-edit"
                aria-label="edit-details-pencil-edit"
                variant="link"
                isSmall
                icon={<PencilAltIcon />}
                onClick={() => setEditDetailsModalOpen(true)}
              >{__('Edit Details')}
              </Button>
            </SplitItem>
          </Split>
        </StackItem>
        <StackItem>
          <ExpandableSection
            isExpanded={showDetails}
            isDetached
            contentId="showDetails"
          >
            <TextContent className="margin-0-24">
              <TextList component={TextListVariants.dl}>
                <TextListItem component={TextListItemVariants.dt}>
                  {__('Name')}
                </TextListItem>
                <TextListItem
                  aria-label="name_text_value"
                  component={TextListItemVariants.dd}
                >
                  {name}
                </TextListItem>
                <TextListItem component={TextListItemVariants.dt}>
                  {__('Description')}
                </TextListItem>
                <TextListItem
                  aria-label="name_text_value"
                  component={TextListItemVariants.dd}
                >
                  {description}
                </TextListItem>
                <TextListItem component={TextListItemVariants.dt}>
                  {__('Type')}
                </TextListItem>
                <TextListItem
                  aria-label="type_text_value"
                  component={TextListItemVariants.dd}
                >
                  {acsType}
                </TextListItem>
                <TextListItem component={TextListItemVariants.dt}>
                  {__('Content type')}
                </TextListItem>
                <TextListItem
                  aria-label="content_type_text_value"
                  component={TextListItemVariants.dd}
                >
                  {contentType}
                </TextListItem>
              </TextList>
            </TextContent>
          </ExpandableSection>
        </StackItem>
        <StackItem>
          <Split>
            <SplitItem isFilled>
              <ExpandableSectionToggle
                isExpanded={showSmartProxies}
                onToggle={(expanded) => {
                  setShowDetails(false);
                  setShowSmartProxies(expanded);
                  setShowUrlPaths(false);
                  setShowCredentials(false);
                }}
                contentId="showSmartProxies"
              >
                {showSmartProxies ? 'Hide smart proxies' : 'Show smart proxies'}
              </ExpandableSectionToggle>
            </SplitItem>
            <SplitItem>
              <Button
                ouiaId="edit-smart-proxies-pencil-edit"
                aria-label="edit-smart-proxies-pencil-edit"
                variant="link"
                isSmall
                icon={<PencilAltIcon />}
                onClick={() => setEditSmartProxiesModalOpen(true)}
              >{__('Edit smart proxies')}
              </Button>
            </SplitItem>
          </Split>
        </StackItem>
        <StackItem>
          <ExpandableSection
            isDetached
            contentId="showSmartProxies"
            isExpanded={showSmartProxies}
          >
            <List className="margin-0-24" isPlain isBordered>
              {smartProxies?.length > 0 && smartProxies.map(sp =>
                (
                  <ListItem key={sp?.id} aria-label="smartproxy_value">
                    <a href={urlBuilder(`smart_proxies/${sp?.id}`, '')}><b>{sp?.name}</b></a>
                  </ListItem>
                ))}
              {smartProxies?.length === 0 &&
              <InactiveText text="N/A" />
                            }
            </List>
          </ExpandableSection>
        </StackItem>
        {acsType === 'simplified' &&
        <>
          <StackItem>
            <Split>
              <SplitItem isFilled>
                <ExpandableSectionToggle
                  onToggle={(expanded) => {
                    setShowDetails(false);
                    setShowSmartProxies(false);
                    setShowProducts(expanded);
                    setShowUrlPaths(false);
                    setShowCredentials(false);
                  }}
                  isExpanded={showProducts}
                  contentId="showProducts"
                >
                  {showProducts ? 'Hide products' : 'Show products'}
                </ExpandableSectionToggle>
              </SplitItem>
              <SplitItem>
                <Button
                  ouiaId="edit-products-pencil-edit"
                  aria-label="edit-products-pencil-edit"
                  variant="link"
                  isSmall
                  icon={<PencilAltIcon />}
                  onClick={() => setEditProductsModalOpen(true)}
                >{__('Edit products')}
                </Button>
              </SplitItem>
            </Split>
          </StackItem>
          <StackItem>
            <ExpandableSection
              isDetached
              contentId="showProducts"
              isExpanded={showProducts}
            >
              <List className="margin-0-24" isPlain isBordered>
                {products.map(product =>
                  (
                    <ListItem key={product?.id} aria-label="product_value">
                      <a href={urlBuilder(`products/${product?.id}`, '')}><b>{product?.name}</b></a>
                    </ListItem>
                  ))}
              </List>
            </ExpandableSection>
          </StackItem>
        </>
                }
        {acsType === 'custom' &&
        <>
          <StackItem>
            <Split>
              <SplitItem isFilled>
                <ExpandableSectionToggle
                  onToggle={(expanded) => {
                    setShowDetails(false);
                    setShowSmartProxies(false);
                    setShowUrlPaths(expanded);
                    setShowCredentials(false);
                  }}
                  isExpanded={showUrlPaths}
                  contentId="showUrlPaths"
                >
                  {showUrlPaths ? 'Hide URL and subpaths' : 'Show URL and subpaths'}
                </ExpandableSectionToggle>
              </SplitItem>
              <SplitItem>
                <Button
                  ouiaId="edit-urls-pencil-edit"
                  aria-label="edit-urls-pencil-edit"
                  variant="link"
                  isSmall
                  icon={<PencilAltIcon />}
                  onClick={() => setEditUrlModalOpen(true)}
                >{__('Edit URL and subpaths')}
                </Button>
              </SplitItem>
            </Split>
          </StackItem>
          <StackItem>
            <ExpandableSection
              contentId="showUrlPaths"
              isDetached
              isExpanded={showUrlPaths}
            >
              <TextContent className="margin-0-24">
                <TextList component={TextListVariants.dl}>
                  <TextListItem component={TextListItemVariants.dt}>
                    {__('URL')}
                  </TextListItem>
                  <TextListItem
                    aria-label="url_text_value"
                    component={TextListItemVariants.dd}
                  >
                    {url}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>
                    {__('Subpaths')}
                  </TextListItem>
                  <TextListItem
                    aria-label="subpaths_text_value"
                    component={TextListItemVariants.dd}
                  >
                    {subpaths.join()}
                  </TextListItem>
                </TextList>
              </TextContent>
            </ExpandableSection>
          </StackItem>
          <StackItem>
            <Split>
              <SplitItem isFilled>
                <ExpandableSectionToggle
                  onToggle={(expanded) => {
                    setShowDetails(false);
                    setShowSmartProxies(false);
                    setShowUrlPaths(false);
                    setShowCredentials(expanded);
                  }}
                  isExpanded={showCredentials}
                  contentId="showCredentials"
                >
                  {showCredentials ? 'Hide credentials' : 'Show credentials'}
                </ExpandableSectionToggle>
              </SplitItem>
              <SplitItem>
                <Button
                  ouiaId="edit-credentials-pencil-edit"
                  aria-label="edit-credentials-pencil-edit"
                  variant="link"
                  isSmall
                  icon={<PencilAltIcon />}
                  onClick={() => setEditCredentialsModalOpen(true)}
                >{__('Edit credentials')}
                </Button>
              </SplitItem>
            </Split>
          </StackItem>
          <StackItem>
            <ExpandableSection
              isExpanded={showCredentials}
              contentId="showCredentials"
              isDetached
            >
              <TextContent className="margin-0-24">
                <TextList component={TextListVariants.dl}>
                  <TextListItem component={TextListItemVariants.dt}>
                    {__('Verify SSL')}
                  </TextListItem>
                  <TextListItem
                    aria-label="verifySSL_value"
                    component={TextListItemVariants.dd}
                  >
                    {verifySsl ? 'true' : 'false'}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>
                    {__('SSL CA certificate')}
                  </TextListItem>
                  <TextListItem
                    aria-label="sslCaCert_value"
                    component={TextListItemVariants.dd}
                  >
                    {sslCaCert ?
                      <a href={urlBuilder(`content_credentials/${sslCaCert?.id}`, '')}>{sslCaCert?.name}</a> :
                      <InactiveText text="N/A" />}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>
                    {__('SSL client certificate')}
                  </TextListItem>
                  <TextListItem
                    aria-label="sslClientCert_value"
                    component={TextListItemVariants.dd}
                  >
                    {sslClientCert ?
                      <a href={urlBuilder(`content_credentials/${sslClientCert?.id}`, '')}>{sslClientCert?.name}</a> :
                      <InactiveText text="N/A" />}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>
                    {__('SSL client key')}
                  </TextListItem>
                  <TextListItem
                    aria-label="sslClientKey_value"
                    component={TextListItemVariants.dd}
                  >
                    {sslClientKey ?
                      <a href={urlBuilder(`content_credentials/${sslClientKey?.id}`, '')}>{sslClientKey?.name}</a> :
                      <InactiveText text="N/A" />}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>
                    {__('Username')}
                  </TextListItem>
                  <TextListItem
                    aria-label="username_value"
                    component={TextListItemVariants.dd}
                  >
                    {username || <InactiveText text="N/A" />}
                  </TextListItem>
                  <TextListItem component={TextListItemVariants.dt}>
                    {__('Password')}
                  </TextListItem>
                  <TextListItem
                    aria-label="password_value"
                    component={TextListItemVariants.dd}
                  >
                    {username ? '****' : <InactiveText text="N/A" />}
                  </TextListItem>
                </TextList>
              </TextContent>
            </ExpandableSection>
          </StackItem>
        </>
                }
      </Stack>
      {editDetailsModalOpen &&
      <ACSEditDetails
        acsId={acsId}
        acsDetails={details}
        onClose={() => setEditDetailsModalOpen(false)}
      />
            }
      {editUrlModalOpen &&
      <ACSEditURLPaths
        acsId={acsId}
        acsDetails={details}
        onClose={() => setEditUrlModalOpen(false)}
      />
            }
      {editSmartProxiesModalOpen &&
      <ACSEditSmartProxies
        acsId={acsId}
        acsDetails={details}
        onClose={() => setEditSmartProxiesModalOpen(false)}
      />
            }
      {editProductsModalOpen &&
      <ACSEditProducts
        acsId={acsId}
        acsDetails={details}
        onClose={() => setEditProductsModalOpen(false)}
      />
            }
      {editCredentialsModalOpen &&
      <ACSEditCredentials
        acsId={acsId}
        acsDetails={details}
        onClose={() => setEditCredentialsModalOpen(false)}
      />
            }
    </>
  );
};

export default ACSExpandableDetails;
