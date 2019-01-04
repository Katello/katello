import Immutable from '@theforeman/vendor/seamless-immutable';
import { initialApiState } from '../../../services/api';
import { toastErrorAction, failureAction } from '../../../services/api/testHelpers';

export const initialState = initialApiState;

export const loadingState = Immutable({
  ...initialState,
  loading: true,
});

export const results = [
  {
    id: 39,
    name: 'ant',
    uuid: 'db1d7b30-3db3-49c9-a141-1276dc0f8bb3',
    version: '20180629154141',
    context: '819b5873',
    stream: '1.10',
    arch: 'x86_64',
    description: 'Apache Ant is a Java library and command-line tool whose mission is to drive processes described in build files as targets and extension points dependent upon each other. The main known usage of Ant is the build of Java applications. Ant supplies a number of built-in tasks allowing to compile, assemble, test and run Java applications. Ant can also be used effectively to build non Java applications, for instance C or C++ applications. More generally, Ant can be used to pilot any type of process which can be described in terms of targets and tasks.',
    summary: 'Java build tool',
    repositories: [
      {
        id: 9,
        name: 'rawhide modularity repo',
      },
    ],
  },
  {
    id: 31,
    name: 'avocado',
    uuid: '9e6a0c79-f838-40cf-b6c0-729f4ce23669',
    version: '20180726175620',
    context: '6c81f848',
    stream: 'latest',
    arch: 'x86_64',
    description: 'Avocado is a set of tools and libraries (what people call these days a framework) to perform automated testing.',
    summary: 'Framework with tools and libraries for Automated Testing',
    repositories: [
      {
        id: 9,
        name: 'rawhide modularity repo',
      },
    ],
  },
];

export const successState = {
  itemCount: NaN,
  loading: false,
  pagination: { page: NaN, perPage: 20 },
  results,
};

export const moduleStreamsFailureActions = [
  {
    type: 'MODULE_STREAMS_REQUEST',
  },
  failureAction('MODULE_STREAMS_FAILURE', 'Request failed with status code 500'),
  toastErrorAction('Request failed with status code 500'),
];

export const moduleStreamsSuccessActions = [
  {
    type: 'MODULE_STREAMS_REQUEST',
  },
  {
    type: 'MODULE_STREAMS_SUCCESS',
    response: results,
  },
];
