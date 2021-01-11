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

export const selectLifeCycleEnvironments = state =>
  selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).pluginData?.lifeCycleEnvironments || [];

export const selectHostGroupEnvironment = state =>
    selectAPIResponse(state, REGISTRATION_COMMANDS_DATA).pluginData?.hostGroupEnvironment;

