from mythic_payloadtype_container.MythicCommandBase import *
import json


class LsArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(name="path", type=ParameterType.String, default_value="."),
            CommandParameter(name="recurse", type=ParameterType.String, default_value="false")
        ]

    async def parse_arguments(self):
        if len(self.command_line) > 0:
            if self.command_line[0] == '{':
                self.load_args_from_json_string(self.command_line)
            else:
                self.add_arg("path", self.command_line)


class LsCommand(CommandBase):
    cmd = "ls"
    needs_admin = False
    help_cmd = "ls [directory] [recurse?]"
    description = "List files in directory with option to recursively list files"
    version = 1
    supported_ui_features = ["file_browser:list"]
    author = "@NotoriousRebel"
    argument_class = LsArguments
    attackmapping = ["T1083"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
