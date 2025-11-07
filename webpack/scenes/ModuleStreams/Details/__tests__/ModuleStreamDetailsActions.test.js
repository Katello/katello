import api from '../../../../services/api';
import { apiError } from '../../../../utils/helpers';
import { loadModuleStreamDetails } from '../ModuleStreamDetailsActions';
import {
  MODULE_STREAM_DETAILS_REQUEST,
  MODULE_STREAM_DETAILS_SUCCESS,
  MODULE_STREAM_DETAILS_FAILURE,
} from '../ModuleStreamDetailsConstants';
import { details } from './moduleStreamDetails.fixtures';

jest.mock('../../../../services/api');
jest.mock('../../../../utils/helpers');

describe('Module stream details actions', () => {
  const dispatch = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.resetAllMocks();
    jest.restoreAllMocks();
  });

  test('dispatches REQUEST and SUCCESS actions on successful API call', async () => {
    api.get.mockResolvedValue({
      data: details,
    });

    await loadModuleStreamDetails(22)(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: MODULE_STREAM_DETAILS_REQUEST,
    });

    expect(dispatch).toHaveBeenCalledWith({
      type: MODULE_STREAM_DETAILS_SUCCESS,
      response: details,
    });

    expect(api.get).toHaveBeenCalledWith(
      '/module_streams/22',
      {},
      expect.any(Object),
    );

    expect(apiError).not.toHaveBeenCalled();
  });

  test('dispatches REQUEST and FAILURE actions on failed API call', async () => {
    const error = new Error('Network error');
    api.get.mockRejectedValue(error);

    const mockApiErrorReturn = {
      type: MODULE_STREAM_DETAILS_FAILURE,
      payload: error,
    };
    apiError.mockReturnValue(mockApiErrorReturn);

    await loadModuleStreamDetails(22)(dispatch);

    expect(dispatch).toHaveBeenCalledWith({
      type: MODULE_STREAM_DETAILS_REQUEST,
    });

    expect(apiError).toHaveBeenCalledWith(MODULE_STREAM_DETAILS_FAILURE, error);

    expect(dispatch).toHaveBeenCalledWith(mockApiErrorReturn);
  });
});
