from mythic_container.MythicCommandBase import *
import json


class UnsetEnvArguments(TaskArguments):
    def __init__(self, command_line):
        super().__init__(command_line)
        self.args = [
            CommandParameter(
                name="param",
                cli_name = "Param",
                display_name = "Param to set env value of.",
                type=ParameterType.String,
                description='Param to set env value of')
        ]

    async def parse_arguments(self):
        if self.command_line[0] == "{":
            self.load_args_from_json_string(self.command_line)
        else:
            cmds = self.split_commandline()
            if len(cmds) != 1:
                raise Exception("Invalid number of arguments given. Expected One, but received: {}\n\tUsage: {}".format(cmds, CpCommand.help_cmd))
            self.add_arg("param", cmds[0])


class UnsetEnvCommand(CommandBase):
    cmd = "unsetenv"
    needs_admin = False
    help_cmd = "unsetenv [param]"
    description = "Unset an environment variable"
    version = 3
    author = "@NotoriousRebel"
    argument_class = UnsetEnvArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        task.display_params = "-Param {} -Value {}".format(
            task.args.get_arg("param"))
        return task
    async def process_response(self, response: AgentResponse):
        pass
