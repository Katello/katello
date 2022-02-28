import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { ListView } from 'patternfly-react';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

import RepositoryTypeIcon from '../RepositoryTypeIcon';

import EnabledRepositoryContent from './EnabledRepositoryContent';

class EnabledRepository extends Component {
  constructor(props) {
    super(props);
    this.disableTooltipId = `disable-${props.id}`;
  }

  setDisabled = () => {
    this.props.setRepositoryDisabled(this.repoForAction());
  };

  repoForAction = () => {
    const {
      id, productId, contentId, arch, releasever, name, type,
    } = this.props;

    return {
      id,
      contentId,
      productId,
      name,
      type,
      arch,
      releasever,
    };
  };

  reload = () => (
    this.props.loadEnabledRepos({
      ...this.props.pagination,
      search: this.props.search,
    }, true)
  );

  notifyDisabled = () => {
    window.tfm.toastNotifications.notify({
      message: sprintf(__("Repository '%(repoName)s' has been disabled."), { repoName: this.props.name }),
      type: 'success',
    });
  };

  reloadAndNotify = async (result) => {
    if (result && result.success) {
      await this.reload();
      await this.setDisabled();
      await this.notifyDisabled();
    }
  };

  disableRepository = async () => {
    const result = await this.props.disableRepository(this.repoForAction());
    this.reloadAndNotify(result);
  };

  render() {
    const {
      name, id, type, orphaned, label,
    } = this.props;

    return (
      <ListView.Item
        key={id}
        actions={
          <EnabledRepositoryContent
            loading={this.props.loading}
            disableTooltipId={this.disableTooltipId}
            disableRepository={this.disableRepository}
          />
        }
        leftContent={<RepositoryTypeIcon id={id} type={type} />}
        heading={`${name} ${orphaned ? __('(Orphaned)') : ''}`}
        description={label}
        stacked
      />
    );
  }
}

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
  setRepositoryDisabled: PropTypes.func.isRequired,
  loadEnabledRepos: PropTypes.func.isRequired,
  disableRepository: PropTypes.func.isRequired,
};

EnabledRepository.defaultProps = {
  releasever: '',
  orphaned: false,
  search: {},
  loading: false,
};

export default EnabledRepository;
