import { combineReducers } from 'redux';

const orgId = () => ({
  id: document.getElementById('organization-id').dataset.id,
});

export default combineReducers({
  orgId,
});
