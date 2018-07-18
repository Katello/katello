import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ModalProgressBar from '../ModalProgressBar';
import { task } from '../../../../../scenes/TasksMonitor/__tests__/TasksMonitor.fixtures';


describe('ModalProgressBar', () => {
  const props = {
    show: true,
    task,
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
