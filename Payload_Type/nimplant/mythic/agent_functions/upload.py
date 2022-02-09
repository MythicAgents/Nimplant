from mythic_payloadtype_container.MythicCommandBase import *
from mythic_payloadtype_container.MythicRPC import *
import json


class UploadArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="file", type=ParameterType.File, description="file to upload"
            ),
            CommandParameter(
                name="remote_path",
                type=ParameterType.String,
                description="/remote/path/on/victim.txt",
            ),
        ]

    async def parse_arguments(self):
        if len(self.command_line) > 0:
            if self.command_line[0] == "{":
                self.load_args_from_json_string(self.command_line)
            else:
                raise ValueError("Missing JSON arguments")
        else:
            raise ValueError("Missing arguments")


class UploadCommand(CommandBase):
    cmd = "upload"
    needs_admin = False
    help_cmd = "upload"
    description = (
        "Upload a file to the target machine by selecting a file from your computer. "
    )
    version = 2
    supported_ui_features = ["file_browser:upload"]
    author = "@NotoriousRebel"
    attackmapping = ["T1132", "T1030", "T1105"]
    argument_class = UploadArguments

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        file_resp = await MythicRPC().execute("get_file",
                                              file_id=task.args.get_arg("file"),
                                              task_id=task.id,
                                              get_contents=False)
        if file_resp.status == MythicRPCStatus.Success:
            if len(file_resp.response) > 0:
                original_file_name = file_resp.response[0]["filename"]
                if len(task.args.get_arg("remote_path")) == 0:
                    task.args.add_arg("remote_path", original_file_name)
                task.display_params = original_file_name + " to " + task.args.get_arg("remote_path")
        else:
            raise Exception("Error from Mythic: " + file_resp.error)
        return task

    async def process_response(self, response: AgentResponse):
        pass
