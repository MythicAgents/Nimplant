from mythic_payloadtype_container.MythicCommandBase import *
import json


class ShellArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class ShellCommand(CommandBase):
    cmd = "shell"
    needs_admin = False
    help_cmd = "shell [command]"
    description = "Execute a shell command with 'sh -c' if on Linux or 'cmd.exe /r' if on Windows"
    version = 2
    author = "@NotoriousRebel"
    argument_class = ShellArguments
    attackmapping = ["T1059"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass