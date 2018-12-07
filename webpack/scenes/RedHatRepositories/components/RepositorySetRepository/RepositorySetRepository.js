import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { ListView, Spinner, OverlayTrigger, Tooltip, Icon, FieldLevelHelp } from 'patternfly-react';

import { sprintf } from 'foremanReact/common/I18n';
import { yStream } from '../RepositorySetRepositoriesHelpers';
import { notify } from '../../../../move_to_foreman/foreman_toast_notifications';
import '../../index.scss';

class RepositorySetRepository extends Component {
  constructor(props) {
    super(props);

    this.state = {};

    this.repoForAction = () => {
      const {
        productId, contentId, arch, releasever, label,
      } = this.props;

      return {
        productId,
        contentId,
        arch,
        releasever,
        label,
      };
    };

    this.setEnabled = () => {
      this.props.setRepositoryEnabled(this.repoForAction());
    };

    this.reloadEnabledRepos = () => (
      this.props.loadEnabledRepos({
        ...this.props.enabledPagination,
        search: this.props.enabledSearch,
      }, true)
    );

    this.notifyEnabled = (data) => {
      const repoName = data.output.repository.name;
      notify({
        message: sprintf(__("Repository '%(repoName)s' has been enabled."), { repoName }),
        type: 'success',
      });
    };

    this.reloadAndNotify = (result) => {
      if (result.success) {
        this.reloadEnabledRepos()
          .then(this.setEnabled)
          .then(() => this.notifyEnabled(result.data));
      }
    };

    this.enableRepository = () => {
      this.props.enableRepository(this.repoForAction())
        .then(this.reloadAndNotify);
    };
  }

  render() {
    const { arch, releasever, type } = this.props;

    const archLabel = arch || __('Default');
    const releaseverLabel = releasever || '';

    const yStreamHelpText =
      sprintf(
        __('This repository is not suggested. Please see additional %(anchorBegin)sdocumentation%(anchorEnd)s prior to use.'),
        {
          anchorBegin: '<a href="https://access.redhat.com/articles/1586183">',
          anchorEnd: '</a>',
        },
      );
    // eslint-disable-next-line react/no-danger
    const yStreamHelp = <span dangerouslySetInnerHTML={{ __html: yStreamHelpText }} />;
    const shouldDeemphasize = () => type !== 'kickstart' && yStream(releaseverLabel);
    const repositoryHeading = () => (
      <span>
        {archLabel} {releaseverLabel}
        {shouldDeemphasize() ? (<FieldLevelHelp content={yStreamHelp} />) : null}
      </span>
    );

    return (
      <ListView.Item
        heading={repositoryHeading()}
        className={`list-item-with-divider ${shouldDeemphasize() ? 'deemphasize' : ''}`}
        leftContent={
          this.props.error ? (
            <div className="list-error-danger">
              <Icon name="times-circle-o" />
            </div>
          ) : null
        }
        additionalInfo={
          this.state.error
            ? [
              <ListView.InfoItem key="error" stacked className="list-error-danger">
                {this.state.error.displayMessage}
              </ListView.InfoItem>,
              ]
            : null
        }
        actions={
          <Spinner loading={this.props.loading} inline>
            <OverlayTrigger
              overlay={<Tooltip id="enable">Enable</Tooltip>}
              placement="bottom"
              trigger={['hover', 'focus']}
              rootClose={false}
            >
              <button
                onClick={this.enableRepository}
                style={{
                  backgroundColor: 'initial',
                  border: 'none',
                  color: '#0388ce',
                }}
              >
                <i className={cx('fa-2x', 'fa fa-plus-circle')} />
              </button>
            </OverlayTrigger>
          </Spinner>
        }
        stacked
      />
    );
  }
}

RepositorySetRepository.propTypes = {
  contentId: PropTypes.number.isRequired,
  productId: PropTypes.number.isRequired,
  arch: PropTypes.string,
  releasever: PropTypes.string,
  type: PropTypes.string,
  label: PropTypes.string,
  enabledSearch: PropTypes.shape({
    query: PropTypes.string,
    searchList: PropTypes.string,
    filters: PropTypes.array,
  }),
  enabledPagination: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
  }).isRequired,
  loading: PropTypes.bool,
  error: PropTypes.bool,
  setRepositoryEnabled: PropTypes.func.isRequired,
  loadEnabledRepos: PropTypes.func.isRequired,
  enableRepository: PropTypes.func.isRequired,
};

RepositorySetRepository.defaultProps = {
  type: '',
  label: '',
  releasever: undefined,
  arch: undefined,
  enabledSearch: {},
  loading: false,
  error: false,
};

export default RepositorySetRepository;
