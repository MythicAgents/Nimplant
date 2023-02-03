from mythic_payloadtype_container.MythicCommandBase import *
import json


class PsArguments(TaskArguments):

    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = []

    async def parse_arguments(self):
        if len(self.command_line.strip()) > 0:
            raise Exception("ps takes no command line arguments.")
        pass


class PsCommand(CommandBase):
    cmd = "ps"
    needs_admin = False
    help_cmd = "ps"
    description = "Gather list of running processes."
    version = 2
    supported_ui_features = ["process_browser:list"]

    author = "@djhohnstein"
    argument_class = PsArguments
    attackmapping = ["T1106"]
    browser_script = BrowserScript(script_name="ps_new", author="@djhohnstein", for_new_ui=True)
    

    async def create_tasking(self, task: MythicTask) -> MythicTask:
        return task

    async def process_response(self, response: AgentResponse):
        pass
