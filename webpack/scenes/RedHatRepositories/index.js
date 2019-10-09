/* eslint-disable import/no-extraneous-dependencies */
/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-unresolved */

import { connect } from 'react-redux';
import { loadEnabledRepos } from '../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets, updateRecommendedRepositorySets } from '../../redux/actions/RedHatRepositories/sets';
import RedHatRepositoriesPage from './RedHatRepositoriesPage';

const mapStateToProps = ({
  katello: {
    redHatRepositories: { enabled, sets },
  },
}) => ({
  enabledRepositories: enabled,
  repositorySets: sets,
});

export default connect(mapStateToProps, {
  loadEnabledRepos,
  loadRepositorySets,
  updateRecommendedRepositorySets,
})(RedHatRepositoriesPage);
