from mythic_payloadtype_container.MythicCommandBase import *
import json


class DownloadArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="file_path",
                type=ParameterType.String,
                description="Path to remote file to be downloaded",
            )
        ]

    async def parse_arguments(self):
        if len(self.command_line) > 0:
            if self.command_line[0] == "{":
                self.load_args_from_json_string(self.command_line)
            else:
                self.add_arg("path", self.command_line)
        else:
            raise ValueError("Missing arguments")


class DownloadCommand(CommandBase):
    cmd = "download"
    needs_admin = False
    help_cmd = "download [path to remote file]"
    description = "Download a file from the victim machine to the Mythic server in chunks (no need for quotes in the path)"
    version = 2
    supported_ui_features = ["file_browser:download"]
    author = "@NotoriousRebel"
    argument_class = DownloadArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass