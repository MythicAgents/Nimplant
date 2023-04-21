from mythic_container.MythicCommandBase import *
import json
from mythic_container.MythicRPC import *

class ShellArguments(TaskArguments):

    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        if len(self.command_line.strip()) == 0:
            raise Exception("shell requires at least one command-line parameter.\n\tUsage: {}".format(ShellCommand.help_cmd))
        pass


class ShellCommand(CommandBase):
    cmd = "shell"
#    attributes=CommandAttributes(
#        dependencies=["run"]
#    )
    needs_admin = False
    help_cmd = "shell [command]  [arguments]"
    description = "Execute a shell command with 'sh -c' if on Linux or 'cmd.exe /r' if on Windows"
    version = 2
    author = "@NotoriousRebel"
    argument_class = ShellArguments
    
    attackmapping = ["T1059"]

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        #response = await MythicRPC().execute("create_subtask", parent_task_id=task.id,
        #                command="shell", params_string="cmd.exe /S /c {}".format(task.args.command_line))
        task.display_params = task.args.get_arg("command_line")
        return task



    async def process_response(self, response: AgentResponse):
        pass
