import React, { Component } from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import { ListView, Spinner, OverlayTrigger, Tooltip } from 'patternfly-react';
import { connect } from 'react-redux';

import RepositoryTypeIcon from './RepositoryTypeIcon';
import { setRepositoryDisabled } from '../../../redux/actions/RedHatRepositories/enabled';
import api from '../../../services/api';

class EnabledRepository extends Component {
  constructor(props) {
    super(props);

    this.state = { loading: false };
    this.setDisabled = () => {
      const {
        productId, contentId, arch, releasever, name, type,
      } = this.props;

      const disabledRepo = {
        contentId,
        productId,
        name,
        type,
        arch,
        releasever,
      };

      this.props.setRepositoryDisabled(disabledRepo);
    };

    this.disableRepository = () => {
      this.setState({ loading: true });

      const {
        productId, contentId, arch, releasever,
      } = this.props;

      const url = `/products/${productId}/repository_sets/${contentId}/disable`;

      const data = {
        id: contentId,
        product_id: productId,
        basearch: arch,
        releasever,
      };

      api
        .put(url, data)
        .then(this.setDisabled)
        .catch(() => {
          this.setState({ loading: false });
          // TODO: Add error component
        });
    };

    this.disableTooltipId = `disable-${props.id}`;
  }

  render() {
    const {
      arch, name, id, type, releasever,
    } = this.props;

    return (
      <ListView.Item
        key={id}
        actions={
          <Spinner loading={this.state.loading} inline>
            <OverlayTrigger
              overlay={<Tooltip id={this.disableTooltipId}>{__('Disable')}</Tooltip>}
              placement="bottom"
              trigger={['hover', 'focus']}
              rootClose={false}
            >
              <button
                onClick={this.disableRepository}
                style={{
                  backgroundColor: 'initial',
                  border: 'none',
                  color: '#0388ce',
                }}
              >
                <i className={cx('fa-2x', 'fa fa-minus-circle')} />
              </button>
            </OverlayTrigger>
          </Spinner>
        }
        leftContent={<RepositoryTypeIcon id={id} type={type} />}
        heading={name}
        description={`${arch} ${releasever || ''}`}
        stacked
      />
    );
  }
}

EnabledRepository.propTypes = {
  id: PropTypes.number.isRequired,
  contentId: PropTypes.number.isRequired,
  productId: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  arch: PropTypes.string.isRequired,
  releasever: PropTypes.string,
  setRepositoryDisabled: PropTypes.func.isRequired,
};

EnabledRepository.defaultProps = {
  releasever: '',
};

export default connect(null, { setRepositoryDisabled })(EnabledRepository);
