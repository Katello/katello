import {
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';

import {
  REGISTRATION_COMMANDS_DATA,
} from './RegistrationCommandsPageConstants';


export const selectActivationKeys = state =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).pluginData?.activationKeys || [];

export const selectHostGroupActivationKeys = state =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).pluginData?.hostGroupActivationKeys;

export const selectLifecycleEnvironments = state =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).pluginData?.lifecycleEnvironments || [];

export const selectHostGroupEnvironment = state =>
    selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).pluginData?.hostGroupEnvironment;

