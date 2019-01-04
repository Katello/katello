import { connect } from '@theforeman/vendor/react-redux';
import { setRepositoryDisabled, loadEnabledRepos, disableRepository } from '../../../../redux/actions/RedHatRepositories/enabled';
import EnabledRepository from './EnabledRepository';

const mapStateToProps = (
  { katello: { redHatRepositories: { enabled: { pagination, search } } } },
  props,
) => ({
  ...props,
  pagination,
  search,
});

export default connect(
  mapStateToProps,
  { setRepositoryDisabled, loadEnabledRepos, disableRepository },
)(EnabledRepository);
