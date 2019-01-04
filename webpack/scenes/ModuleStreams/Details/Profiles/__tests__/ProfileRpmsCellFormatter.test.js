import React from '@theforeman/vendor/react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ProfileRpmCellFormatter from '../ProfileRpmsCellFormatter';
import { details } from '../../__tests__/moduleStreamDetails.fixtures';

jest.mock('../../../../../move_to_foreman/foreman_toast_notifications');

describe('ProfileRpmCellFormatter', () => {
  it('should render and expand on click', () => {
    //  eslint-disable-next-line prefer-destructuring
    const rpms = details.profiles[0].rpms;
    const wrapper = shallow(<ProfileRpmCellFormatter
      rpms={rpms}
    />);

    expect(toJson(wrapper)).toMatchSnapshot();
    expect(wrapper.state('expanded')).toBeFalsy();
    expect(wrapper.state('showAmount')).toBe(10);
    wrapper.instance().onClick();
    expect(wrapper.state('expanded')).toBeTruthy();
    expect(wrapper.state('showAmount')).toBe(rpms.length);
  });
});
