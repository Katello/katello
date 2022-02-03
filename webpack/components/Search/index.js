import * as settingActions
  from 'foremanReact/components/Settings/SettingsActions';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import { selectSettings } from '../../scenes/Settings/SettingsSelectors';
import Search from './Search';

const mapStateToProps = state => ({
  settings: selectSettings(state),
});

const thing = () => {
  if (mapStateToProps) {
    return 'stuff';
  }
  return 'not stuff';
};
console.log('🚀 ~ file: index.js ~ line 23 ~ thing', 'you jeremy');


const actions = { ...settingActions };

const mapDispatchToProps = dispatch => bindActionCreators(actions, dispatch);

export default connect(mapStateToProps, mapDispatchToProps)(Search);
