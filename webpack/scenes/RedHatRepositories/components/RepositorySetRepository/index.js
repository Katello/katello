import { connect } from 'react-redux';
import { setRepositoryEnabled, enableRepository } from '../../../../redux/actions/RedHatRepositories/repositorySetRepositories';
import { loadEnabledRepos } from '../../../../redux/actions/RedHatRepositories/enabled';
import RepositorySetRepository from './RepositorySetRepository';

const mapStateToProps = (
  { katello: { redHatRepositories: { enabled } } },
  props,
) => ({
  ...props,
  enabledPagination: enabled.pagination,
  enabledSearch: enabled.search,
});

export default connect(
  mapStateToProps,
  { setRepositoryEnabled, loadEnabledRepos, enableRepository },
)(RepositorySetRepository);
