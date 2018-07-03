import React from 'react';
import ReactDOMServer from 'react-dom/server';

const htmlCaret = title => title + ReactDOMServer.renderToStaticMarkup(<span className="caret" />);

export default htmlCaret;
