from mythic_payloadtype_container.MythicCommandBase import *
import json


class SetEnvArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class SetEnvCommand(CommandBase):
    cmd = "setenv"
    needs_admin = False
    help_cmd = "setenv [param] [value]"
    description = "Sets an environment variable to your choosing."
    version = 2
    author = "@NotoriousRebel"
    argument_class = SetEnvArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
