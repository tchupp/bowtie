'use strict';

require('./css/main.less');
const {Elm} = require('../elm/Main.elm');

Elm.Main.init({
    node: document.getElementById('main')
});
