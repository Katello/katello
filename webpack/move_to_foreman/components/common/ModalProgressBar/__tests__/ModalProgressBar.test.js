import React from '@theforeman/vendor/react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ModalProgressBar from '../ModalProgressBar';
import { getTaskSuccessResponse } from '../../../../../scenes/Tasks/__tests__/task.fixtures';


describe('ModalProgressBar', () => {
  const props = {
    show: true,
    task: getTaskSuccessResponse,
  };
  const message = 'Proceed with this action?';

  it('renders a modal progress bar', async () => {
    const dialog = shallow(<ModalProgressBar
      {...props}
      {...{ message }}
    />);
    expect(toJson(dialog)).toMatchSnapshot();
  });
});
