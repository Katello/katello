import React, { useState } from 'react';
import PropTypes from 'prop-types';
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
  Text,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { PencilAltIcon } from '@patternfly/react-icons';
import { STATUS } from 'foremanReact/constants';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { getACSDetails } from '../ACSActions';
import { selectACSDetails, selectACSDetailsError, selectACSDetailsStatus } from '../ACSSelectors';
import Loading from '../../../components/Loading';
import InactiveText from '../../ContentViews/components/InactiveText';
import ACSEditDetails from './EditModals/ACSEditDetails';
import ACSEditURLPaths from './EditModals/ACSEditURLPaths';
import ACSEditSmartProxies from './EditModals/ACSEditSmartProxies';
import ACSEditCredentials from './EditModals/ACSEditCredentials';
import ACSEditProducts from './EditModals/ACSEditProducts';
import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';
import '../Acs.scss';
import { hasPermission } from '../../ContentViews/helpers';
import { HelpToolTip } from '../../ContentViews/Create/ContentViewFormComponents';

const ACSExpandableDetails = ({ expandedId }) => {
  const { id } = useParams();
  const acsId = Number(expandedId) || Number(id);
  const details = useSelector(state => selectACSDetails(state, acsId));
  const status = useSelector(state => selectACSDetailsStatus(state, acsId));
  const error = useSelector(state => selectACSDetailsError(state, acsId));
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

  if (status === STATUS.PENDING) return <Loading skeleton />;

  const {
    name,
    alternate_content_source_type: acsType,
    content_type: contentType,
    subpaths,
    deb_releases: debReleases,
    deb_components: debComponents,
    deb_architectures: debArchitectures,
    description,
    base_url: url,
    smart_proxies: smartProxies,
    use_http_proxies: useHttpProxies,
    verify_ssl: verifySsl,
    ssl_ca_cert: sslCaCert,
    ssl_client_cert: sslClientCert,
    ssl_client_key: sslClientKey,
    upstream_username: username,
    products,
    permissions,
  } = details;
  if (error) {
    return <EmptyStateMessage error={error} />;
  }
  const canEdit = hasPermission(permissions, 'edit_alternate_content_sources');
  const debMode = contentType === 'deb';
  return (
    <>
      <Stack>
        <StackItem className="primary-detail-stack-items-border">
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
                contentId="showDetails-content"
                toggleId="showDetails-toggle"
              >
                <Text ouiaId="expandable-details-text">{__('Details')}</Text>
              </ExpandableSectionToggle>
            </SplitItem>
            {canEdit &&
            <SplitItem>
              <Button
                ouiaId="edit-details-pencil-edit"
                aria-label="edit-details-pencil-edit"
                variant="link"
                size="sm"
                icon={<PencilAltIcon />}
                onClick={() => setEditDetailsModalOpen(true)}
              >{__('Edit')}
              </Button>
            </SplitItem>
            }
          </Split>
        </StackItem>
        <StackItem className="primary-detail-stack-items-border">
          <ExpandableSection
            isExpanded={showDetails}
            isDetached
            contentId="showDetails-content"
            toggleId="showDetails-toggle"
          >
            <TextContent className="margin-0-24 expandable-section-text">
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
                  aria-label="description_text_value"
                  component={TextListItemVariants.dd}
                >
                  {description || <InactiveText text="N/A" />}
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
        <StackItem className="primary-detail-stack-items-border">
          <Split>
            <SplitItem isFilled>
              <ExpandableSectionToggle
                isExpanded={showSmartProxies}
                onToggle={(expanded) => {
                  setShowDetails(false);
                  setShowSmartProxies(expanded);
                  setShowUrlPaths(false);
                  setShowCredentials(false);
                  setShowProducts(false);
                }}
                contentId="showSmartProxies-content"
                toggleId="showSmartProxies-toggle"
              >
                <Text ouiaId="expandable-smart-proxies-text">{__('Smart proxies')}</Text>
              </ExpandableSectionToggle>
            </SplitItem>
            {canEdit &&
            <SplitItem>
              <Button
                ouiaId="edit-smart-proxies-pencil-edit"
                aria-label="edit-smart-proxies-pencil-edit"
                variant="link"
                size="sm"
                icon={<PencilAltIcon />}
                onClick={() => setEditSmartProxiesModalOpen(true)}
              >{__('Edit')}
              </Button>
            </SplitItem>
            }
          </Split>
        </StackItem>
        <StackItem className="primary-detail-stack-items-border">
          <ExpandableSection
            isDetached
            contentId="showSmartProxies-content"
            toggleId="showSmartProxies-toggle"
            isExpanded={showSmartProxies}
          >
            <List className="margin-0-24 expandable-section-text" isPlain isBordered>
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
            <TextContent className="margin-0-24 expandable-section-text" style={{ marginTop: '24px' }}>
              <TextList component={TextListVariants.dl}>
                <TextListItem component={TextListItemVariants.dt}>
                  <Flex spaceItems={{ default: 'spaceItemsNone' }}>
                    <FlexItem aria-label="httpProxyTitle">{__('Use HTTP proxies')}</FlexItem>
                    <FlexItem>
                      <HelpToolTip tooltip={__('Alternate content sources use the HTTP proxy of their assigned smart proxy for communication.')} />
                    </FlexItem>
                  </Flex>
                </TextListItem>
                <TextListItem
                  aria-label="useHttpProxies_value"
                  component={TextListItemVariants.dd}
                >
                  {useHttpProxies ? 'true' : 'false'}
                </TextListItem>
              </TextList>
            </TextContent>
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
                  contentId="showProducts-content"
                  toggleId="showProducts-toggle"
                >
                  <Text ouiaId="expandable-products-text">{__('Products')}</Text>
                </ExpandableSectionToggle>
              </SplitItem>
              {canEdit &&
              <SplitItem>
                <Button
                  ouiaId="edit-products-pencil-edit"
                  aria-label="edit-products-pencil-edit"
                  variant="link"
                  size="sm"
                  icon={<PencilAltIcon />}
                  onClick={() => setEditProductsModalOpen(true)}
                >{__('Edit')}
                </Button>
              </SplitItem>
              }
            </Split>
          </StackItem>
          <StackItem>
            <ExpandableSection
              isDetached
              contentId="showProducts-content"
              toggleId="showProducts-toggle"
              isExpanded={showProducts}
            >
              <List className="margin-0-24 expandable-section-text" isPlain isBordered>
                {products.map(product =>
                  (
                    <ListItem key={product?.id} aria-label="product_value">
                      <a href={urlBuilder(`products/${product?.id}`, '')}><b>{product?.name}</b></a>
                    </ListItem>
                  ))}
                {products?.length === 0 &&
                <InactiveText text="N/A" />
                }
              </List>
            </ExpandableSection>
          </StackItem>
        </>
                }
        {(acsType === 'custom' || acsType === 'rhui') &&
        <>
          <StackItem className="primary-detail-stack-items-border">
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
                  contentId="showUrlPaths-content"
                  toggleId="showUrlPaths-toggle"
                >
                  <Text ouiaId="expandable-url-paths-text">
                    {debMode ? __('URL and Debian fields') : __('URL and subpaths')}
                  </Text>
                </ExpandableSectionToggle>
              </SplitItem>
              {canEdit &&
              <SplitItem>
                <Button
                  ouiaId="edit-urls-pencil-edit"
                  aria-label="edit-urls-pencil-edit"
                  variant="link"
                  size="sm"
                  icon={<PencilAltIcon />}
                  onClick={() => setEditUrlModalOpen(true)}
                >{__('Edit')}
                </Button>
              </SplitItem>
              }
            </Split>
          </StackItem>
          <StackItem className="primary-detail-stack-items-border">
            <ExpandableSection
              contentId="showUrlPaths-content"
              toggleId="showUrlPaths-toggle"
              isDetached
              isExpanded={showUrlPaths}
            >
              <TextContent className="margin-0-24 expandable-section-text">
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
                  {!debMode ? (
                    <>
                      <TextListItem component={TextListItemVariants.dt}>
                        {__('Subpaths')}
                      </TextListItem>
                      <TextListItem
                        aria-label="subpaths_text_value"
                        component={TextListItemVariants.dd}
                      >
                        {subpaths.join()}
                      </TextListItem>
                    </>
                  ) : (
                    <>
                      <TextListItem component={TextListItemVariants.dt}>
                        {__('Releases/Distributions')}
                      </TextListItem>
                      <TextListItem
                        aria-label="deb_releases_text_value"
                        component={TextListItemVariants.dd}
                      >
                        {debReleases || <InactiveText text="N/A" />}
                      </TextListItem>
                      <TextListItem component={TextListItemVariants.dt}>
                        {__('Components')}
                      </TextListItem>
                      <TextListItem
                        aria-label="deb_components_text_value"
                        component={TextListItemVariants.dd}
                      >
                        {debComponents || <InactiveText text="N/A" />}
                      </TextListItem>
                      <TextListItem component={TextListItemVariants.dt}>
                        {__('Architectures')}
                      </TextListItem>
                      <TextListItem
                        aria-label="deb_architectures_text_value"
                        component={TextListItemVariants.dd}
                      >
                        {debArchitectures || <InactiveText text="N/A" />}
                      </TextListItem>
                    </>
                  )}
                </TextList>
              </TextContent>
            </ExpandableSection>
          </StackItem>
          <StackItem className="primary-detail-stack-items-border">
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
                  contentId="showCredentials-content"
                  toggleId="showCredentials-toggle"
                >
                  <Text ouiaId="expandable-credentials-text">{__('Credentials')}</Text>
                </ExpandableSectionToggle>
              </SplitItem>
              {canEdit &&
              <SplitItem>
                <Button
                  ouiaId="edit-credentials-pencil-edit"
                  aria-label="edit-credentials-pencil-edit"
                  variant="link"
                  size="sm"
                  icon={<PencilAltIcon />}
                  onClick={() => setEditCredentialsModalOpen(true)}
                >{__('Edit')}
                </Button>
              </SplitItem>
              }
            </Split>
          </StackItem>
          <StackItem className="primary-detail-stack-items-border">
            <ExpandableSection
              isExpanded={showCredentials}
              contentId="showCredentials-content"
              toggleId="showCredentials-toggle"
              isDetached
            >
              <TextContent className="margin-0-24 expandable-section-text">
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

ACSExpandableDetails.propTypes = {
  expandedId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]),
};

ACSExpandableDetails.defaultProps = {
  expandedId: null,
};

export default ACSExpandableDetails;
