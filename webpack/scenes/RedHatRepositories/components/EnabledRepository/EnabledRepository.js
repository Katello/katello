import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { ListView } from 'patternfly-react';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

import RepositoryTypeIcon from '../RepositoryTypeIcon';

import EnabledRepositoryContent from './EnabledRepositoryContent';

class EnabledRepository extends Component {
  constructor(props) {
    super(props);

    this.repoForAction = () => {
      const {
        productId, contentId, arch, releasever, name, type,
      } = this.props;

      return {
        contentId,
        productId,
        name,
        type,
        arch,
        releasever,
      };
    };

    this.setDisabled = () => {
      this.props.setRepositoryDisabled(this.repoForAction());
    };

    this.reload = () => (
      this.props.loadEnabledRepos({
        ...this.props.pagination,
        search: this.props.search,
      }, true)
    );

    this.notifyDisabled = () => {
      window.tfm.toastNotifications.notify({
        message: sprintf(__("Repository '%(repoName)s' has been disabled."), { repoName: this.props.name }),
        type: 'success',
      });
    };

    this.reloadAndNotify = (result) => {
      if (result.success) {
        this.reload()
          .then(this.setDisabled)
          .then(this.notifyDisabled);
      }
    };

    this.disableRepository = () => {
      this.props.disableRepository(this.repoForAction())
        .then(this.reloadAndNotify);
    };

    this.disableTooltipId = `disable-${props.id}`;
  }

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
    filters: PropTypes.array,
  }),
  pagination: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
  }),
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
  pagination: PropTypes.shape({
    page: 0,
    perPage: 0,
  }),
};

export default EnabledRepository;
