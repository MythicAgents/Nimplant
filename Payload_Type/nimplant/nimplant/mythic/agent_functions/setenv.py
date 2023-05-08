from mythic_container.MythicCommandBase import *
import json


class SetEnvArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        
        self.args = [
            CommandParameter(
                name="param",
                cli_name = "Param",
                display_name = "Param to set env value of.",
                type=ParameterType.String,
                description='Param to set env value of',
                parameter_group_info=[
                    ParameterGroupInfo(ui_position=1)
                ]),
            CommandParameter(
                name="value",
                cli_name="Value",
                display_name="Value to set environmental variable to",
                type=ParameterType.String,
                description="Value to set environmental variable to.",
                parameter_group_info=[
                    ParameterGroupInfo(ui_position=2)
                ])
        ]

    async def parse_arguments(self):
        if self.command_line[0] == "{":
            self.load_args_from_json_string(self.command_line)
        else:
            cmds = self.split_commandline()
            if len(cmds) != 2:
                raise Exception("Invalid number of arguments given. Expected two, but received: {}\n\tUsage: {}".format(cmds, CpCommand.help_cmd))
            self.add_arg("param", cmds[0])
            self.add_arg("value", cmds[1])


class SetEnvCommand(CommandBase):
    cmd = "setenv"
    needs_admin = False
    help_cmd = "setenv [param] [value]"
    description = "Sets an environment variable to your choosing."
    version = 3
    author = "@NotoriousRebel"
    argument_class = SetEnvArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        task.display_params = "-Param {} -Value {}".format(
            task.args.get_arg("param"),
            task.args.get_arg("value"))
        return task

    async def process_response(self, response: AgentResponse):
        pass
