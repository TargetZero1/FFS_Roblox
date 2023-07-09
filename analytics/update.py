import pandas as pd
import json
import pbit
import midas
import midas.playfab as pf
import midas.data_encoder as de
from midas.playfab import PlayFabClient
from midas.data_encoder import BaseStateTree, DecodedRowData, VersionData, IndexData, IdentificationData
from pandas import DataFrame
from typing import Any, TypedDict
import dpath

dpath.options.ALLOW_EMPTY_STRING_KEYS = True

DASHBOARD_PATH = "analytics/main.pbit"
INPUT_JSON_PATH = "analytics/data.json"
OUTPUT_DIR = "analytics/output"
OUTPUT_KPI_PATH = OUTPUT_DIR+"/kpi"
EVENTS_JSON = OUTPUT_DIR+"/events.json"
SESSIONS_JSON = OUTPUT_KPI_PATH+"/sessions.json"
USERS_JSON = OUTPUT_KPI_PATH+"/users.json"
ONBOARDING_JSON = OUTPUT_DIR+"/onboarding.json"
ONBOARDING_STEP_JSON = OUTPUT_DIR+"/onboarding_step.json"
PROGRESSION_JSON = OUTPUT_DIR+"/progression.json"
GAMEPLAY_JSON = OUTPUT_DIR+"/gameplay.json"
POPULATION_JSON = OUTPUT_DIR+"/population.json"

def get_metal_level(metal: str | None) -> int | None:
	if metal == "Normal":
		return 1
	elif metal == "Silver":
		return 2
	elif metal == "Gold":
		return 3
	elif metal == "Diamond":
		return 4

	return None

def format_kpi_data() -> None:
	# export data into json
	df = pd.read_json(INPUT_JSON_PATH)
	events, sessions, users = midas.load(df)

	# # export data
	print("constructing event table")
	event_df = DataFrame(midas.dump(events))
	event_df.to_json(EVENTS_JSON, indent=4, orient="records")

	print("validating event table")
	with open(EVENTS_JSON, "r") as event_json:
		registry = {}
		for event_data in json.loads(event_json.read()):
			event_id = event_data["event_id"]
			if event_id in registry:
				if event_data["seconds_since_previous_event"] != 0:
					registry[event_id] = event_data
			else:
				registry[event_id] = event_data

		out_data = list(registry.values())

		with open(EVENTS_JSON, "w") as out_json:
			out_json.write(json.dumps(out_data, indent=5))

	print("constructing session table")
	session_df = DataFrame(midas.dump(sessions))
	session_df.to_json(SESSIONS_JSON, indent=4, orient="records")

	print("validating session table")
	with open(SESSIONS_JSON, "r") as session_json:
		session_out_data = []
		for session_data in json.loads(session_json.read()):
			version_text = session_data["version_text"]
			build_number = int(version_text.split("-")[1])
			session_data["build"] = build_number
			session_out_data.append(session_data)

		with open(SESSIONS_JSON, "w") as out_session_json:
			out_session_json.write(json.dumps(session_out_data, indent=5))			

	print("constructing user table")
	session_df = DataFrame(midas.dump(users))
	session_df.to_json(USERS_JSON, indent=4, orient="records")

def format_population_data() -> None:
	# construct onboarding table
	print("constructing onboarding table")
	event_df = pd.read_json(EVENTS_JSON)

	# onboarding_df = event_df[event_df["name"] == "UserExitQuit"]
	population_df_data = []
	for _i, row in event_df.iterrows():
		event_id = dpath.get(row, "event_id", default=None)
		seconds_since_session_start = dpath.get(row, "seconds_since_session_start", default=None)
		population_data = dpath.get(row, "state_data/Population", default=None)
		if population_data != None and event_id and seconds_since_session_start:
			out_data = {
				"event_id": event_id,
				"population_time": seconds_since_session_start,
				"peak_friends": dpath.get(row, "state_data/Population/PeakFriends", default=None),
				"friends": dpath.get(row, "state_data/Population/Friends", default=None),
				"total": dpath.get(row, "state_data/Population/Total", default=None),
			}
			population_df_data.append(out_data)

	population_df = pd.DataFrame(population_df_data)
	population_df.to_json(POPULATION_JSON, indent=4, orient="records")

