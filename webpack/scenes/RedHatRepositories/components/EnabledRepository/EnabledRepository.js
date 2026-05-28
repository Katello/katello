import React, { useCallback } from 'react';
import PropTypes from 'prop-types';
import {
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
  DataListAction,
} from '@patternfly/react-core';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

import RepositoryTypeIcon from '../RepositoryTypeIcon';
import EnabledRepositoryContent from './EnabledRepositoryContent';

const EnabledRepository = ({
  id,
  contentId,
  productId,
  label,
  name,
  type,
  arch,
  releasever,
  orphaned,
  canDisable,
  loading,
  search,
  pagination,
  setRepositoryDisabled,
  loadEnabledRepos,
  disableRepository,
}) => {
  const repoForAction = useCallback(() => ({
    id,
    contentId,
    productId,
    name,
    type,
    arch,
    releasever,
  }), [id, contentId, productId, name, type, arch, releasever]);

  const reload = useCallback(() => (
    loadEnabledRepos({
      ...pagination,
      search,
    }, true)
  ), [loadEnabledRepos, pagination, search]);

  const notifyDisabled = useCallback(() => {
    window.tfm.toastNotifications.notify({
      message: sprintf(__("Repository '%(repoName)s' has been disabled."), { repoName: name }),
      type: 'success',
    });
  }, [name]);

  const reloadAndNotify = useCallback(async (result) => {
    if (result && result.success) {
      await reload();
      await setRepositoryDisabled(repoForAction());
      await notifyDisabled();
    }
  }, [reload, setRepositoryDisabled, repoForAction, notifyDisabled]);

  const handleDisableRepository = useCallback(async () => {
    const result = await disableRepository(repoForAction());
    await reloadAndNotify(result);
  }, [disableRepository, repoForAction, reloadAndNotify]);

  const heading = `${name} ${orphaned ? __('(Orphaned)') : ''}`;

  return (
    <DataListItem key={id} aria-labelledby={`enabled-repo-${id}`}>
      <DataListItemRow className="repository-item-row">
        <DataListItemCells
          dataListCells={[
            <DataListCell key="icon" className="repository-cell-icon">
              <div className="repository-icon-badge repository-icon-badge-green">
                <RepositoryTypeIcon type={type} />
              </div>
            </DataListCell>,
            <DataListCell key="content" className="repository-cell-content">
              <div id={`enabled-repo-${id}`} className="repository-name">
                {heading}
              </div>
              <div className="repository-label">{label}</div>
            </DataListCell>,
          ]}
        />
        <DataListAction>
          <EnabledRepositoryContent
            loading={loading}
            disableRepository={handleDisableRepository}
            canDisable={canDisable}
          />
        </DataListAction>
      </DataListItemRow>
    </DataListItem>
  );
};

EnabledRepository.propTypes = {
  id: PropTypes.number.isRequired,
  contentId: PropTypes.number.isRequired,
  productId: PropTypes.number.isRequired,
  label: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  arch: PropTypes.string.isRequired,
  search: PropTypes.shape({
    query: PropTypes.string,
    searchList: PropTypes.string,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    filters: PropTypes.array,
  }),
  pagination: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
  }).isRequired,
  loading: PropTypes.bool,
  releasever: PropTypes.string,
  orphaned: PropTypes.bool,
  canDisable: PropTypes.bool,
  setRepositoryDisabled: PropTypes.func.isRequired,
  loadEnabledRepos: PropTypes.func.isRequired,
  disableRepository: PropTypes.func.isRequired,
};

EnabledRepository.defaultProps = {
  releasever: '',
  orphaned: false,
  search: {},
  loading: false,
  canDisable: true,
};

export default EnabledRepository;
