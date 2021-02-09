import React from 'react';
import ReactDOM from 'react-dom';
import { ApolloProvider } from '@apollo/client';

import Home from './SlAdmin/home';
import client from './SlAdmin/client';

document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('SlAdmin');
    if (!container) return null;

    const App = () => {
        return (
            <ApolloProvider client={client}>
                <Home />
            </ApolloProvider>
        );
    };
    ReactDOM.render(<App/>, container);
});