def format_onboarding_data() -> None:
	# construct onboarding table
	print("constructing onboarding table")
	event_df = pd.read_json(EVENTS_JSON)

	# onboarding_df = event_df[event_df["name"] == "UserExitQuit"]
	onboarding_df_data = []
	user_ids = []
	for _i, row in event_df.iterrows():
		event_id = dpath.get(row, "event_id", default=None)
		seconds_since_session_start = dpath.get(row, "seconds_since_session_start", default=None)
		user_id = dpath.get(row, "user_id", default=None)

		onboarding_data = dpath.get(row, "state_data/Onboarding", default=None)
		if onboarding_data != None and user_id and event_id and seconds_since_session_start:
			out_data = {
				"event_id": event_id,
				"user_id": user_id,
				"onboarding_time": seconds_since_session_start,
			}
			for key, val in onboarding_data.items():
				if "Order" in val and "Completed" in val and "Total" in val:
								
	
					index = val["Order"]
					completed = val["Completed"]
					total = val["Total"]
					
					out_float_key = f"{index}_{key.lower()}_progress"
					out_data[out_float_key] = completed/total
			user_ids.append(user_id)
			onboarding_df_data.append(out_data)

	user_ids = list(dict.fromkeys(user_ids).keys())

	onboarding_user_data_list = []
	for user_id in user_ids:
		onboarding_user_data = {
			"user_id": user_id,
			"max_level": 0,
		}

		for entry_data in onboarding_df_data:
			if entry_data["user_id"] == user_id:
				for k, v in entry_data.items():
					parts = k.split("_")
					if len(parts) == 3:
						if not k in onboarding_user_data:
							onboarding_user_data[k] = v
						else:
							onboarding_user_data[k] = max(onboarding_user_data[k], v)

						if v > 0:
							level = int(parts[0]) - 1 + v
							if level > onboarding_user_data["max_level"]:
								onboarding_user_data["max_level"] = level
		onboarding_user_data_list.append(onboarding_user_data)

	# Create a new DataFrame from the list of dictionaries
	onboarding_df = pd.DataFrame(onboarding_user_data_list)
	onboarding_df.to_json(ONBOARDING_JSON, indent=4, orient="records")

	onboarding_step_list = []
	for onboarding_user_entry in onboarding_user_data_list:
		for k, v in onboarding_user_entry.items():
			parts = k.split("_")
			if len(parts) == 3:
				level = int(parts[0])
				name = parts[1]
				if level == 1 or v == 1:
					if v != 1 and level == 1:
						name = "none"
						level = 0

					onboarding_step_data = {
						"name": name,
						"level": level,
						"user_id": onboarding_user_entry["user_id"]
					}
					onboarding_step_list.append(onboarding_step_data)

	onboarding_step_df = pd.DataFrame(onboarding_step_list)
	onboarding_step_df.to_json(ONBOARDING_STEP_JSON, indent=4, orient="records")

def format_gameplay_data() -> None:

	# construct gameplay table
	print("constructing gameplay table")
	event_df = pd.read_json(EVENTS_JSON)
	gameplay_df_data = []
	for _i, row in event_df.iterrows():
		event_id = dpath.get(row, "event_id", default=None)
		seconds_since_session_start = dpath.get(row, "seconds_since_session_start", default=None)

		gameplay_state = {
			"RunningStation": dpath.get(row, "state_data/GameplayEvent/RunningStation", default=False),
			"EasyObby": dpath.get(row, "state_data/GameplayEvent/Obby/Easy", default=False),
			"HardObby": dpath.get(row, "state_data/GameplayEvent/Obby/Hard", default=False),
			"PetManagement": dpath.get(row, "state_data/GameplayEvent/PetManagement", default=False),
			"Explore": dpath.get(row, "state_data/GameplayEvent/Explore", default=False),
			"UpgradingTycoon": dpath.get(row, "state_data/GameplayEvent/UpgradingTycoon", default=False),
			"PetHatch": dpath.get(row, "state_data/GameplayEvent/PetHatch", default=False),
		}

		index = dpath.get(row, "index", default=None)

		selected_state: None | str = None
		for key, val in gameplay_state.items():
			if val:
				if selected_state == None:
					selected_state = key
				else:
					selected_state = "Unknown"
		

		if event_id and seconds_since_session_start and index:
			gameplay_df_data.append({
				"event_id": event_id,
				"gameplay_time": seconds_since_session_start,
				"state": selected_state,
			})

	gameplay_df = pd.DataFrame(gameplay_df_data)
	gameplay_df.to_json(GAMEPLAY_JSON, indent=4, orient="records")



