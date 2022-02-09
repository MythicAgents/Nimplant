from mythic_payloadtype_container.MythicCommandBase import *
import json


class RmArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        if len(self.command_line) > 0:
            if self.command_line[0] == "{":
                tmp_json = json.loads(self.command_line)
                self.command_line = tmp_json["path"] + "/" + tmp_json["file"]


class RmCommand(CommandBase):
    cmd = "rm"
    needs_admin = False
    help_cmd = "rm [path]"
    description = "Delete a file."
    version = 2
    supported_ui_features = ["file_browser:remove"]
    author = "@NotoriousRebel"
    argument_class = RmArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
