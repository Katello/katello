import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { ListView, Spinner, OverlayTrigger, Tooltip, Icon } from 'patternfly-react';
import { connect } from 'react-redux';

import { setRepositoryEnabled } from '../../../redux/actions/RedHatRepositories/repositorySetRepositories';
import '../index.scss';
import api from '../../../services/api';

class RepositorySetRepository extends Component {
  constructor(props) {
    super(props);

    this.state = { loading: false };

    this.setEnabled = (response) => {
      this.setState({ loading: false });

      const { data: { output: { repository: { id, name, content_type: type } } } } = response;

      const {
        productId, contentId, arch, releasever,
      } = this.props;

      const enabledRepo = {
        productId,
        contentId,
        id,
        name,
        type,
        arch,
        releasever,
      };

      this.props.setRepositoryEnabled(enabledRepo);
    };

    this.enableRepository = () => {
      this.setState({ loading: true });

      const {
        productId, contentId, arch, releasever,
      } = this.props;

      const url = `/products/${productId}/repository_sets/${contentId}/enable`;

      const data = {
        id: contentId,
        product_id: productId,
        basearch: arch,
        releasever: releasever || undefined,
      };

      api
        .put(url, data)
        .then(this.setEnabled)
        .catch(({ response: { data: error } }) => {
          this.setState({ loading: false, error });
        });
    };
  }

  render() {
    const { arch, releasever } = this.props;

    return (
      <ListView.Item
        heading={`${arch} ${releasever}`}
        className="list-item-with-divider"
        leftContent={
          this.state.error ? (
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
          <Spinner loading={this.state.loading} inline>
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
  contentId: PropTypes.string.isRequired,
  productId: PropTypes.number.isRequired,
  arch: PropTypes.string.isRequired,
  releasever: PropTypes.string,
  setRepositoryEnabled: PropTypes.func.isRequired,
};

RepositorySetRepository.defaultProps = {
  releasever: '',
};

export default connect(null, { setRepositoryEnabled })(RepositorySetRepository);
