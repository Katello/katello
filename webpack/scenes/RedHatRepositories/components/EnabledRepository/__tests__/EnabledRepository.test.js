import React from 'react';
import thunk from 'redux-thunk';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import configureMockStore from 'redux-mock-store';
import EnabledRepository from '../EnabledRepository';

const mockStore = configureMockStore([thunk]);
const store = mockStore({});

describe('Enabled Repositories Component', () => {
  let shallowWrapper;
  const mockSetRepositoryDisabled = jest.fn();
  const mockLoadEnabledRepos = jest.fn();
  const mockDisableRepository = jest.fn();
  beforeEach(() => {
    shallowWrapper = shallow(<EnabledRepository
      store={store}
      id={1}
      contentId={1}
      productId={1}
      name="foo"
      orphaned={false}
      type="foo"
      arch="foo"
      releasever="1.1.1"
      label="some label"
      pagination={{}}
      setRepositoryDisabled={mockSetRepositoryDisabled}
      loadEnabledRepos={mockLoadEnabledRepos}
      disableRepository={mockDisableRepository}
    />);
  });

  afterEach(() => {
    store.clearActions();
  });

  it('should render', async () => {
    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });

  describe('class methods', () => {
    let instance;
    beforeEach(() => {
      instance = shallowWrapper.instance();
      mockSetRepositoryDisabled.mockClear();
      mockLoadEnabledRepos.mockClear();
      mockDisableRepository.mockClear();
    });
    it('setDisabled - should call this.props.setRepositoryDisabled', () => {
      instance.setDisabled();
      expect(mockSetRepositoryDisabled).toHaveBeenCalled();
    });
    it('repoForAction - should return expected object', () => {
      const expected = {
        contentId: 1,
        productId: 1,
        name: 'foo',
        type: 'foo',
        arch: 'foo',
        releasever: '1.1.1',
        id: 1,
      };
      expect(instance.repoForAction()).toEqual(expected);
    });
    it('reload - calls this.props.loadEnabledRepos with expected data', () => {
      const expectedData = {
        search: {},
      };
      instance.reload();
      expect(mockLoadEnabledRepos).toHaveBeenCalledWith(expectedData, true);
      // this.props.loadEnabledRepos({
      //   ...this.props.pagination,
      //   search: this.props.search,
      // }, true)
    });
    it('notifyDisabled - uses window.tfm.toastNotifications object to make a toast', () => {
      // setup
      const savedTfm = window.tfm;
      window.tfm = {
        toastNotifications: {
          notify: jest.fn(),
        },
      };
      const expectedData = {
        message: "Repository 'foo' has been disabled.",
        type: 'success',
      };
      instance.notifyDisabled();
      expect(window.tfm.toastNotifications.notify).toHaveBeenCalledWith(expectedData);
      // cleanup
      window.tfm = savedTfm;
    });
    it('reloadAndNotify - calls all 3 async functions', async () => {
      const result = { success: true };
      instance.reload = jest.fn();
      instance.setDisabled = jest.fn();
      instance.notifyDisabled = jest.fn();
      await instance.reloadAndNotify(result);
      expect(instance.reload).toHaveBeenCalled();
      expect(instance.setDisabled).toHaveBeenCalled();
      expect(instance.notifyDisabled).toHaveBeenCalled();
    });
    it('disableRepository - calls both async functions', async () => {
      const repoForAction = {
        contentId: 1,
        productId: 1,
        name: 'foo',
        type: 'foo',
        arch: 'foo',
        releasever: '1.1.1',
        id: 1,
      };
      instance.reloadAndNotify = jest.fn();
      await instance.disableRepository();
      expect(mockDisableRepository).toHaveBeenCalledWith(repoForAction);
      expect(instance.reloadAndNotify).toHaveBeenCalled();
    });
  });
});
