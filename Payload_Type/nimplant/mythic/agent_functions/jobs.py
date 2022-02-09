from mythic_payloadtype_container.MythicCommandBase import *
import json


class JobsArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = {}

    async def parse_arguments(self):
        pass


class JobsCommand(CommandBase):
    cmd = "jobs"
    needs_admin = False
    help_cmd = "jobs"
    description = "List current jobs."
    version = 2
    author = "@NotoriousRebel"
    argument_class = JobsArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
