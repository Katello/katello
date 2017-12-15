import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import axios from 'axios';
import { ListView, Spinner, OverlayTrigger, Tooltip } from 'patternfly-react';
import { connect } from 'react-redux';

import { setRepositoryEnabled } from '../../../redux/actions/RedHatRepositories/repositorySetRepositories';

class RepositorySetRepository extends Component {
  constructor(props) {
    super(props);

    this.state = { loading: false };

    this.setEnabled = (response) => {
      this.setState({ loading: false });

      const { data: { output: { id, name, content_type } } } = response;
      const {
        productId, contentId, arch, releasever,
      } = this.props;

      const enabledRepo = {
        productId,
        contentId,
        id,
        name,
        type: content_type,
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

      const url = `/katello/api/v2/products/${productId}/repository_sets/${contentId}/enable`;

      const data = {
        id: contentId,
        product_id: productId,
        basearch: arch,
        releasever,
      };

      axios
        .put(url, { data })
        .then(this.setEnabled)
        .catch(() => {
          this.setState({ loading: false });
          // TODO: Add error component
        });
    };
  }

  render() {
    const { enabled, arch, releasever } = this.props;

    if (enabled) return null;

    return (
      <ListView.Item
        heading={`${arch} ${releasever}`}
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
  releasever: PropTypes.string.isRequired,
  enabled: PropTypes.bool.isRequired,
  setRepositoryEnabled: PropTypes.func.isRequired,
};

export default connect(null, { setRepositoryEnabled })(RepositorySetRepository);
