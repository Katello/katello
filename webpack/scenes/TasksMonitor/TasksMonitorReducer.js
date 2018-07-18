import Immutable from 'seamless-immutable';
import {
  TASKS_MONITOR_STARTED,
  TASKS_MONITOR_STOPPED,
  TASKS_MONITOR_SUCCESS,
  TASKS_MONITOR_FAILED,
} from './TasksMonitorConstants';

const initialState = Immutable({ });

export default (state = initialState, action) => {
  switch (action.type) {
    case TASKS_MONITOR_STARTED:
      return state.setIn([action.payload.id], {
        interval: action.payload.interval,
        intervalId: action.payload.intervalId,
        params: action.payload.params,
        tasks: [],
      });
    case TASKS_MONITOR_STOPPED:
      return state.setIn([action.payload.id, 'intervalId'], null);

    case TASKS_MONITOR_SUCCESS:
      return state
        .setIn([action.payload.id, 'tasks'], action.payload.tasks)
        .setIn([action.payload.id, 'error'], null);

    case TASKS_MONITOR_FAILED:
      return state.setIn([action.payload.id, 'error'], action.payload.error);

    default:
      return state;
  }
};
