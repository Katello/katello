import componentRegistry from 'foremanReact/components/componentRegistry';
import { mount } from 'foremanReact/common/MountingService';
import ExperimentalUi from './containers/Application/index';

componentRegistry.register({
  name: 'xui_katello',
  type: ExperimentalUi,
});

mount('xui_katello', '#reactRoot');
