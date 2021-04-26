
// AMD's define
define(commonJS);

function commonJS(require,exports,module) {

// Define CommonJS module: commonJSCounterModule.js.
//const dependencyModule1 = require("./dependencyModule1");
//const dependencyModule2 = require("./dependencyModule2");

let count = 0;
const increase = () => ++count;
const reset = () => {
    count = 0;
    console.log("Count is reset.");
};
const getValue = () => { return count; };
const setValue = (val) => { count = val; return count; };

exports.increase = increase;
exports.reset = reset;
exports.getValue = getValue;
exports.setValue = setValue;

}

