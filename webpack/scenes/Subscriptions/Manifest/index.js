import { bindActionCreators, combineReducers } from 'redux';

import { connect } from 'react-redux';

import * as manifestActions from './ManifestActions';
import * as organizationActions from '../../Organizations/OrganizationActions';

import history from './ManifestHistoryReducer';
import task from './ManifestReducer';

import ManifestModal from './ManageManifestModal';

import './Manifest.scss';

// map state to props
const mapStateToProps = state => ({
  organization: state.katello.organization,
  manifestHistory: state.katello.manifest.history,
  task: state.katello.manifest.task,
});

// map action dispatchers to props
const actions = { ...manifestActions, ...organizationActions };
const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

// export reducers
export const manifest = combineReducers({ history, task });

// export connected component
export default connect(mapStateToProps, mapDispatchToProps)(ManifestModal);
