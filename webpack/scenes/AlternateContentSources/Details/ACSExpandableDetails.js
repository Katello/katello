import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { useParams } from 'react-router-dom';
import { isEmpty } from 'lodash';
import {
  ExpandableSection,
  List,
  ListItem,
  TextContent,
  TextList,
  TextListItem,
  TextListItemVariants,
  TextListVariants,
} from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { getACSDetails } from '../ACSActions';
import { selectACSDetails, selectACSDetailsStatus } from '../ACSSelectors';
import Loading from '../../../components/Loading';
import InactiveText from '../../ContentViews/components/InactiveText';

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
      <ExpandableSection
        toggleText={showDetails ? 'Hide details' : 'Show details'}
        onToggle={(expanded) => {
          setShowDetails(expanded);
          setShowSmartProxies(false);
          setShowProducts(false);
          setShowUrlPaths(false);
          setShowCredentials(false);
        }}
        isExpanded={showDetails}
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
      <ExpandableSection
        toggleText={showSmartProxies ? 'Hide smart proxies' : 'Show smart proxies'}
        onToggle={(expanded) => {
          setShowDetails(false);
          setShowSmartProxies(expanded);
          setShowProducts(false);
          setShowUrlPaths(false);
          setShowCredentials(false);
        }}
        isExpanded={showSmartProxies}
      >
        <List className="margin-0-24" isPlain>
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
      {acsType === 'simplified' &&
      <ExpandableSection
        toggleText={showProducts ? 'Hide products' : 'Show products'}
        onToggle={(expanded) => {
          setShowDetails(false);
          setShowSmartProxies(false);
          setShowProducts(expanded);
          setShowUrlPaths(false);
          setShowCredentials(false);
        }}
        isExpanded={showProducts}
      >
        <List className="margin-0-24" isPlain>
          {products.map(product =>
            (
              <ListItem key={product?.id} aria-label="product_value">
                <a href={urlBuilder(`products/${product?.id}`, '')}><b>{product?.name}</b></a>
              </ListItem>
            ))}
        </List>
      </ExpandableSection>
            }
      {acsType === 'custom' &&
      <>
        <ExpandableSection
          toggleText={showUrlPaths ? 'Hide URL and subpaths' : 'Show URL and subpaths'}
          onToggle={(expanded) => {
            setShowDetails(false);
            setShowSmartProxies(false);
            setShowUrlPaths(expanded);
            setShowCredentials(false);
          }}
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
        <ExpandableSection
          toggleText={showCredentials ? 'Hide credentials' : 'Show credentials'}
          onToggle={(expanded) => {
            setShowDetails(false);
            setShowSmartProxies(false);
            setShowUrlPaths(false);
            setShowCredentials(expanded);
          }}
          isExpanded={showCredentials}
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
      </>
            }
    </>
  );
};

export default ACSExpandableDetails;
