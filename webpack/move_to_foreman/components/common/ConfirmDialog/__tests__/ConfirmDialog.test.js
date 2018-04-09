import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import ConfirmDialog from '../ConfirmDialog';

describe('ConfirmDialog', () => {
  const props = {
    show: true,
    onConfirm: () => {},
    onCancel: () => {},
    title: 'Please Confirm',
  };
  const message = 'Proceed with this action?';

  it('renders a confirm dialog', async () => {
    const dialog = shallow(<ConfirmDialog
      {...props}
      {...{ message }}
    />);
    expect(toJson(dialog)).toMatchSnapshot();
  });

  it('enables to override button labels', async () => {
    const dialog = shallow(<ConfirmDialog
      {...props}
      {...{ message }}
      confirmLabel="Custom confirm"
      cancelLabel="Custom cancel"
    />);
    expect(toJson(dialog)).toMatchSnapshot();
  });

  it('enables to set inner html', async () => {
    const dialog = shallow(<ConfirmDialog
      {...props}
      dangerouslySetInnerHTML={{ _html: '<b>Custom</b> html content' }}
    />);
    expect(toJson(dialog)).toMatchSnapshot();
  });
});
