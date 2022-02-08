from mythic_payloadtype_container.MythicCommandBase import *
import json


class UnsetEnvArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class UnsetEnvCommand(CommandBase):
    cmd = "unsetenv"
    needs_admin = False
    help_cmd = "unsetenv [param]"
    description = "Unset an environment variable"
    version = 2
    author = "@NotoriousRebel"
    argument_class = UnsetEnvArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
