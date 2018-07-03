import React from 'react';
import { shallow } from 'enzyme';
import OrganizationCheck from '../../OrganizationCheck';

describe('Organization check page', () => {
  /* eslint-disable react/jsx-closing-tag-location */
  it('should render when passed hide and contain appropiate message', async () => {
    const wrapper = shallow(<OrganizationCheck
      hide
    >
      <div>hi</div>
    </OrganizationCheck>);
    expect(wrapper.find('h2').text()).toEqual('No organization selected');
  });

  it('should render children when not passed hide prop', async () => {
    const content = 'some awesome organization-dependent content';
    const wrapper = shallow(<OrganizationCheck>
      <h1>{content}</h1>
    </OrganizationCheck>);
    expect(wrapper.find('h1').text()).toEqual(content);
  });
  /* eslint-enable react/jsx-closing-tag-location */
});
