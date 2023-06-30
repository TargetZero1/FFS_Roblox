import os
import json
import shutil

STYLE_GUIDE_DIR_PATH = "out/StyleGuide"
STYLE_GUIDE_FILE_PATH = STYLE_GUIDE_DIR_PATH+"/init.luau"

with open(STYLE_GUIDE_FILE_PATH, "r") as read_file:
	content = read_file.read()
	with open(STYLE_GUIDE_FILE_PATH, "w") as write_file:
		content = content.replace(
			"local PseudoEnum = require(game:WaitForChild(\"PseudoEnum\"))", 
			"local Package = script.Parent; assert(Package); local PseudoEnum = require(Package:WaitForChild(\"PseudoEnum\"))"
		)
		
		write_file.write(content)

def get_package_name_from_full_wally_path(wally_package_path: str) -> str:
	return (wally_package_path.split("_")[1]).split("@")[0]

def get_package_name(wally_middle_script_content: str, fall_back_name: str) -> str:
	for line in wally_middle_script_content.split("\n"):
		prefix = "script.Parent._Index[\""
		if prefix in line:
			wally_package_path = (line.split(prefix)[1]).split("\"]")[0]
			return get_package_name_from_full_wally_path(wally_package_path)
	return fall_back_name

def rewrite_middle_package(file_path: str):
	package_name = os.path.splitext(file_name)[0].lower()
	with open(file_path, "r") as read_sub_file:
		content = read_sub_file.read()
		package_name = get_package_name(content, package_name)
		# print(f"package {package_name} in {file_path}")
		content = content.replace(f"\"{package_name}\"", "\"gui-library\"")
		with open(file_path, "w") as write_sub_file:
			write_sub_file.write(content)

STYLE_GUIDE_PACKAGE_PATH = STYLE_GUIDE_DIR_PATH + "/Packages"
for file_name in os.listdir(STYLE_GUIDE_PACKAGE_PATH):
	file_path = os.path.join(STYLE_GUIDE_PACKAGE_PATH, file_name).replace("\\", "/")
	if not os.path.isdir(file_path):
		package_name = os.path.splitext(file_name)[0].lower()
		with open(file_path, "r") as read_sub_file:
			content = read_sub_file.read()
			package_name = get_package_name(content, package_name)
			# print(f"package {package_name} in {file_path}")
			content = content.replace(f"\"{package_name}\"", "\"gui-library\"")
			with open(file_path, "w") as write_sub_file:
				write_sub_file.write(content)

INDEX_GUIDE_PACKAGE_PATH = STYLE_GUIDE_PACKAGE_PATH + "/_Index"
for package_dir_name in os.listdir(INDEX_GUIDE_PACKAGE_PATH):
	package_name = get_package_name_from_full_wally_path(package_dir_name)
	file_path = os.path.join(INDEX_GUIDE_PACKAGE_PATH, package_dir_name).replace("\\", "/")
	# print("\ntwo: ", file_path, "as", package_name, "in", package_dir_name)
	for script_name in os.listdir(file_path):

		base_name, ext = os.path.splitext(script_name)
		script_path = os.path.join(file_path, script_name).replace("\\", "/")
		# print("uhhh", base_name, "pack", package_name, "isdir", os.path.isdir(script_path))
		if not os.path.isdir(script_path):
			with open(script_path, "r") as read_sub_file:
				content = read_sub_file.read()
				for line in content.split("\n"):
					prefix = "script.Parent.Parent[\""
					if prefix in line:
						pack_name = (line.split(prefix)[1]).split("\"]")[1]
						# print("PACK NAME", pack_name)
						content = content.replace(pack_name, "[\"gui-library")
				with open(script_path, "w") as write_sub_file:
					write_sub_file.write(content)
		else:
			rojo_path = script_path + "/default.project.json"
			with open(rojo_path, "r") as read_rojo_file:
				rojo_data = json.loads(read_rojo_file.read())
				rojo_data["name"] = "gui-library"
				with open(rojo_path, "w") as write_rojo_file:
					write_rojo_file.write(json.dumps(rojo_data, indent=5))
