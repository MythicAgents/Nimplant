from mythic_payloadtype_container.MythicCommandBase import *
import json


class CpArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="source",
                type=ParameterType.String,
                description="Source file to copy.",
            ),
            CommandParameter(
                name="destination",
                type=ParameterType.String,
                description="Source will copy to this location",
            ),
        ]

    async def parse_arguments(self):
        self.load_args_from_json_string(self.command_line)


class CpCommand(CommandBase):
    cmd = "cp"
    needs_admin = False
    help_cmd = "cp"
    description = "Copy a file from one location to another."
    version = 2
    author = "@NotoriousRebel"
    argument_class = CpArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
