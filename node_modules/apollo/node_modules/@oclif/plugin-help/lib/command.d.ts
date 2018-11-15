import * as Config from '@oclif/config';
import { HelpOptions } from '.';
export default class CommandHelp {
    config: Config.IConfig;
    opts: HelpOptions;
    render: (input: string) => string;
    constructor(config: Config.IConfig, opts: HelpOptions);
    command(cmd: Config.Command): string;
    protected usage(cmd: Config.Command, flags: Config.Command.Flag[]): string;
    protected defaultUsage(command: Config.Command, _: Config.Command.Flag[]): string;
    protected description(cmd: Config.Command): string | undefined;
    protected aliases(aliases: string[] | undefined): string | undefined;
    protected examples(examples: string[] | undefined | string): string | undefined;
    protected args(args: Config.Command['args']): string | undefined;
    protected arg(arg: Config.Command['args'][0]): string;
    protected flags(flags: Config.Command.Flag[]): string | undefined;
}
