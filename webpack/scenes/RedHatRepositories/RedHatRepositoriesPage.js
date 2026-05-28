/* eslint-disable import/no-extraneous-dependencies */
/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-unresolved */

import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { isEmpty } from 'lodash';
import { Grid, GridItem, Skeleton, Alert, Button, Popover } from '@patternfly/react-core';
import { InfoCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import PermissionDenied from 'foremanReact/components/PermissionDenied';
import { LoadingState } from '../../components/LoadingState';
import { createEnabledRepoParams } from '../../redux/actions/RedHatRepositories/enabled';
import SearchBar from './components/SearchBar';
import RecommendedRepositorySetsToggler from './components/RecommendedRepositorySetsToggler';
import { getSetsComponent, getEnabledComponent } from './helpers';
import api from '../../services/api';
import { EXPORT_SYNC } from '../Subscriptions/Manifest/CdnConfigurationTab/CdnConfigurationConstants';

const RedHatRepositoriesPage = ({
  loadOrganization,
  loadEnabledRepos,
  loadRepositorySets,
  updateRecommendedRepositorySets,
  enabledRepositories,
  repositorySets,
  organization,
}) => {
  useEffect(() => {
    loadOrganization();
    loadEnabledRepos();
    loadRepositorySets({ search: { filters: ['rpm'] } });
  }, [loadOrganization, loadEnabledRepos, loadRepositorySets]);

  const { repoParams } = createEnabledRepoParams(enabledRepositories);

  if (!isEmpty(repositorySets.missingPermissions)) {
    return <PermissionDenied missingPermissions={repositorySets.missingPermissions} />;
  }
  if (!isEmpty(enabledRepositories.missingPermissions)) {
    return <PermissionDenied missingPermissions={enabledRepositories.missingPermissions} />;
  }
  if (!(organization?.cdn_configuration)) {
    return <Skeleton />;
  }
  if (organization.cdn_configuration.type === EXPORT_SYNC) {
    return (
      <div id="redhatRepositoriesPage">
        <h1>{__('Red Hat Repositories')}</h1>
        <Grid hasGutter>
          <GridItem span={12}>
            <Alert
              ouiaId="repo-sets-alert"
              variant="info"
              className="repo-sets-alert"
              isInline
              title={__('CDN configuration is set to Export Sync (disconnected). Repository enablement/disablement is not permitted on this page.')}
            />
          </GridItem>
        </Grid>
      </div>
    );
  }

  return (
    <div id="redhatRepositoriesPage">
      <h1>{__('Red Hat Repositories')}</h1>
      <Grid hasGutter>
        <GridItem md={6}>
          <SearchBar />
        </GridItem>
      </Grid>

      <Grid>
        <GridItem md={6} className="available-repositories-container">
          <div className="available-repositories-header">
            <h2>{__('Available Repositories')}</h2>
            <RecommendedRepositorySetsToggler
              enabled={repositorySets.recommended}
              onChange={value => updateRecommendedRepositorySets(value)}
              className="recommended-repositories-toggler"
            />
          </div>
          <LoadingState loading={repositorySets.loading} loadingText={__('Loading')}>
            {getSetsComponent(
              repositorySets,
              (pagination) => {
                loadRepositorySets({
                  ...pagination,
                  search: repositorySets.search,
                });
              },
            )}
          </LoadingState>
        </GridItem>

        <GridItem md={6} className="enabled-repositories-container">
          <div className="enabled-repositories-header">
            <h2>
              {__('Enabled Repositories')}
              <Popover bodyContent={__('Only repositories not published in a content view can be disabled. Published repositories must be deleted from the repository details page.')}>
                <Button
                  variant="plain"
                  aria-label={__('Help')}
                  ouiaId="enabled-repos-help-button"
                  className="help-button-plain"
                >
                  <InfoCircleIcon />
                </Button>
              </Popover>
              <Button
                ouiaId="export-csv-button"
                variant="tertiary"
                size="sm"
                onClick={() => { api.open('/repositories.csv', repoParams); }}
                className="export-csv-button"
              >
                {__('Export as CSV')}
              </Button>
            </h2>
          </div>

          <LoadingState loading={enabledRepositories.loading} loadingText={__('Loading')}>
            {getEnabledComponent(
              enabledRepositories,
              (pagination) => {
                loadEnabledRepos({
                  ...pagination,
                  search: enabledRepositories.search,
                });
              },
            )}
          </LoadingState>
        </GridItem>
      </Grid>
    </div>
  );
};

RedHatRepositoriesPage.propTypes = {
  loadOrganization: PropTypes.func.isRequired,
  loadEnabledRepos: PropTypes.func.isRequired,
  loadRepositorySets: PropTypes.func.isRequired,
  updateRecommendedRepositorySets: PropTypes.func.isRequired,
  enabledRepositories: PropTypes.shape({
    loading: PropTypes.bool,
    search: PropTypes.shape({}),
    missingPermissions: PropTypes.arrayOf(PropTypes.string),
  }).isRequired,
  repositorySets: PropTypes.shape({
    recommended: PropTypes.bool,
    loading: PropTypes.bool,
    search: PropTypes.shape({}),
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    missingPermissions: PropTypes.array,
  }).isRequired,
  organization: PropTypes.shape({
    cdn_configuration: PropTypes.shape({
      type: PropTypes.string,
    }),
  }).isRequired,

};

export default RedHatRepositoriesPage;
