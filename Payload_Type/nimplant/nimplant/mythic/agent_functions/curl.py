from mythic_container.MythicCommandBase import *
import json
from mythic_container.MythicRPC import *


class CurlArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="url",
                type=ParameterType.String,
                description="URL to request.",
                default_value="https://www.google.com",
            ),
            CommandParameter(
                name="method",
                type=ParameterType.ChooseOne,
                description="Type of request",
                choices=["GET", "POST"],
            ),
            CommandParameter(
                name="headers",
                type=ParameterType.String,
                description="base64 encoded json with headers.",
                parameter_group_info=[
                    ParameterGroupInfo(
                        required=False,
                    ),
                ],
            ),
            CommandParameter(
                name="body",
                type=ParameterType.String,
                description="base64 encoded body.",
                parameter_group_info=[
                    ParameterGroupInfo(
                        required=False,
                    ),
                ],
            ),
        ]


    async def parse_arguments(self):
        if len(self.url) == 0:
            raise ValueError("Must supply a url")
        self.add_arg("url", self.command_line)

        if len(self.method) == 0:
            raise ValueError("Must supply a method")
        self.add_arg("method", self.command_line)

    async def parse_dictionary(self, dictionary_arguments):
        if "url" in dictionary_arguments:
            self.add_arg("url", dictionary_arguments["url"])
        else:
            raise ValueError("Missing 'url' argument")

        if "method" in dictionary_arguments:
            self.add_arg("method", dictionary_arguments["method"])
        else:
            raise ValueError("Missing 'method' argument")


class CurlCommand(CommandBase):
    cmd = "curl"
    needs_admin = False
    help_cmd = 'curl {  "url": "https://www.google.com",  "method": "GET",  "headers": "",  "body": "" }'
    description = "Execute a single web request."
    version = 3
    is_exit = False
    is_file_browse = False
    is_process_list = False
    is_download_file = False
    is_remove_file = False
    is_upload_file = False
    author = "@NotoriousRebel"
    argument_class = CurlArguments
    attackmapping = []

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        resp = await MythicRPC().execute("create_artifact", task_id=task.id,
            artifact="$.NSString.stringWithContentsOfFileEncodingError",
            artifact_type="API Called",
        )
        return task

    async def process_response(self, response: AgentResponse):
        pass
