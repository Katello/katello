import { bindActionCreators } from 'redux';

import { connect } from 'react-redux';
import { selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import * as manifestActions from './ManifestActions';
import * as organizationActions from '../../Organizations/OrganizationActions';
import * as contentCredentialActions from '../../ContentCredentials/ContentCredentialActions';
import * as tasksActions from '../../Tasks/TaskActions';
import history from './ManifestHistoryReducer';
import {
  selectIsManifestImported,
  selectUpdatingCdnConfiguration,
} from '../../Organizations/OrganizationSelectors';
import { selectContentCredentials } from '../../ContentCredentials/ContentCredentialSelectors';
import {
  UPLOAD_MANIFEST_KEY,
  REFRESH_MANIFEST_KEY,
  DELETE_MANIFEST_KEY,
} from './ManifestConstants';

import ManifestModal from './ManageManifestModal';

const selectManifestActionStarted = (state) => {
  const statuses = [
    selectAPIStatus(state, UPLOAD_MANIFEST_KEY),
    selectAPIStatus(state, REFRESH_MANIFEST_KEY),
    selectAPIStatus(state, DELETE_MANIFEST_KEY),
  ];
  return statuses.includes(STATUS.PENDING);
};

// map state to props
const mapStateToProps = state => ({
  organization: state.katello.organization,
  manifestHistory: state.katello.manifestHistory,
  isManifestImported: selectIsManifestImported(state),
  manifestActionStarted: selectManifestActionStarted(state),
  updatingCdnConfiguration: selectUpdatingCdnConfiguration(state),
  contentCredentials: selectContentCredentials(state),
});

// map action dispatchers to props
const actions = {
  ...manifestActions,
  ...organizationActions,
  ...tasksActions,
  ...contentCredentialActions,
};
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const manifestHistory = history;

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(ManifestModal);
