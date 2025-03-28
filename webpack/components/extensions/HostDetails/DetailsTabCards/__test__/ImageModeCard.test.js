import React from 'react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import { CardExpansionContext } from 'foremanReact/components/HostDetails/CardExpansionContext';
import ImageModeCard from '../ImageModeCard';

const hostDetails = {
  name: 'test-host',
  content_facet_attributes: {
    bootc_booted_image: 'quay.io/centos-bootc/centos-bootc:42',
    bootc_booted_digest: 'sha256:18ec8a272258b22bf9707b1963d72b8987110c8965c3d08b496fac0b1fb22159',
    bootc_available_image: '',
    bootc_available_digest: '',
    bootc_staged_image: 'quay.io/fedora/fedora-bootc:40',
    bootc_staged_digest: 'sha256:b2b888aa0a05f3278e4957cb658fd088e3579e214140dc88ca138f47144d6a05',
    bootc_rollback_image: 'quay.io/centos-bootc/centos-bootc:stream9',
    bootc_rollback_digest: 'sha256:893b636bbc5725378ce602f222f26c29f51334f93243ae8657d31391634eb024',
  },
};
const customRender = (ui, { providerProps, ...renderOptions }) => renderWithRedux(
  <CardExpansionContext.Provider value={providerProps}>{ui}</CardExpansionContext.Provider>,
  renderOptions,
);

describe('image mode card', () => {
  test('shows image mode details when expanded', () => {
    const providerProps = {
      cardExpandStates: { 'image-mode': true },
      dispatch: () => {},
      registerCard: () => {},
    };
    const { getByText }
      = customRender(<ImageModeCard hostDetails={hostDetails} />, { providerProps });

    expect(getByText('Image mode details')).toBeInTheDocument();

    const rexLink = getByText('Modify via remote execution');
    expect(rexLink).toBeInTheDocument();
    expect(rexLink).toHaveAttribute(
      'href',
      '/job_invocations/new?feature=katello_bootc_action&search=name%20%5E%20(test-host)',
    );

    expect(getByText('Running image')).toBeInTheDocument();
    expect(getByText('Running image digest')).toBeInTheDocument();
    expect(getByText('Staged image')).toBeInTheDocument();
    expect(getByText('Staged image digest')).toBeInTheDocument();
    expect(getByText('Available image')).toBeInTheDocument();
    expect(getByText('Available image digest')).toBeInTheDocument();
    expect(getByText('Rollback image')).toBeInTheDocument();
    expect(getByText('Rollback image digest')).toBeInTheDocument();

    expect(getByText('quay.io/centos-bootc/centos-bootc:42')).toBeInTheDocument();
    expect(getByText('sha256:18ec8a272258b22bf9707b1963d72b8987110c8965c3d08b496fac0b1fb22159')).toBeInTheDocument();
    expect(getByText('quay.io/fedora/fedora-bootc:40')).toBeInTheDocument();
    expect(getByText('sha256:b2b888aa0a05f3278e4957cb658fd088e3579e214140dc88ca138f47144d6a05')).toBeInTheDocument();
    expect(getByText('quay.io/centos-bootc/centos-bootc:stream9')).toBeInTheDocument();
    expect(getByText('sha256:893b636bbc5725378ce602f222f26c29f51334f93243ae8657d31391634eb024')).toBeInTheDocument();
  });

  test('does not show details when not expanded', () => {
    const providerProps = {
      cardExpandStates: { 'image-mode': false },
      dispatch: () => {},
      registerCard: () => {},
    };
    const { queryByText, getByText }
      = customRender(<ImageModeCard hostDetails={hostDetails} />, { providerProps });

    expect(getByText('Image mode details')).toBeInTheDocument();
    const element = queryByText((_, e) => e.textContent === 'Running image');
    expect(element).not.toBeInTheDocument();
  });
});