def format_progression_data() -> None:

	# construct gameplay table
	print("constructing progression table")
	event_df = pd.read_json(EVENTS_JSON)
	progression_df_data = []
	for _i, row in event_df.iterrows():
		event_id = dpath.get(row, "event_id", default=None)
		seconds_since_session_start = dpath.get(row, "seconds_since_session_start", default=None)

		windmill_value_lvl = dpath.get(row, "state_data/Tycoon/Windmill/Level/Value", default=None)
		windmill_recharge_lvl = dpath.get(row, "state_data/Tycoon/Windmill/Level/Recharge", default=None)

		kneader_pet_id: None | str = dpath.get(row, "state_data/Tycoon/Kneader/PetBalanceId", default=None)
		kneader_pet_type: None | str = None
		kneader_pet_metal_lvl: None | int = None
		kneader_pet_lvl: None | int = None

		if kneader_pet_id != None and kneader_pet_id != "" and kneader_pet_id != "None":
			kneader_pet_type = kneader_pet_id.split("_")[0]
			kneader_pet_metal_lvl = get_metal_level(kneader_pet_id.split("_")[1])
			kneader_pet_lvl = int(kneader_pet_id.split("_")[2])

		kneader_multiplier_lvl = dpath.get(row, "state_data/Tycoon/Kneader/Level/Multiplier", default=None)
		kneader_recharge_lvl = dpath.get(row, "state_data/Tycoon/Kneader/Level/Recharge", default=None)

		oven_pet_id: None | str = dpath.get(row, "state_data/Tycoon/Oven/PetBalanceId", default=None)
		oven_value_lvl = dpath.get(row, "state_data/Tycoon/Oven/Level/Value", default=None)
		oven_recharge_lvl = dpath.get(row, "state_data/Tycoon/Oven/Level/Recharge", default=None)
		oven_pet_type: None | str = None
		oven_pet_metal_lvl: None | int = None
		oven_pet_lvl: None | int = None

		if oven_pet_id != None and oven_pet_id != "" and oven_pet_id != "None":
			oven_pet_type = oven_pet_id.split("_")[0]
			oven_pet_metal_lvl = get_metal_level(oven_pet_id.split("_")[1])
			oven_pet_lvl = int(oven_pet_id.split("_")[2])

		wrapper_pet_id: None | str = dpath.get(row, "state_data/Tycoon/Wrapper/PetBalanceId", default=None)
		wrapper_recharge_lvl = dpath.get(row, "state_data/Tycoon/Wrapper/Level/Recharge", default=None)
		wrapper_multiplier_lvl = dpath.get(row, "state_data/Tycoon/Wrapper/Level/Multiplier", default=None)
		
		wrapper_pet_type: None | str = None
		wrapper_pet_metal_lvl: None | int = None
		wrapper_pet_lvl: None | int = None

		if wrapper_pet_id != None and wrapper_pet_id != "" and wrapper_pet_id != "None":
			wrapper_pet_type = wrapper_pet_id.split("_")[0]
			wrapper_pet_metal_lvl = get_metal_level(wrapper_pet_id.split("_")[1])
			wrapper_pet_lvl = int(wrapper_pet_id.split("_")[2])

		rack_storage_lvl = dpath.get(row, "state_data/Tycoon/Rack/Level/Storage", default=None)

		deliveries_completed = dpath.get(row, "state_data/Tycoon/Truck/DeliveryCount", default=None)
		last_delivery_quantity = dpath.get(row, "state_data/Tycoon/Truck/LastDelivery/Count", default=None)
		last_delivery_value = dpath.get(row, "state_data/Tycoon/Truck/LastDelivery/Value", default=None)
		bread_unit_value: None | float = None
		if last_delivery_quantity and last_delivery_value:
			bread_unit_value = float(last_delivery_value) / float(last_delivery_quantity)

		cash = dpath.get(row, "state_data//Cash", default=None)

		if event_id and seconds_since_session_start and kneader_multiplier_lvl and kneader_recharge_lvl and oven_value_lvl and oven_recharge_lvl and wrapper_multiplier_lvl and wrapper_recharge_lvl and windmill_recharge_lvl and windmill_value_lvl:
			progression_df_data.append({
				"event_id": event_id,
				"progression_time": seconds_since_session_start,
				"cash": cash,

				"windmill_value_lvl": windmill_value_lvl,
				"windmill_recharge_lvl": windmill_recharge_lvl,

				"kneader_pet_type": kneader_pet_type,
				"kneader_pet_metal_lvl": kneader_pet_metal_lvl,
				"kneader_pet_lvl": kneader_pet_lvl,
				"kneader_multiplier_lvl": kneader_multiplier_lvl,
				"kneader_recharge_lvl": kneader_recharge_lvl,

				"oven_pet_type": oven_pet_type,
				"oven_pet_metal_lvl": oven_pet_metal_lvl,
				"oven_pet_lvl": oven_pet_lvl,
				"oven_value_lvl": oven_value_lvl,
				"oven_recharge_lvl": oven_recharge_lvl,

				"wrapper_pet_type": wrapper_pet_type,
				"wrapper_pet_metal_lvl": wrapper_pet_metal_lvl,
				"wrapper_pet_lvl": wrapper_pet_lvl,
				"wrapper_recharge_lvl": wrapper_recharge_lvl,
				"wrapper_multiplier_lvl": wrapper_multiplier_lvl,

				"rack_storage_lvl": rack_storage_lvl,

				"deliveries_completed": deliveries_completed,		
				"last_delivery_quantity": last_delivery_quantity,	
				"last_delivery_value": last_delivery_value,
				"last_delivery_bread_unit_value": bread_unit_value,
			})

	progression_df = pd.DataFrame(progression_df_data)
	progression_df.to_json(PROGRESSION_JSON, indent=4, orient="records")

	return None

