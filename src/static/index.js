'use strict';

require('./index.html');
const {Elm} = require('../elm/Main.elm');

Elm.Main.init({
    node: document.getElementById('main')
});
