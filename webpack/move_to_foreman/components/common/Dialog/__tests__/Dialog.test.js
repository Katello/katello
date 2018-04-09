import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { Button } from 'patternfly-react';
import Dialog from '../Dialog';

describe('Dialog', () => {
  const props = {
    show: true,
    onCancel: () => {},
    title: 'Message dialog',
  };
  const message = 'Some important message';

  it('renders a message dialog', async () => {
    const dialog = shallow(<Dialog
      {...props}
      {...{ message }}
    />);
    expect(toJson(dialog)).toMatchSnapshot();
  });

  it('enables to override cancel button label', async () => {
    const dialog = shallow(<Dialog
      {...props}
      {...{ message }}
      cancelLabel="Custom cancel"
    />);
    expect(toJson(dialog)).toMatchSnapshot();
  });

  it('enables to set inner html', async () => {
    const dialog = shallow(<Dialog
      {...props}
      dangerouslySetInnerHTML={{ _html: '<b>Custom</b> html content' }}
    />);
    expect(toJson(dialog)).toMatchSnapshot();
  });

  it("passes onCancel to the default OK button's onClick", () => {
    const onCancel = jest.fn();
    const dialog = shallow(<Dialog
      {...props}
      {...{ onCancel }}
    />);
    expect(dialog.find('ModalFooter > Button[bsStyle="default"]').props().onClick).toBe(onCancel);
    expect(dialog.find('ModalHeader > Button').props().onClick).toBe(onCancel);
  });

  it('enables to define custom buttons', async () => {
    const dialog = shallow(<Dialog
      {...props}
      buttons={[
        <Button key="btn1">Button 1</Button>,
        <Button key="btn2">Button 2</Button>,
        <Button key="btn3">Button 3</Button>,
      ]}
    />);
    expect(toJson(dialog)).toMatchSnapshot();
  });
});
