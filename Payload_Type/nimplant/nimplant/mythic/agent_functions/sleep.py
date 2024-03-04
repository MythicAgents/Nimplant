from mythic_container.MythicCommandBase import *
import json


def positiveTime(val):
    if val < 0:
        raise ValueError("Value must be positive")

class SleepArguments(TaskArguments):
    def __init__(self, command_line, **kwargs):
        super().__init__(command_line, **kwargs)
        self.args = [
            CommandParameter(
                name="jitter",
                type=ParameterType.Number,
                validation_func=positiveTime,
                default_value=0,
                parameter_group_info=[ParameterGroupInfo(
                    required=False,
                    ui_position=2
                )],
                description="Percentage of C2's interval to use as jitter",
            ),
            CommandParameter(
                name="seconds",
                type=ParameterType.Number,
                parameter_group_info=[ParameterGroupInfo(
                    required=False,
                    ui_position=1
                )],
                validation_func=positiveTime,
                description="Number of seconds between checkins",
            ),
        ]

    async def parse_arguments(self):
        if self.command_line[0] != "{":
            pieces = self.command_line.split(" ")
            if len(pieces) == 1:
                self.add_arg("seconds", pieces[0])
                self.remove_arg("jitter")
            elif len(pieces) == 2:
                self.add_arg("seconds", pieces[0])
                self.add_arg("jitter", pieces[1])
            else:
                raise Exception("Wrong number of parameters, should be 1 or 2")
        else:
            self.load_args_from_json_string(self.command_line)


class SleepCommand(CommandBase):
    cmd = "sleep"
    needs_admin = False
    help_cmd = "sleep {interval} [jitter%]"
    description = "Update the sleep interval for the agent."
    version = 3
    author = "@NotoriousRebel"
    argument_class = SleepArguments
    attackmapping = ["T1029"]

    async def create_go_tasking(self, taskData: PTTaskMessageAllData) -> PTTaskCreateTaskingMessageResponse:
        response = PTTaskCreateTaskingMessageResponse(
            TaskID=taskData.Task.ID,
            Success=True,
        )
        return response

    async def process_response(self, task: PTTaskMessageAllData, response: any) -> PTTaskProcessResponseMessageResponse:
        resp = PTTaskProcessResponseMessageResponse(TaskID=task.Task.ID, Success=True)
        return resp
