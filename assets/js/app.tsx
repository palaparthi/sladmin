import React from 'react';
import ReactDOM from 'react-dom';
import Hello  from './SlAdmin/hello';

document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('SlAdmin');
    if (!container) return null;
    ReactDOM.render(<Hello />, container);
})