/* eslint-disable import/no-extraneous-dependencies */
/* eslint import/no-unresolved: [2, { ignore: [foremanReact/*] }] */
/* eslint-disable import/no-unresolved */
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { loadEnabledRepos } from '../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets, updateRecommendedRepositorySets } from '../../redux/actions/RedHatRepositories/sets';
import RedHatRepositoriesPage from './RedHatRepositoriesPage';
import * as organizationActions from '../Organizations/OrganizationActions';

const mapStateToProps = ({
  katello: {
    redHatRepositories: { enabled, sets },
    organization,
  },
}) => ({
  enabledRepositories: enabled,
  repositorySets: sets,
  organization,
});

// map action dispatchers to props
const actions = {
  ...organizationActions,
  loadEnabledRepos,
  loadRepositorySets,
  updateRecommendedRepositorySets,
};
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export default connect(mapStateToProps, mapDispatchToProps)(RedHatRepositoriesPage);
