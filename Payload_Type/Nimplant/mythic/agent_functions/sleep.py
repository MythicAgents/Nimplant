from mythic_payloadtype_container.MythicCommandBase import *
import json


class SleepArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="jitter",
                type=ParameterType.Number,
                description="Jitter percentage.",
                default_value=-1,
                parameter_group_info=[
                    ParameterGroupInfo(
                        required=False
                    )
                ]
            ),
            CommandParameter(
                name="interval",
                type=ParameterType.Number,
                description="Sleep time in seconds",
                default_value=-1,
                parameter_group_info=[
                    ParameterGroupInfo(
                        required=False
                    )
                ]
            ),
        ]

    async def parse_arguments(self):
        if len(self.command_line) > 0:
            if self.command_line[0] == "{":
                self.load_args_from_json_string(self.command_line)
            else:
                pieces = self.command_line.split(" ")
                if len(pieces) == 1:
                    self.add_arg("interval", pieces[0])
                elif len(pieces) == 2:
                    self.add_arg("interval", pieces[0])
                    self.add_arg("jitter", pieces[1])
                else:
                    raise Exception("Wrong number of arguments. should be 1 or 2")
        else:
            raise Exception("Missing arguments for sleep")


class SleepCommand(CommandBase):
    cmd = "sleep"
    needs_admin = False
    help_cmd = "sleep {interval} [jitter%]"
    description = "Update the sleep interval for the agent."
    version = 2
    author = "@NotoriousRebel"
    argument_class = SleepArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
