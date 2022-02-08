from mythic_payloadtype_container.MythicCommandBase import *
import json

class KillArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        pass


class KillCommand(CommandBase):
    cmd = "kill"
    needs_admin = False
    help_cmd = "kill [pid]"
    description = "Kill a process specified by PID."
    version = 2
    author = "@NotoriousRebel"
    argument_class = KillArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass