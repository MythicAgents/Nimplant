from CommandBase import *
import json


class LsArguments(TaskArguments):
    def __init__(self, command_line):
        super().__init__(command_line)
        self.args = {
            "path": CommandParameter(name="path", type=ParameterType.String, default_value="."),
            "recurse": CommandParameter(name="recurse", type=ParameterType.String, default_value="false")
        }

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
    is_exit = False
    is_file_browse = True
    is_process_list = False
    is_download_file = False
    is_remove_file = False
    is_upload_file = False
    author = "@NotoriousRebel"
    argument_class = LsArguments
    attackmapping = ["T1083"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
