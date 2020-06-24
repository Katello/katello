import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as settingActions from 'foremanReact/components/Settings/SettingsActions';
import { selectSettings } from '../../scenes/Settings/SettingsSelectors';
import Search from './Search';

const mapStateToProps = state => ({
  settings: selectSettings(state),
});

const actions = { ...settingActions };

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export default connect(mapStateToProps, mapDispatchToProps)(Search);
