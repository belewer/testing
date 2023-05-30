import subprocess

subprocess.run(["git","add","."])
subprocess.run(["git","commit","-m", '"mensaje"'])
subprocess.run(["git","push","origin", "main"])
