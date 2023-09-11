import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import EnabledRepositoryContent from '../EnabledRepositoryContent';

describe('Enabled Repositories Content Component', () => {
  const mockCallBack = jest.fn();

  let shallowWrapper;
  beforeEach(() => {
    shallowWrapper = shallow(<EnabledRepositoryContent
      loading
      disableTooltipId="disable-1"
      disableRepository={mockCallBack}
      canDisable={false}
    />);
  });

  it('should render', async () => {
    expect(toJson(shallowWrapper)).toMatchSnapshot();
  });

  it('should run disableRepository on click', async () => {
    expect(mockCallBack).not.toHaveBeenCalled();
    shallowWrapper.find('button').at(0).simulate('click');
    expect(mockCallBack).toHaveBeenCalled();
  });
});
