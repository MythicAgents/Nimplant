from mythic_payloadtype_container.MythicCommandBase import *
import json


class GetEnvArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class GetEnvCommand(CommandBase):
    cmd = "getenv"
    needs_admin = False
    help_cmd = "getenv"
    description = "Get all of the current environment variables."
    version = 2
    author = "@NotoriousRebel"
    argument_class = GetEnvArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
