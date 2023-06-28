import pandas as pd
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
PROGRESSION_JSON = OUTPUT_DIR+"/progression.json"
GAMEPLAY_JSON = OUTPUT_DIR+"/gameplay.json"

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

def format_data():
	# export data into json
	df = pd.read_json(INPUT_JSON_PATH)
	events, sessions, users = midas.load(df)

	# # export data
	print("constructing event table")
	event_df = DataFrame(midas.dump(events))
	event_df.to_json(EVENTS_JSON, indent=4, orient="records")

	print("constructing session table")
	session_df = DataFrame(midas.dump(sessions))
	session_df.to_json(SESSIONS_JSON, indent=4, orient="records")

	print("constructing user table")
	session_df = DataFrame(midas.dump(users))
	session_df.to_json(USERS_JSON, indent=4, orient="records")

	# construct onboarding table
	print("constructing onboarding table")
	# onboarding_df = event_df[event_df["name"] == "UserExitQuit"]
	onboarding_df_data = []
	for _i, row in event_df.iterrows():
		event_id = dpath.get(row, "event_id", default=None)
		seconds_since_session_start = dpath.get(row, "seconds_since_session_start", default=None)
		if event_id and seconds_since_session_start:
			onboarding_df_data.append({
				"event_id": event_id,
				"onboarding_time": seconds_since_session_start,
			})

	# Create a new DataFrame from the list of dictionaries
	onboarding_df = pd.DataFrame(onboarding_df_data)
	onboarding_df.to_json(ONBOARDING_JSON, indent=4, orient="records")

	# construct gameplay table
	print("constructing gameplay table")
	gameplay_df_data = []
	for _i, row in event_df.iterrows():
		event_id = dpath.get(row, "event_id", default=None)
		seconds_since_session_start = dpath.get(row, "seconds_since_session_start", default=None)

		gameplay_state = {
			"RunningStation": dpath.get(row, "state_date/GameplayEvent/RunningStation", default=False),
			"EasyObby": dpath.get(row, "state_date/GameplayEvent/Obby/Easy", default=False),
			"HardObby": dpath.get(row, "state_date/GameplayEvent/Obby/Hard", default=False),
			"PetManagement": dpath.get(row, "state_date/GameplayEvent/PetManagement", default=False),
			"Explore": dpath.get(row, "state_date/GameplayEvent/Explore", default=False),
			"UpgradingTycoon": dpath.get(row, "state_date/GameplayEvent/UpgradingTycoon", default=False),
			"PetHatch": dpath.get(row, "state_date/GameplayEvent/PetHatch", default=False),
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

	# construct gameplay table
	print("constructing progression table")
	progression_df_data = []
	for _i, row in event_df.iterrows():
		event_id = dpath.get(row, "event_id", default=None)
		seconds_since_session_start = dpath.get(row, "seconds_since_session_start", default=None)

		windmill_value_lvl = dpath.get(row, "state_date/Tycoon/Windmill/Level/Value", default=None)
		windmill_recharge_lvl = dpath.get(row, "state_date/Tycoon/Windmill/Level/Recharge", default=None)

		kneader_pet_id: None | str = dpath.get(row, "state_date/Tycoon/Kneader/PetBalanceId", default=None)
		kneader_pet_type: None | str = None
		kneader_pet_metal_lvl: None | int = None
		kneader_pet_lvl: None | int = None

		if kneader_pet_id != None and kneader_pet_id != "" and kneader_pet_id != "None":
			kneader_pet_type = kneader_pet_id.split("_")[0]
			kneader_pet_metal_lvl = get_metal_level(kneader_pet_id.split("_")[1])
			kneader_pet_lvl = int(kneader_pet_id.split("_")[2])

		kneader_multiplier_lvl = dpath.get(row, "state_date/Tycoon/Kneader/Level/Multiplier", default=None)
		kneader_recharge_lvl = dpath.get(row, "state_date/Tycoon/Kneader/Level/Recharge", default=None)

		oven_pet_id: None | str = dpath.get(row, "state_date/Tycoon/Oven/PetBalanceId", default=None)
		oven_value_lvl = dpath.get(row, "state_date/Tycoon/Oven/Level/Value", default=None)
		oven_recharge_lvl = dpath.get(row, "state_date/Tycoon/Oven/Level/Recharge", default=None)
		oven_pet_type: None | str = None
		oven_pet_metal_lvl: None | int = None
		oven_pet_lvl: None | int = None

		if oven_pet_id != None and oven_pet_id != "" and oven_pet_id != "None":
			oven_pet_type = oven_pet_id.split("_")[0]
			oven_pet_metal_lvl = get_metal_level(oven_pet_id.split("_")[1])
			oven_pet_lvl = int(oven_pet_id.split("_")[2])

		wrapper_pet_id: None | str = dpath.get(row, "state_date/Tycoon/Wrapper/PetBalanceId", default=None)
		wrapper_recharge_lvl = dpath.get(row, "state_date/Tycoon/Wrapper/Level/Recharge", default=None)
		wrapper_multiplier_lvl = dpath.get(row, "state_date/Tycoon/Wrapper/Level/Multiplier", default=None)
		
		wrapper_pet_type: None | str = None
		wrapper_pet_metal_lvl: None | int = None
		wrapper_pet_lvl: None | int = None

		if wrapper_pet_id != None and wrapper_pet_id != "" and wrapper_pet_id != "None":
			wrapper_pet_type = wrapper_pet_id.split("_")[0]
			wrapper_pet_metal_lvl = get_metal_level(wrapper_pet_id.split("_")[1])
			wrapper_pet_lvl = int(wrapper_pet_id.split("_")[2])

		rack_storage_lvl = dpath.get(row, "state_date/Tycoon/Rack/Level/Storage", default=None)

		deliveries_completed = dpath.get(row, "state_date/Tycoon/Truck/DeliveryCount", default=None)
		last_delivery_quantity = dpath.get(row, "state_date/Tycoon/Truck/LastDelivery/Count", default=None)
		last_delivery_value = dpath.get(row, "state_date/Tycoon/Truck/LastDelivery/Value", default=None)
		bread_unit_value: None | float = None
		if last_delivery_quantity and last_delivery_value:
			bread_unit_value = float(last_delivery_value) / float(last_delivery_quantity)

		cash = dpath.get(row, "state_date//Cash", default=None)

		if event_id and seconds_since_session_start and index and kneader_multiplier_lvl and kneader_recharge_lvl and oven_value_lvl and oven_recharge_lvl and wrapper_multiplier_lvl and wrapper_recharge_lvl and windmill_recharge_lvl and windmill_value_lvl:
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

def build_model():
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
		"event_id": "string",
		"onboarding_time": "double",
	})

	onboarding_table.new_bin("onboarding_time", 30)
	onboarding_relationship = model.new_relationship("onboarding", "event_id", "events", "event_id")
	onboarding_relationship.is_both_directions = False

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
	gameplay_relationship.is_both_directions = False

	# create gameplay table
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
	progression_relationship.is_both_directions = False

	# create relationships
	print("creating relationships")
	print("writing model")
	pbit.write_model(DASHBOARD_PATH, model)

	print("pbit model update complete")

format_data()
build_model()