def build_model() -> None:
	# construct pbit
	print("loading pbit model")
	model = pbit.load_model(DASHBOARD_PATH)
	model.clear()

	# create user table
	print("creating user table")
	user_table = model.new_table("users")
	user_table.bind_to_json(USERS_JSON, {
		"user_id":"string",
		"timestamp":"dateTime",
		"index": "int64",
		"session_count": "int64",
		"revenue": "int64",
		"duration": "double",
		"is_retained_on_d0": "boolean",
		"is_retained_on_d1": "boolean",
		"is_retained_on_d7": "boolean",
		"is_retained_on_d14": "boolean",
		"is_retained_on_d28": "boolean",
	})

	user_table.new_measure("d0_rr").set_to_retention_rate_tracker("users", "is_retained_on_d0")
	user_table.new_measure("d1_rr").set_to_retention_rate_tracker("users", "is_retained_on_d1")
	user_table.new_measure("d7_rr").set_to_retention_rate_tracker("users", "is_retained_on_d7")
	user_table.new_measure("d14_rr").set_to_retention_rate_tracker("users", "is_retained_on_d14")
	user_table.new_measure("d28_rr").set_to_retention_rate_tracker("users", "is_retained_on_d28")

	# create session table
	print("creating session table")
	session_table = model.new_table("sessions")
	session_table.bind_to_json(SESSIONS_JSON, {
		"user_id":"string",
		"session_id": "string",
		"version_text":"string",
		"index": "int64",
		"event_count": "int64",
		"revenue": "int64",
		"build": "int64",
		"duration": "double"
	})

	session_table.new_dax_column("sessions[duration] / 60", "duration_minutes_unrounded")
	session_table.new_bin("duration_minutes_unrounded", 1, bin_name = "duration_minutes")
	session_table.new_bin("revenue", 25)
	session_table.new_normalized_column("event_count", "duration_minutes", name = "events_per_minute")

	model.new_relationship("sessions", "user_id", "users", "user_id")

	# create event table
	print("creating event table")
	event_table = model.new_table("events")
	event_table.bind_to_json(EVENTS_JSON, {
		"name": "string",
		"session_id": "string",
		"event_id": "string",
		"timestamp":"dateTime",
		"index": "int64",
	})

	model.new_relationship("events", "session_id", "sessions", "session_id")

	# create onboarding table
	print("creating onboarding table")
	onboarding_table = model.new_table("onboarding")
	onboarding_table.bind_to_json(ONBOARDING_JSON, {
		"user_id": "string",
		"1_knead_progress": "double",
		"4_collect_progress": "double",
		"6_deliver_progress": "double",
		"3_wrap_progress": "double",
		"2_bake_progress": "double",
		"5_deposit_progress": "double",
		"7_hatch_progress": "double",
		"8_assign_progress": "double",
		"max_level": "double",
	})

	onboarding_table.new_bin("max_level", 1)
	onboarding_relationship = model.new_relationship("onboarding", "user_id", "users", "user_id")
	# onboarding_relationship.is_both_directions = False

	# create onboarding table
	print("creating onboarding-step table")
	onboarding_table = model.new_table("onboarding-step")
	onboarding_table.bind_to_json(ONBOARDING_STEP_JSON, {
		"user_id": "string",
		"name": "string",
		"level": "int64",
	})
	onboarding_relationship = model.new_relationship("onboarding-step", "user_id", "users", "user_id")
	# onboarding_relationship.is_both_directions = False

	# create gameplay table
	print("creating gameplay table")
	gameplay_table = model.new_table("gameplay")
	gameplay_table.bind_to_json(GAMEPLAY_JSON, {
		"event_id": "string",
		"gameplay_time": "double",
		"state": "string",
	})

	gameplay_table.new_bin("gameplay_time", 15)
	gameplay_relationship = model.new_relationship("gameplay", "event_id", "events", "event_id")
	# gameplay_relationship.is_both_directions = False

	# create population table
	print("creating population table")
	gameplay_table = model.new_table("population")
	gameplay_table.bind_to_json(POPULATION_JSON, {
		"event_id": "string",
		"population_time": "double",
		"peak_friends": "int64",
		"friends": "int64",
		"total": "int64",
	})

	gameplay_table.new_bin("population_time", 15)
	gameplay_relationship = model.new_relationship("population", "event_id", "events", "event_id")

	# create progression table
	print("creating progression table")
	progression_table = model.new_table("progression")
	progression_table.bind_to_json(PROGRESSION_JSON, {
		"event_id": "string",
		"progression_time": "double",
		"cash": "int64",

		"windmill_value_lvl": "int64",
		"windmill_recharge_lvl": "int64",

		"kneader_pet_type": "string",
		"kneader_pet_metal_lvl": "int64",
		"kneader_pet_lvl": "int64",
		"kneader_multiplier_lvl": "int64",
		"kneader_recharge_lvl": "int64",

		"oven_pet_type": "string",
		"oven_pet_metal_lvl": "int64",
		"oven_pet_lvl": "int64",
		"oven_value_lvl": "int64",
		"oven_recharge_lvl": "int64",

		"wrapper_pet_type": "string",
		"wrapper_pet_metal_lvl": "int64",
		"wrapper_pet_lvl": "int64",
		"wrapper_recharge_lvl": "int64",
		"wrapper_multiplier_lvl": "int64",

		"rack_storage_lvl": "int64",

		"deliveries_completed": "int64",
		"last_delivery_quantity": "int64",
		"last_delivery_value": "double",
		"last_delivery_bread_unit_value": "double",
	})

	progression_table.new_bin("progression_time", 15)

	progression_relationship = model.new_relationship("progression", "event_id", "events", "event_id")
	# progression_relationship.is_both_directions = False

	# create relationships
	print("creating relationships")
	print("writing model")
	pbit.write_model(DASHBOARD_PATH, model)

	print("pbit model update complete")

	return None

format_kpi_data()
format_onboarding_data()
format_population_data()
format_gameplay_data()
format_progression_data()
build_model()