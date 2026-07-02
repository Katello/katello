import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Tabs, Tab, TabTitleText, Grid, GridItem } from '@patternfly/react-core';
import BreadcrumbsBar from 'foremanReact/components/BreadcrumbBar';
import SubscriptionDetailInfo from './SubscriptionDetailInfo';
import SubscriptionDetailProducts from './SubscriptionDetailProducts';
import SubscriptionDetailProductContent from './SubscriptionDetailProductContent';
import { LoadingState } from '../../../components/LoadingState';
import api, { orgId } from '../../../services/api';

const SubscriptionDetails = ({
  loadSubscriptionDetails,
  loadProducts,
  subscriptionDetails,
  history,
  match,
}) => {
  const routerParams = match.params;

  useEffect(() => {
    loadSubscriptionDetails(parseInt(routerParams.id, 10));
    loadProducts({
      subscription_id: parseInt(routerParams.id, 10),
      include_available_content: true,
      enabled: true,
    });
  }, [routerParams.id, loadSubscriptionDetails, loadProducts]);

  useEffect(() => {
    if (subscriptionDetails.error) {
      window.tfm.toastNotifications.notify({ message: subscriptionDetails.error });
    }
  }, [subscriptionDetails.error]);

  const handleBreadcrumbSwitcherItem = (e, url) => {
    history.push(url);
    e.preventDefault();
  };

  const resource = {
    nameField: 'name',
    resourceUrl: api.getApiUrl(`/organizations/${orgId()}/subscriptions`),
    switcherItemUrl: '/subscriptions/:id',
  };

  return (
    <div id="subscription-details">
      {!subscriptionDetails.loading && <BreadcrumbsBar
        isLoadingResources={subscriptionDetails.loading}
        onSwitcherItemClick={(e, url) => handleBreadcrumbSwitcherItem(e, url)}
        isSwitchable
        breadcrumbItems={[
          {
            caption: __('Subscriptions'),
            url: '/subscriptions/',
          },
          {
            caption: String(subscriptionDetails.name || __('Subscription Details')),
          },
        ]}
        resource={resource}
      />}

      <LoadingState loading={subscriptionDetails.loading} loadingText={__('Loading')}>
        <Tabs defaultActiveKey={0} aria-label="Subscription details tabs" ouiaId="subscription-details-tabs">
          <Tab eventKey={0} title={<TabTitleText>{__('Details')}</TabTitleText>} ouiaId="subscription-details-tab">
            <div className="container-fluid">
              <Grid hasGutter>
                <GridItem span={6}>
                  <SubscriptionDetailInfo
                    subscriptionDetails={subscriptionDetails}
                  />
                </GridItem>
                <GridItem span={6}>
                  <SubscriptionDetailProducts
                    subscriptionDetails={subscriptionDetails}
                  />
                </GridItem>
              </Grid>
            </div>
          </Tab>

          <Tab eventKey={1} title={<TabTitleText>{__('Product Content')}</TabTitleText>} ouiaId="product-content-tab">
            <div className="container-fluid">
              <Grid hasGutter>
                <GridItem span={12}>
                  <SubscriptionDetailProductContent
                    productContent={subscriptionDetails.productContent}
                  />
                </GridItem>
              </Grid>
            </div>
          </Tab>
        </Tabs>
      </LoadingState>
    </div>
  );
};

SubscriptionDetails.propTypes = {
  loadSubscriptionDetails: PropTypes.func.isRequired,
  loadProducts: PropTypes.func.isRequired,
  subscriptionDetails: PropTypes.shape({
    error: PropTypes.shape({}),
    loading: PropTypes.bool,
    name: PropTypes.string,
    productContent: PropTypes.shape({}),
  }).isRequired,
  history: PropTypes.shape({ push: PropTypes.func.isRequired }).isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
};

export default SubscriptionDetails;
