"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const errors_1 = require("@oclif/errors");
const errors_2 = require("./errors");
function validate(parse) {
    function validateArgs() {
        const maxArgs = parse.input.args.length;
        if (parse.input.strict && parse.output.argv.length > maxArgs) {
            const extras = parse.output.argv.slice(maxArgs);
            throw new errors_2.UnexpectedArgsError({ parse, args: extras });
        }
        const requiredArgs = parse.input.args.filter(a => a.required);
        const missingRequiredArgs = requiredArgs.slice(parse.output.argv.length);
        if (missingRequiredArgs.length) {
            throw new errors_2.RequiredArgsError({ parse, args: missingRequiredArgs });
        }
    }
    function validateFlags() {
        for (let [name, flag] of Object.entries(parse.input.flags)) {
            if (parse.output.flags[name]) {
                for (let also of flag.dependsOn || []) {
                    if (!parse.output.flags[also]) {
                        throw new errors_1.CLIError(`--${also}= must also be provided when using --${name}=`);
                    }
                }
                for (let also of flag.exclusive || []) {
                    if (parse.output.flags[also]) {
                        throw new errors_1.CLIError(`--${also}= cannot also be provided when using --${name}=`);
                    }
                }
            }
            else {
                if (flag.required)
                    throw new errors_2.RequiredFlagError({ parse, flag });
            }
        }
    }
    validateArgs();
    validateFlags();
}
exports.validate = validate;
