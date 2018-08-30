import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { ListView } from 'patternfly-react';
import { connect } from 'react-redux';

import RepositoryTypeIcon from './RepositoryTypeIcon';
import { setRepositoryDisabled } from '../../../redux/actions/RedHatRepositories/enabled';
import api from '../../../services/api';
import { notify } from '../../../move_to_foreman/foreman_toast_notifications';
import { getResponseErrorMsgs } from '../../../move_to_foreman/common/helpers';
import EnabledRepositoryContent from './EnabledRepositoryContent';

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
        .catch(({ response }) => {
          const errors = getResponseErrorMsgs(response);
          errors.forEach((error) => {
            notify({ message: error, type: 'error' });
          });
          this.setState({ loading: false });
        });
    };

    this.disableTooltipId = `disable-${props.id}`;
  }

  render() {
    const {
      arch, name, id, type, releasever, orphaned,
    } = this.props;
    return (
      <ListView.Item
        key={id}
        actions={
          <EnabledRepositoryContent
            loading={this.state.loading}
            disableTooltipId={this.disableTooltipId}
            disableRepository={this.disableRepository}
          />
        }
        leftContent={<RepositoryTypeIcon id={id} type={type} />}
        heading={`${name} ${orphaned ? __('(Orphaned)') : ''}`}
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
  orphaned: PropTypes.bool,
  setRepositoryDisabled: PropTypes.func.isRequired,
};

EnabledRepository.defaultProps = {
  releasever: '',
  orphaned: false,
};

export default connect(null, { setRepositoryDisabled })(EnabledRepository);
